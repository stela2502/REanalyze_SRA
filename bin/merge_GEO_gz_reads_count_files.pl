#! /usr/bin/perl -w

=head1 LICENCE

  Copyright (C) 2017-05-31 Stefan Lang

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

=head1 CREATED BY
   
   binCreate.pl from  commit 
   

=head1  SYNOPSIS

    merge_GEO_gz_reads_count_files.pl
       -infiles     :<please add some info!> you can specify more entries to that
       -outfile       :<please add some info!>
       -options     :<please add some info!> you can specify more entries to that
                         format: key_1 value_1 key_2 value_2 ... key_n value_n


       -help           :print this help
       -debug          :verbose output
   
=head1 DESCRIPTION

  This script reads a list of gz text files and creates a summary table from them.

  To get further help use 'merge_GEO_gz_reads_count_files.pl -help' at the comman line.

=cut

use Getopt::Long;
use Pod::Usage;

use strict;
use warnings;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';


my ( $help, $debug, $database, @infiles, $outfile, $options, @options);

Getopt::Long::GetOptions(
       "-infiles=s{,}"    => \@infiles,
	 "-outfile=s"    => \$outfile,
       "-options=s{,}"    => \@options,

	 "-help"             => \$help,
	 "-debug"            => \$debug
);

my $warn = '';
my $error = '';

unless ( defined $infiles[0]) {
	$error .= "the cmd line switch -infiles is undefined!\n";
}
unless ( defined $outfile) {
	$error .= "the cmd line switch -outfile is undefined!\n";
}
unless ( defined $options[0]) {
	$error .= "the cmd line switch -options is undefined!\n";
}


if ( $help ){
	print helpString( ) ;
	exit;
}

if ( $error =~ m/\w/ ){
	helpString($error ) ;
	exit;
}

sub helpString {
	my $errorMessage = shift;
	$errorMessage = ' ' unless ( defined $errorMessage); 
	print "$errorMessage.\n";
	pod2usage(q(-verbose) => 1);
}

### initialize default options:

#$options->{'n'} ||= 10;

###


my ( $task_description);

$task_description .= 'perl '.$plugin_path .'/merge_GEO_gz_reads_count_files.pl';
$task_description .= ' -infiles "'.join( '" "', @infiles ).'"' if ( defined $infiles[0]);
$task_description .= " -outfile '$outfile'" if (defined $outfile);
$task_description .= ' -options "'.join( '" "', @options ).'"' if ( defined $options[0]);


for ( my $i = 0 ; $i < @options ; $i += 2 ) {
	$options[ $i + 1 ] =~ s/\n/ /g;
	$options->{ $options[$i] } = $options[ $i + 1 ];
}
###### default options ########
#$options->{'something'} ||= 'default value';
##############################
use stefans_libs::Version;

my $V = stefans_libs::Version->new();
my $fm = root->filemap( $outfile );
mkdir( $fm->{'path'}) unless ( -d $fm->{'path'} );

open ( LOG , ">$outfile.log") or die $!;
print LOG '#library version'.$V->version( "Reanalyze_SRA" )."\n";
print LOG $task_description."\n";
close ( LOG );


## Do whatever you want!



