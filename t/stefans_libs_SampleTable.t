#! /usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;
BEGIN { use_ok 'stefans_libs::SampleTable' }

use stefans_libs::flexible_data_structures::data_table;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $value, @values, $exp );

my $gziped = "$plugin_path/data/problematicsTestFiles.tar.gz";
unless ( -f $gziped ) {
	die
"Package not complete - test data is missing! ($gziped)\n";
}

unless ( -d "$plugin_path/data/output/ChIP_data3/" ) {
	mkdir("$plugin_path/data/output/ChIP_data3/");
	system(
"tar -C $plugin_path/data/output/ChIP_data3/  -zxf $gziped"
	);
}
my @files;
foreach ( 'DRR008961_hisat.sorted_summits.bed', 'DRR008962_hisat.sorted_summits.bed' ){
	ok(
		-f "$plugin_path/data/output/ChIP_data3/$_",
		"input summit data ($_)"
		);
	push ( @files, "$plugin_path/data/output/ChIP_data3/$_" );
}

my $samples = "$plugin_path/data/ChIP_samples.xls";

my $data_table = data_table->new( { 'filename' => $samples } );

my $OBJ = stefans_libs::SampleTable->new(
	{ 'data_table' => $data_table, 'filenames' => \@files } );

is_deeply ( ref($OBJ) , 'stefans_libs::SampleTable', 'simple test of function stefans_libs::SampleTable -> new() ');

my $ret;
my $outfile = "$plugin_path/data/output/SampleTableTestFile.xls";
my $fm = root->filemap($outfile);
( $data_table, $ret ) = $OBJ->fix_the_table( $fm );

$data_table->write_file($outfile);

$value = data_table->new( {'filename' =>$outfile });

ok ($value->Lines() == 2, "sample file restircted to two sample files (".$value->Lines()." == 2)");
#print "\$exp = ".root->print_perl_var_def($value ).";\n";


