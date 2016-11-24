 #! /usr/bin/perl -w

=head1 LICENCE

  Copyright (C) 2016-06-13 Stefan Lang

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

    RNA_analysis_script.pl
       -bam_files     :a list of bam files that you want to analyze
       -samples       :a samples definition table that contains at least 
                       one column that links to the filenames
       -outfile       :the R script you want to extend
       
       -options       :format: key_1 value_1 key_2 value_2 ... key_n value_n
       
             
             RobjName  :The R object name - make it phony
             
          ## quantify reads using RSubread options; see Rsubread documentation. 
                       
             annot.ext :the gtf file that will be used to quantify the data   
             
             nthreads            default '32'
             allowMultiOverlap   default 'TRUE'
             GTF.attrType        default 'gene_id'
             GTF.featureType     default 'exon'
             isPairedEnd         default 'FALSE'
             isGTFAnnotationFile default 'TRUE'
		

       -help           :print this help
       -debug          :verbose output
   
=head1 DESCRIPTION

  This script reads a list of bam files and a sample definition table.
  It will add a filename column into the sample definition table that links to
  the bam files. The filename will use a relative path is possible.
  
  In addition an initail R script to create a StefansExpressionSet R object will be created
  called LoadData.R in the outfile path.
  The outfile will become a rudimentary R script loading the object containing all data. 

  To get further help use 'RNA_analysis_script.pl -help' at the comman line.

=cut

use Getopt::Long;
use Pod::Usage;

use stefans_libs::flexible_data_structures::data_table;
use stefans_libs::SampleTable;

use strict;
use warnings;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';

my (
	$help,    $debug,   $database, @bam_files,
	$samples, $outfile, $options,  @options
);

Getopt::Long::GetOptions(
	"-bam_files=s{,}" => \@bam_files,
	"-samples=s"      => \$samples,
	"-outfile=s"      => \$outfile,
	"-options=s{,}"   => \@options,

	"-help"  => \$help,
	"-debug" => \$debug
);

my $warn  = '';
my $error = '';

unless ( -f $bam_files[0] ) {
	$error .= "the cmd line switch -bam_files is undefined!\n";
}
unless ( -f $samples ) {
	$error .= "the cmd line switch -samples is undefined!\n";
}
unless ( defined $outfile ) {
	$error .= "the cmd line switch -outfile is undefined!\n";
}
unless ( defined $options[0] ) {
	$warn .= "the cmd line switch -options is undefined!\n";
}

if ($help) {
	print helpString();
	exit;
}

sub helpString {
	my $errorMessage = shift;
	$errorMessage = ' ' unless ( defined $errorMessage );
	print "$errorMessage.\n";
	pod2usage( q(-verbose) => 1 );
}

my ($task_description);

$task_description .= 'perl ' . $plugin_path . '/RNA_analysis_script.pl';
$task_description .= ' -bam_files "' . join( '" "', @bam_files ) . '"'
  if ( defined $bam_files[0] );
$task_description .= " -samples '$samples'" if ( defined $samples );
$task_description .= " -outfile '$outfile'" if ( defined $outfile );
$task_description .= ' -options "' . join( '" "', @options ) . '"'
  if ( defined $options[0] );

for ( my $i = 0 ; $i < @options ; $i += 2 ) {
	$options[ $i + 1 ] =~ s/\n/ /g;
	$options->{ $options[$i] } = $options[ $i + 1 ];
}
foreach ('annot.ext' ) {
	$error .= "option $_ is missing\n" unless ( defined $options->{$_} );
}

if ( $error =~ m/\w/ ) {
	helpString($error);
	exit;
}

my $fm = root->filemap($outfile);

###### default options ########
$options->{'RobjName'}            ||= $fm->{'filename_core'};
$options->{'isGTFAnnotationFile'} ||= 'TRUE';
$options->{'GTF.featureType'}     ||= 'exon';
$options->{'GTF.attrType'}        ||= 'gene_id';
$options->{'allowMultiOverlap'}   ||= "TRUE";
$options->{'isPairedEnd'}         ||= 'FALSE';
$options->{'nthreads'}            ||= 10;
##############################

unless ( -d $fm->{'path'} ) {
	system("mkdir -p $fm->{'path'}");
}

open( LOG, ">$outfile.log" ) or die $!;
print LOG $task_description . "\n";

## Do whatever you want!

## prepare the Samples.xls file
my $data_table = data_table->new( { 'filename' => $samples } );

my $OBJ = stefans_libs::SampleTable->new({ 'data_table' => $data_table, 'filenames' => \@bam_files} );
my $ret;

( $data_table, $ret ) = $OBJ -> fix_the_table ( $fm );

print LOG "file -> table column:\t$ret\n";

$data_table->write_file("$fm->{'path'}/Samples.xls");

$options->{'nameSamples'} = 'filename';

## create the LoadData.R script

open( OUT, ">$fm->{'path'}/LoadData.R" )
  or die "I could not create the LoadData.R script\n$!\n";
sub is_digit {
	my $NO_STRING = { map{ $_ => 1} 'T', 'F', 'TRUE', 'FALSE' };
	my $target = shift;
	if ($NO_STRING->{$target}) {
		return 1;
	}
	return $target =~ m/^[-+]?\d+\.?\d*[eE]?[+-]?\d*/;
}
print OUT "library(StefansExpressionSet)\n"
  . "library(Rsubread)\n"
  . "samples <- read.delim(file='Samples.xls', sep='\\t', header=T)\n"
  . "counts <- featureCounts(files =as.vector(samples[,'filename']), "
  . join( ", ",
	map { if ( &is_digit($options->{$_})){ "$_ = $options->{$_}"} else{"$_ = '$options->{$_}'"} } 'annot.ext', 'GTF.attrType',
	'GTF.featureType',     'allowMultiOverlap',
	'isGTFAnnotationFile', 'isPairedEnd',
	'nthreads' )
  . ")\n" . "\n"
  . "save( counts, file='$options->{'RobjName'}_countsObj.RData' )\n"
  . "samples[,'filename'] <- make.names(samples[,'filename'])\n"
  . "dat = cbind(counts\$annotation,counts\$counts)\n"
  . "$options->{'RobjName'} = NGSexpressionSet( dat = dat,"
  . " Samples = samples,  Analysis = NULL, name='$options->{'RobjName'}', namecol='$options->{'nameSamples'}',"
  . " namerow= colnames(dat)[1], usecol=NULL , outpath = NULL )\n"
  . "colnames($options->{'RobjName'}\@samples)[1] = str_replace(colnames($options->{'RobjName'}\@samples[1]), '^X.', '' )\n"
  . "save( $options->{'RobjName'}, file='$options->{'RobjName'}.RData' )\n";
close(OUT);
print
"You should run the R script '$fm->{'path'}/LoadData.R' to create the data objects.\n";

close(LOG);

open( SCR, ">$fm->{'total'}" )
  or die "I could not create the main script outfile $fm->{'total'}\n$!\n";
print SCR "library(StefansExpressionSet)\n"
  . "load('$options->{'RobjName'}.RData')\n"
  . "## use the object from here on\n";
close(SCR);

print "Extend the R script $fm->{'total'} to work with the data\n";

