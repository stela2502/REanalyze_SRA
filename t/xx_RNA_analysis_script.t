#! /usr/bin/perl
use strict;
use warnings;
use stefans_libs::root;
use Test::More tests => 21;
use stefans_libs::flexible_data_structures::data_table;

use FindBin;
my $plugin_path = $FindBin::Bin;
my ( $value, $exp, @tmp, @files );
my $exec = $plugin_path . "/../bin/RNA_analysis_script.pl";
ok( -f $exec, "the script has been found" );

if ( -d "$plugin_path/data/output/Script" ) {
	system("rm -Rf $plugin_path/data/output/Script ");
}

foreach ( 'ERR688856.bam', 'ERR688857.bam', 'ERR688855.bam', 'ERR688858.bam' ) {
	push( @files, "data/fake_BAM_files/$_" );
	ok( -f "$plugin_path/data/fake_BAM_files/$_", "fake bam file $_ exists" );
}

ok( -f "$plugin_path/data/output/PRJEB7858_SUMMARY.xls",
	"the input summary file exists" );

die
"Test of script $exec not possible - please run $plugin_path/stefans_libs_XML_parser.t first\n"
  unless ( -f "$plugin_path/data/output/PRJEB7858_SUMMARY.xls" );

my $cmd =
    "perl -I $plugin_path/../lib  $exec "
  . " -bam_files "
  . join( " ", @files )
  . " -samples $plugin_path/data/output/PRJEB7858_SUMMARY.xls"
  . " -outfile $plugin_path/data/output/Script/PRJEB7858.R"
  . " -options RobjName PRJEB7858 annot.ext someGTFfile.gtf GroupName 'EXPERIMENT-DESIGN-LIBRARY_DESCRIPTOR-LIBRARY_NAME' GeneName GeneID"
  . " -debug";

system($cmd );

ok( -d "$plugin_path/data/output/Script", "Output path was created" );
foreach ( 'PRJEB7858.R.log', 'Samples.xls', 'PRJEB7858.R', 'LoadData.R' ) {
	ok( -f "$plugin_path/data/output/Script/$_", "outfile $_ exists" );
}

open( LOG, "<$plugin_path/data/output/Script/PRJEB7858.R.log" )
  or die "I could not open the log file\n$!\n";
my @values = map { chomp; $_ } <LOG>;
close(LOG);
my $internal_vals;
for ( my $i = 1 ; $i < @values ; $i++ ) {
	if ( $values[$i] =~ m/^(.+)\t(.+)$/ ) {
		$internal_vals->{$1} = $2;
	}
}

my $data_table = data_table->new(
	{ 'filename' => "$plugin_path/data/output/Script/Samples.xls" } );

( $internal_vals->{'filename col'} ) = $data_table->Header_Position('filename');

ok(
	defined $internal_vals->{'file -> table column:'},
	"log value 1 OK ($internal_vals->{'file -> table column:'})"
);

for ( my $i = 0 ; $i < $data_table->Rows() ; $i++ ) {
	@tmp = @{ @{ $data_table->{'data'} }[$i] };
	ok(
		$tmp[ $internal_vals->{'filename col'} ] =~
		  m/$tmp[$internal_vals->{'file -> table column:'}]/,
"file $tmp[$internal_vals->{'filename col'}] matches corresponding accession number $tmp[$internal_vals->{'file -> table column:'}] in Samples.xls file"
	);
	#warn "$tmp[$internal_vals->{'filename col'}] eq ../../fake_BAM_files/$tmp[$internal_vals->{'file -> table column:'}].bam\n";
	ok ( $tmp[$internal_vals->{'filename col'}] eq "../../fake_BAM_files/".$tmp[$internal_vals->{'file -> table column:'}].".bam", "right relative path" );
}

open( SCR, "<$plugin_path/data/output/Script/LoadData.R" )
  or die "could not open LoadData.R\n$!\n";
@values = map { chomp; $_ } <SCR>;
close(SCR);

print " \$exp = " . root->print_perl_var_def( \@values ) . ";\n ";
$exp = [
	'library(StefansExpressionSet)',
	'library(Rsubread)',
	'samples <- read.delim(file=\'Samples.xls\', sep=\'\\t\', header=T)',
'counts <- featureCounts(files =as.vector(samples[,\'filename\']), annot.ext = \'someGTFfile.gtf\', GTF.attrType = \'gene_id\', GTF.featureType = \'exon\', allowMultiOverlap = TRUE, isGTFAnnotationFile = TRUE, isPairedEnd = FALSE, nthreads = 10)',
	'',
'PRJEB7858 = NGSexpressionSet( dat = cbind(counts$annotation,counts$counts), Samples = samples,  Analysis = NULL, name=\'PRJEB7858\', namecol=\'filename\', namerow= \'gene_id\', usecol=NULL , outpath = NULL )',
	'save( PRJEB7858, file=\'PRJEB7858.RData\' )',
	'save( counts, file=\'PRJEB7858_countsObj.RData\' )'
];
is_deeply( \@values, $exp, "LoadData.R" );


die "You need to implement a check of the resulting R scripts!\n";

