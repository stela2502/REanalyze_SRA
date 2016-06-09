#! /usr/bin/perl -w

=head1 LICENCE

  Copyright (C) 2016-06-09 Stefan Lang

  This program is free software; you can redistribute it 
  and/or modify it under the terms of the GNU General Public License 
  as published by the Free Software Foundation; 
  either version 3 of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful, 
  but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
  See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License 
  along with this program; if not, see <http://www.gnu.org/licenses/>.

=head1  SYNOPSIS

    subset_summary_table.pl
       -summary_file  :the SUMMARY outfile from XML_parser.pl or any other tab separated samples table
       -options       :format: key_1 value_1 key_2 value_2 ... key_n value_n
       
       		match "<s1> <s2>...<sn>" 	
       				:select only the samples that match all strings (one by one)
       				
       		match_any 1: change the match function from match all to match any
       				
       		"column <column>" "<match1> <match2>":
					:select from one column the entries that match to any of the match strings 
					 which must not contain spaces.
							        						 
       -outfile       :the outfile is a list of wget calls that should most likely go into a data folder


       -help           :print this help
       -debug          :verbose output
   
=head1 DESCRIPTION

  This script can subset a SUMMARY table produced by XML_parser.pl and prepare scripts to download the data.

  To get further help use 'analyze_RNA_subset.pl -help' at the comman line.

=cut

use Getopt::Long;
use Pod::Usage;

use strict;
use warnings;

use stefans_libs::flexible_data_structures::data_table;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';

my ( $help, $debug, $database, $summary_file, $options, @options, $outfile );

Getopt::Long::GetOptions(
	"-summary_file=s" => \$summary_file,
	"-options=s{,}"   => \@options,
	"-outfile=s"      => \$outfile,

	"-help"  => \$help,
	"-debug" => \$debug
);

my $warn  = '';
my $error = '';

unless ( defined $summary_file ) {
	$error .= "the cmd line switch -summary_file is undefined!\n";
}
unless ( defined $options[0] ) {
	$error .= "the cmd line switch -options is undefined!\n";
}
unless ( defined $outfile ) {
	$error .= "the cmd line switch -outfile is undefined!\n";
}

if ($help) {
	print helpString();
	exit;
}

if ( $error =~ m/\w/ ) {
	helpString($error);
	exit;
}

sub helpString {
	my $errorMessage = shift;
	$errorMessage = ' ' unless ( defined $errorMessage );
	print "$errorMessage.\n";
	pod2usage( q(-verbose) => 1 );
}

my ($task_description);

$task_description .= 'perl ' . $plugin_path . '/analyze_RNA_subset.pl';
$task_description .= " -summary_file '$summary_file'"
  if ( defined $summary_file );
$task_description .= ' -options "' . join( '" "', @options ) . '"'
  if ( defined $options[0] );
$task_description .= " -outfile '$outfile'" if ( defined $outfile );

for ( my $i = 0 ; $i < @options ; $i += 2 ) {
	$options[ $i + 1 ] =~ s/\n/ /g;
	if ( $options[$i] =~ m/^column (.+)$/ ) {
		$options->{'column'}->{$1} = [ split( " ", $options[ $i + 1 ] ) ];
	}
	elsif ( $options[$i] eq "match" ) {
		$options->{ $options[$i] } = [ split( " ", $options[ $i + 1 ] ) ];
	}
	else {
		$options->{ $options[$i] } = $options[ $i + 1 ];
	}
}

my $fm = root->filemap( $outfile );
unless ( -d $fm->{'path'} ) {
	system( 'mkdir -p '. $fm->{'path'} );
}

open( LOG, ">$outfile.log" ) or die $!;
print LOG $task_description . "\n";
close(LOG);

## Do whatever you want!

my $data_table = data_table->new( { 'filename' => $summary_file } );

unless ( defined $data_table->Header_Position( 'Download') ) {
	Carp::confess ( "Sorry, but I need a download column in the summary_file\n" );
}


if ( defined $options->{'match'} ) {
	my $i = 0;
	my $OK = { map { $i++ => &match($_)} @{ $data_table->{'data'} }  };
	for ( $i = $data_table->Rows() - 1 ; $i >= 0 ; $i-- ) {
		unless ( $OK->{$i} ) {
			splice( @{ $data_table->{'data'} }, $i, 1 );
			warn "I dropped line '$i' from the table\n" if ($debug);
		}
	}
}

if ( defined $options->{'column'} ) {
	Carp::confess("option 'column <colname>' is not implemented ;-)\n");
}



$data_table->write_file( $fm->{'path'}."/Samples.xls" );
open ( OUT ,">$fm->{'path'}/wget.sh" ) or die "I could not create the wget script '$fm->{'path'}/wget.sh'\n$!\n";
print OUT join( "\n", @{$data_table->GetAsArray('Download')});
close ( OUT );
print "Please run the script wget.sh in the folder '$fm->{'path'}' to download all data from NCBI.\n";


sub match {
	my $array = shift;
	my $line = join( "\t", @$array );
	if ( $options->{'match_any'} ){
		foreach (@{ $options->{'match'} }){
			return 1 if ( $line =~ m/$_/ );
		}
		return 0;
	}else {
		my $ok = 1;
		foreach (@{ $options->{'match'} }){
			$ok = 0 unless ( $line =~ m/$_/ );
		}
		return $ok;
	}
}

