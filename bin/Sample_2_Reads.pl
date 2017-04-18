#! /usr/bin/perl -w

=head1 LICENCE

  Copyright (C) 2017-03-28 Stefan Lang

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
   
   binCreate.pl from git@github.com:stela2502/Stefans_Lib_Esentials.git commit 379745c9cb3ad2ab4f4e5a01908b35e7dc9536df
   

=head1  SYNOPSIS

    Sample_2_Reads.pl

	   -options :
	       picard : the picard option has been used to map the data
	        opath : the outpath of the copied/merged bam files (def ='./HISAT2_OUT_Per_Experiment/')
	        ipath : the inpath of the original bam files ( def= './HISAT2_OUT/')
	   
	   -outfile : the optional outfile to write a SRR to SRX table to re-link the annotation   
       
       
       -help    : print this help
       -debug   : verbose output
   
=head1 DESCRIPTION

  A filter to link / merge bam files fro a NCBI sample structure into sample specific bam files. Works as a filter on the original sra structure.

  To get further help use 'Sample_2_Reads.pl -help' at the comman line.

=cut

use Getopt::Long;
use Pod::Usage;

use strict;
use warnings;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';

my ( $help, $debug, $database, @options, $options, $outfile );

Getopt::Long::GetOptions(
	"-options=s{,}" => \@options,
	"-outfile=s" => \$outfile,
	"-help"         => \$help,
	"-debug"        => \$debug
);

my $warn  = '';
my $error = '';

if ($help) {
	print helpString();
	exit;
}

if ( $error =~ m/\w/ ) {
	helpString($error);
	exit;
}

unless ( defined $options[0] ) {
	$warn .= "the cmd line switch -options is undefined!\n";
}

sub helpString {
	my $errorMessage = shift;
	$errorMessage = ' ' unless ( defined $errorMessage );
	print "$errorMessage.\n";
	pod2usage( q(-verbose) => 1 );
}

my ($task_description);

$task_description .= 'perl ' . $plugin_path . '/Sample_2_Reads.pl';
$task_description .= ' -options "' . join( '" "', @options ) . '"'
  if ( defined $options[0] );
 $task_description .= " -outfile '".$outfile."'" if ( defined $outfile); 

if ( defined $options[0] ) {

	#my $split_this = { map { $_ => 1 } 'ignore', 'addMultiple', 'useOnly' };
	for ( my $i = 0 ; $i < @options ; $i += 2 ) {

		#if ( $split_this->{ $options[$i] } ) {
		#	$options->{ $options[$i] } = [ split( " ", $options[ $i + 1 ] ) ];
		#}
		#else {
		$options->{ $options[$i] } = $options[ $i + 1 ];

		#}
	}
}

###### default options ########
$options->{'picard'} ||= 0;
$options->{'opath'}  ||= "./HISAT2_OUT_Per_Experiment/";
$options->{'ipath'}  ||= "./HISAT2_OUT/";
###### default options ########

$options->{'opath'} .= '/' unless ( $options->{'opath'} =~ m!/$! );
unless ( -d $options->{'opath'} ) {
	mkdir( $options->{'opath'} );
}

## Do whatever you want!

unless ( -d $options->{'ipath'} ) {
	die "You need to run this filter "
	  . "in a data folder where you have the '$options->{'ipath'}' folder containing all hisat2 mapped bam files.\n";
}

my @t;
my $h;
my $fext = ".sorted.bam";
$fext = "picard_deduplicated.bam" if ( $options->{'picard'} );

while (<>) {
	chomp;
	@t = split( "/", $_ );
	$h->{ $t[8] } ||= [];
	push( @{ $h->{ $t[8] } }, $t[9] );
}

if ( defined $outfile ) {
	open (OUT, ">$outfile" ) or die "I could not create the outfile '$outfile'\n$!\n";
	print OUT "samples\treads\n";
	foreach my $SRX ( sort keys %$h ) {
		map { print OUT "$SRX\t$_\n" } @{$h->{$SRX}};
	}
	close ( OUT );
}

foreach ( sort keys %$h ) {
	if ($debug) {
		warn "$_ has "
		  . scalar( @{ $h->{$_} } )
		  . " entries: "
		  . join( ", ", @{ $h->{$_} } ) . "\n";
	}

#unless ( -f $options->{'ipath'}. @{ $h->{$_} }[0]. "*$fext" ){
#	warn "The mapped bam file '". $options->{'ipath'}. @{ $h->{$_} }[0]. "*$fext' does not exist!\n";
#	next;
#}
	if ( @{ $h->{$_} } == 1 ) {
		print "ln -s $options->{'ipath'}@{ $h->{$_} }[0]*$fext "
		  . "$options->{'opath'}$_$fext\n"
		  unless ( -f "$options->{'opath'}$_$fext" );
	}
	else {
		print "runCommand.pl -cmd '"
		  . "samtools merge  - $options->{'ipath'}"
		  . join( "*$fext $options->{'ipath'}", @{ $h->{$_} } )
		  . "*$fext | samtools sort -\@ 5 -T \$SNIC_TMP/$_$fext - > $options->{'opath'}$_$fext"
		  . "' -options N 1 n 5 A 'lu2016-2-7' t '02:00:00' "
		  . "-outfile $options->{'opath'}$_$fext -I_have_loaded_all_modules\n";

	}
}
