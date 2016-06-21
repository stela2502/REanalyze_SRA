#! /usr/bin/perl
use strict;
use warnings;
use stefans_libs::root;
use Test::More tests => 17;
use stefans_libs::file_readers::bedGraph_file;

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
	die
"Package not complete - test data is missing! ($plugin_path/data/ChrY_summits.bad.tar.gz)\n";
}

unless ( -d "$plugin_path/data/output/ChIP_data/" ) {
	mkdir("$plugin_path/data/output/ChIP_data/");
	system(
"tar -C $plugin_path/data/output/ChIP_data/  -zxf $plugin_path/data/ChrY_summits.bad.tar.gz"
	);
}

ok(
	-f "$plugin_path/data/output/ChIP_data/DRR008644_hisat.sorted_summits.bed.Ychr",
	"input summit data"
);

$samples = "$plugin_path/data/ChIP_samples.xls";
ok( -f $samples, "input summit sample data" );

$outfile = "$plugin_path/data/output/ChIP_script/FANTOM_ChrY.R";

@options = ( 'region', 500 );

if ( -d "$plugin_path/data/output/ChIP_script/" ) {
	system("rm -Rf $plugin_path/data/output/ChIP_script/");
}

my $cmd =
    "perl -I $plugin_path/../lib  $exec "
  . " -files $plugin_path/data/output/ChIP_data/*.Ychr"
  . " -samples "
  . $samples
  . " -outfile "
  . $outfile
  . " -options "
  . join( ' ', @options )
  . " -debug";

system( $cmd . $to_null );
foreach (
	'FANTOM_ChrY.R', 'ChIP_data_2_bed_file.R', 'FANTOM_ChrY.R.log',
	'Samples.xls',   'PeakRegions.bed'
  )
{
	ok( -f "$plugin_path/data/output/ChIP_script/" . $_, "outfile $_ created" );
}

$value = stefans_libs::file_readers::bedGraph_file->new();
$value->read_file("$plugin_path/data/output/ChIP_script/PeakRegions.bed");

#print "\$exp = "  . root->print_perl_var_def(	$value->select_where( 'value', sub { shift >= 100 } )->{'data'} )  . ";\n";
$exp = [
	[ 'chrY', '2841606',  '2842106',  '212' ],
	[ 'chrY', '2935398',  '2935898',  '107' ],
	[ 'chrY', '3969550',  '3970050',  '197' ],
	[ 'chrY', '4344673',  '4345173',  '322' ],
	[ 'chrY', '4353047',  '4353547',  '212' ],
	[ 'chrY', '4910010',  '4910510',  '172' ],
	[ 'chrY', '7273954',  '7274454',  '187' ],
	[ 'chrY', '7425954',  '7426454',  '236' ],
	[ 'chrY', '7576728',  '7577228',  '214' ],
	[ 'chrY', '7666345',  '7666845',  '151' ],
	[ 'chrY', '8370300',  '8370800',  '227' ],
	[ 'chrY', '8419786',  '8420286',  '124' ],
	[ 'chrY', '9141911',  '9142411',  '209' ],
	[ 'chrY', '10040878', '10041378', '239' ],
	[ 'chrY', '10197343', '10197843', '385' ],
	[ 'chrY', '10197848', '10198348', '325' ],
	[ 'chrY', '10198426', '10198926', '366' ],
	[ 'chrY', '11167684', '11168184', '107' ],
	[ 'chrY', '11214845', '11215345', '104' ],
	[ 'chrY', '11861770', '11862270', '224' ],
	[ 'chrY', '11982499', '11982999', '325' ],
	[ 'chrY', '12662361', '12662861', '176' ],
	[ 'chrY', '12904837', '12905337', '202' ],
	[ 'chrY', '13286573', '13287073', '184' ],
	[ 'chrY', '13299289', '13299789', '157' ],
	[ 'chrY', '13479807', '13480307', '154' ],
	[ 'chrY', '14138744', '14139244', '113' ],
	[ 'chrY', '14204926', '14205426', '119' ],
	[ 'chrY', '17115570', '17116070', '274' ],
	[ 'chrY', '17389134', '17389634', '255' ],
	[ 'chrY', '17580310', '17580810', '193' ],
	[ 'chrY', '18147821', '18148321', '111' ],
	[ 'chrY', '18960935', '18961435', '102' ],
	[ 'chrY', '19340898', '19341398', '171' ],
	[ 'chrY', '19437222', '19437722', '109' ],
	[ 'chrY', '19744586', '19745086', '184' ],
	[ 'chrY', '20575481', '20575981', '199' ],
	[ 'chrY', '20863212', '20863712', '175' ],
	[ 'chrY', '26388802', '26389302', '152' ]
];

is_deeply( $value->select_where( 'value', sub { shift > 100 } )->{'data'},
	$exp, "right one chr data" );

### try it with two chromosomes

## find the data files
unless ( -f "$plugin_path/data/ChrY_22_summits.bad.tar.gz" ) {
	die
"Package not complete - test data 2 is missing! ($plugin_path/data/ChrY_22_summits.bad.tar.gz)\n";
}
unless (
	-f "$plugin_path/data/output/ChIP_data/DRR008730_hisat.sorted_summits.bed.Ychr22"
  )
{
	system(
"tar -C $plugin_path/data/output/ChIP_data/  -zxf $plugin_path/data/ChrY_22_summits.bad.tar.gz"
	);
}

ok(
	-f "$plugin_path/data/output/ChIP_data/DRR008730_hisat.sorted_summits.bed.Ychr22",
	"input summit data 2"
);

$samples = "$plugin_path/data/ChIP_samples.xls";
ok( -f $samples, "input summit sample data" );

$outfile = "$plugin_path/data/output/ChIP_script2/FANTOM_ChrY.R";

if ( -d "$plugin_path/data/output/ChIP_script2/" ) {
	system("rm -Rf $plugin_path/data/output/ChIP_script2/");
}

$cmd =
    "perl -I $plugin_path/../lib  $exec "
  . " -files $plugin_path/data/output/ChIP_data/*.Ychr22"
  . " -samples "
  . $samples
  . " -outfile "
  . $outfile
  . " -options "
  . join( ' ', @options )
  . " -debug";

system( $cmd . $to_null );
foreach (
	'FANTOM_ChrY.R', 'ChIP_data_2_bed_file.R', 'FANTOM_ChrY.R.log',
	'Samples.xls',   'PeakRegions.bed'
  )
{
	ok( -f "$plugin_path/data/output/ChIP_script2/" . $_,
		"outfile $_ created (2)" );
}

$value = stefans_libs::file_readers::bedGraph_file->new();
$value->read_file("$plugin_path/data/output/ChIP_script2/PeakRegions.bed");

$exp = [
	[ 'chrY',  '10198461', '10198961', '11' ],
	[ 'chr22', '11251373', '11251873', '17' ],
	[ 'chr22', '11251966', '11252466', '15' ],
	[ 'chr22', '11629623', '11630123', '11' ],
	[ 'chr22', '11630149', '11630649', '19' ],
	[ 'chr22', '17638759', '17639259', '11' ],
	[ 'chr22', '19178456', '19178956', '11' ],
	[ 'chr22', '19432328', '19432828', '12' ],
	[ 'chr22', '19854703', '19855203', '11' ],
	[ 'chr22', '20116974', '20117474', '12' ],
	[ 'chr22', '20117483', '20117983', '12' ],
	[ 'chr22', '20319789', '20320289', '12' ],
	[ 'chr22', '20858632', '20859132', '13' ],
	[ 'chr22', '20982198', '20982698', '11' ],
	[ 'chr22', '21001615', '21002115', '17' ],
	[ 'chr22', '21642033', '21642533', '12' ],
	[ 'chr22', '23180508', '23181008', '12' ],
	[ 'chr22', '23786986', '23787486', '11' ],
	[ 'chr22', '24011175', '24011675', '12' ],
	[ 'chr22', '24555704', '24556204', '12' ],
	[ 'chr22', '26483623', '26484123', '18' ],
	[ 'chr22', '27919084', '27919584', '11' ],
	[ 'chr22', '28800389', '28800889', '12' ],
	[ 'chr22', '31496271', '31496771', '13' ],
	[ 'chr22', '32474724', '32475224', '15' ],
	[ 'chr22', '35299898', '35300398', '11' ],
	[ 'chr22', '37639480', '37639980', '11' ],
	[ 'chr22', '37849319', '37849819', '12' ],
	[ 'chr22', '38057258', '38057758', '11' ],
	[ 'chr22', '39014163', '39014663', '12' ],
	[ 'chr22', '41285722', '41286222', '11' ],
	[ 'chr22', '41620890', '41621390', '13' ],
	[ 'chr22', '41682285', '41682785', '11' ],
	[ 'chr22', '42070556', '42071056', '12' ],
	[ 'chr22', '42649210', '42649710', '11' ],
	[ 'chr22', '45309941', '45310441', '11' ],
	[ 'chr22', '45671842', '45672342', '12' ],
	[ 'chr22', '46762345', '46762845', '12' ],
	[ 'chr22', '49960500', '49961000', '12' ],
	[ 'chr22', '50783471', '50783971', '13' ]
];

is_deeply( $value->select_where( 'value', sub { shift > 10 } )->{'data'},
	$exp, "right two chr data" );

#print "\$exp = "  . root->print_perl_var_def(	$value->select_where( 'value', sub { shift >= 10 } )->{'data'} )  . ";\n";

#print "\$exp = ".root->print_perl_var_def($value ).";\n
