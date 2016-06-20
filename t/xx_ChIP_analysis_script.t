#! /usr/bin/perl
use strict;
use warnings;
use stefans_libs::root;
use Test::More tests => 12;
use stefans_libs::flexible_data_structures::data_table;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $value, @values, $exp, @files, $samples, $outfile, @options, $to_null, );


$to_null = '';
$to_null = " 2> /dev/null";


my $exec = $plugin_path . "/../bin/ChIP_analysis_script.pl";
ok( -f $exec, 'the script has been found' );
my $outpath = "$plugin_path/data/output/ChIP_analysis_script";
if ( -d $outpath ) {
	system("rm -Rf $outpath");
}


## find the data files
unless ( -f "$plugin_path/data/ChrY_summits.bad.tar.gz" ) {
	die "Package not complete - test data is missing! ($plugin_path/data/ChrY_summits.bad.tar.gz)\n";
}

unless ( -d "$plugin_path/data/output/ChIP_data/" ) {
	mkdir ( "$plugin_path/data/output/ChIP_data/" );
	system( "tar -C $plugin_path/data/output/ChIP_data/  -zxf $plugin_path/data/ChrY_summits.bad.tar.gz");
}

ok (-f "$plugin_path/data/output/ChIP_data/DRR008644_hisat.sorted_summits.bed.Ychr", "input summit data" );

$samples = "$plugin_path/data/ChIP_samples.xls";
ok (-f $samples, "input summit sample data" );

$outfile = "$plugin_path/data/output/ChIP_script/FANTOM_ChrY.R";

@options = ('region',500);

if ( -d "$plugin_path/data/output/ChIP_script/" ) {
	system( "rm -Rf $plugin_path/data/output/ChIP_script/" );
}

my $cmd =
    "perl -I $plugin_path/../lib  $exec "
. " -files $plugin_path/data/output/ChIP_data/*.Ychr"
. " -samples " . $samples 
. " -outfile " . $outfile 
. " -options " . join(' ', @options )
. " -debug"
;

system( $cmd .$to_null );
foreach ('FANTOM_ChrY.R', 'LoadData.R', 'FANTOM_ChrY.R.log', 'Samples.xls', 'PeakRegions.bed' ) {
	ok ( -f  "$plugin_path/data/output/ChIP_script/".$_ , "outfile $_ created" );
}



### try it with two chromosomes

## find the data files
unless ( -f "$plugin_path/data/ChrY_22_summits.bad.tar.gz" ) {
	die "Package not complete - test data 2 is missing! ($plugin_path/data/ChrY_22_summits.bad.tar.gz)\n";
}
unless ( -f "$plugin_path/data/output/ChIP_data/DRR008730_hisat.sorted_summits.bed.Ychr22" ) {
	system( "tar -C $plugin_path/data/output/ChIP_data/  -zxf $plugin_path/data/ChrY_22_summits.bad.tar.gz");
}

ok (-f "$plugin_path/data/output/ChIP_data/DRR008730_hisat.sorted_summits.bed.Ychr22", "input summit data 2" );

$samples = "$plugin_path/data/ChIP_samples.xls";
ok (-f $samples, "input summit sample data" );

$outfile = "$plugin_path/data/output/ChIP_script2/FANTOM_ChrY.R";

if ( -d "$plugin_path/data/output/ChIP_script2/" ) {
	system( "rm -Rf $plugin_path/data/output/ChIP_script2/" );
}

$cmd =
    "perl -I $plugin_path/../lib  $exec "
. " -files $plugin_path/data/output/ChIP_data/*.Ychr22"
. " -samples " . $samples 
. " -outfile " . $outfile 
. " -options " . join(' ', @options )
. " -debug"
;

system( $cmd .$to_null );
foreach ('FANTOM_ChrY.R', 'LoadData.R', 'FANTOM_ChrY.R.log', 'Samples.xls', 'PeakRegions.bed' ) {
	ok ( -f  "$plugin_path/data/output/ChIP_script2/".$_ , "outfile $_ created (2)" );
}
#print "\$exp = ".root->print_perl_var_def($value ).";\n