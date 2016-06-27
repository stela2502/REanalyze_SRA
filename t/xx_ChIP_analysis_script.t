#! /usr/bin/perl
use strict;
use warnings;
use stefans_libs::root;
use Test::More tests => 21;
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
	'FANTOM_ChrY.R',        'ChIP_data_2_bed_file.R',
	'FANTOM_ChrY.R.log',    'Samples.xls',
	'PeakRegions.bedGraph', 'PeakRegions.xls'
  )
{
	ok( -f "$plugin_path/data/output/ChIP_script/" . $_, "outfile $_ created" );
}

$value = stefans_libs::file_readers::bedGraph_file->new();
$value->read_file("$plugin_path/data/output/ChIP_script/PeakRegions.bedGraph");

#print "\$exp = "  . root->print_perl_var_def(	$value->select_where( 'value', sub { shift >= 100 } )->{'data'} )  . ";\n";

$exp = [
	[ 'chrY', '2841556',  '2841953',  '212' ],
	[ 'chrY', '2935348',  '2935891',  '107' ],
	[ 'chrY', '3969500',  '3969754',  '197' ],
	[ 'chrY', '4344623',  '4344919',  '322' ],
	[ 'chrY', '4352997',  '4353247',  '212' ],
	[ 'chrY', '4909960',  '4910212',  '172' ],
	[ 'chrY', '7273904',  '7274297',  '187' ],
	[ 'chrY', '7425904',  '7426279',  '236' ],
	[ 'chrY', '7576678',  '7577018',  '214' ],
	[ 'chrY', '7666295',  '7666661',  '151' ],
	[ 'chrY', '8370250',  '8370703',  '227' ],
	[ 'chrY', '8419736',  '8419980',  '124' ],
	[ 'chrY', '9141861',  '9142179',  '209' ],
	[ 'chrY', '10040828', '10041168', '239' ],
	[ 'chrY', '10197293', '10197851', '385' ],
	[ 'chrY', '10197798', '10198349', '325' ],
	[ 'chrY', '10198376', '10198832', '366' ],
	[ 'chrY', '11167634', '11167884', '107' ],
	[ 'chrY', '11214795', '11215065', '104' ],
	[ 'chrY', '11861720', '11862037', '224' ],
	[ 'chrY', '11982449', '11982776', '325' ],
	[ 'chrY', '12662311', '12662673', '176' ],
	[ 'chrY', '12904787', '12905081', '202' ],
	[ 'chrY', '13286523', '13286902', '184' ],
	[ 'chrY', '13299239', '13299492', '157' ],
	[ 'chrY', '13479757', '13480058', '154' ],
	[ 'chrY', '14138694', '14139074', '113' ],
	[ 'chrY', '14204876', '14205118', '119' ],
	[ 'chrY', '17115520', '17115873', '274' ],
	[ 'chrY', '17389084', '17389545', '255' ],
	[ 'chrY', '17580260', '17580589', '193' ],
	[ 'chrY', '18147771', '18148306', '111' ],
	[ 'chrY', '18960885', '18961130', '102' ],
	[ 'chrY', '19340848', '19341097', '171' ],
	[ 'chrY', '19437172', '19437418', '109' ],
	[ 'chrY', '19744536', '19744982', '184' ],
	[ 'chrY', '20575431', '20575988', '199' ],
	[ 'chrY', '20863162', '20863408', '175' ],
	[ 'chrY', '26388752', '26389032', '152' ]
];

is_deeply( $value->select_where( 'value', sub { shift > 100 } )->{'data'},
	$exp, "right one chr data" );

$value = data_table->new(
	{
		'no_doubble_cross' => 1,
		'filename' => "$plugin_path/data/output/ChIP_script/PeakRegions.xls"
	}
);

#print "\$exp = "  . root->print_perl_var_def(	$value->select_where( 'sum', sub { shift == 102  } )->{'data'} )  . ";\n";

$exp = [
	[
		'chrY', '18960885', '18961130', '102',
		'0',    '1',        '0',        '1',
		'1',    '0',        '0',        '0',
		'0',    '1',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '1',        '1',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '1',        '0',
		'1',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '1',
		'0',    '1',        '1',        '0',
		'0',    '0',        '0',        '0',
		'0',    '1',        '0',        '0',
		'0',    '1',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '1',        '0',        '1',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '1',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '1',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '1',
		'0',    '1',        '1',        '1',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '1',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '1',        '1',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '1',        '1',
		'1',    '0',        '0',        '0',
		'0',    '1',        '0',        '1',
		'1',    '0',        '1',        '1',
		'0',    '0',        '1',        '0',
		'1',    '0',        '1',        '1',
		'0',    '0',        '1',        '0',
		'0',    '1',        '1',        '1',
		'1',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '1',        '1',
		'1',    '1',        '0',        '0',
		'1',    '0',        '1',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '1',
		'0',    '0',        '1',        '1',
		'1',    '1',        '1',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '1',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '1',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '1',
		'0',    '0',        '1',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '1',
		'0',    '1',        '1',        '0',
		'0',    '1',        '1',        '1',
		'0',    '0',        '1',        '0',
		'1',    '1',        '1',        '1',
		'1',    '1',        '1',        '1',
		'1',    '1',        '1',        '1',
		'1',    '1',        '1',        '0',
		'1',    '1',        '1',        '1',
		'1',    '1',        '0',        '1',
		'0',    '1',        '1',        '1',
		'1',    '1',        '1',        '1',
		'1',    '1',        '1',        '1',
		'1',    '1',        '1',        '1',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '1',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0',        '0',
		'0',    '0',        '0'
	]
];

is_deeply( $value->select_where( 'sum', sub { shift == 102 } )->{'data'},
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
	'FANTOM_ChrY.R',        'ChIP_data_2_bed_file.R',
	'FANTOM_ChrY.R.log',    'Samples.xls',
	'PeakRegions.bedGraph', 'PeakRegions.xls'
  )
{
	ok( -f "$plugin_path/data/output/ChIP_script2/" . $_,
		"outfile $_ created (2)" );
}

$value = stefans_libs::file_readers::bedGraph_file->new();
$value->read_file("$plugin_path/data/output/ChIP_script2/PeakRegions.bedGraph");

$exp = [
	[ 'chrY',  '10198411', '10198763', '11' ],
	[ 'chr22', '11251323', '11251905', '17' ],
	[ 'chr22', '11251916', '11252337', '15' ],
	[ 'chr22', '11629573', '11630086', '11' ],
	[ 'chr22', '11630099', '11630677', '19' ],
	[ 'chr22', '17638709', '17638972', '11' ],
	[ 'chr22', '19178406', '19178807', '11' ],
	[ 'chr22', '19432278', '19432728', '12' ],
	[ 'chr22', '19854653', '19855049', '11' ],
	[ 'chr22', '20116924', '20117272', '12' ],
	[ 'chr22', '20117433', '20117812', '12' ],
	[ 'chr22', '20319739', '20320212', '12' ],
	[ 'chr22', '20858582', '20859143', '13' ],
	[ 'chr22', '20982148', '20982507', '11' ],
	[ 'chr22', '21001565', '21002156', '17' ],
	[ 'chr22', '21641983', '21642527', '12' ],
	[ 'chr22', '23180458', '23181030', '12' ],
	[ 'chr22', '23786936', '23787422', '11' ],
	[ 'chr22', '24011125', '24011597', '12' ],
	[ 'chr22', '24555654', '24556186', '12' ],
	[ 'chr22', '26483573', '26484112', '18' ],
	[ 'chr22', '27919034', '27919553', '11' ],
	[ 'chr22', '28800339', '28800912', '12' ],
	[ 'chr22', '31496221', '31496732', '13' ],
	[ 'chr22', '32474674', '32475039', '15' ],
	[ 'chr22', '35299848', '35300355', '11' ],
	[ 'chr22', '37639430', '37639845', '11' ],
	[ 'chr22', '37849269', '37849626', '12' ],
	[ 'chr22', '38057208', '38057582', '11' ],
	[ 'chr22', '39014113', '39014446', '12' ],
	[ 'chr22', '41285672', '41286246', '11' ],
	[ 'chr22', '41620840', '41621366', '13' ],
	[ 'chr22', '41682235', '41682602', '11' ],
	[ 'chr22', '42070506', '42070853', '12' ],
	[ 'chr22', '42649160', '42649638', '11' ],
	[ 'chr22', '45309891', '45310224', '11' ],
	[ 'chr22', '45671792', '45672194', '12' ],
	[ 'chr22', '46762295', '46762869', '12' ],
	[ 'chr22', '49960450', '49960984', '12' ],
	[ 'chr22', '50783421', '50784003', '13' ]
];

#print "\$exp = "  . root->print_perl_var_def(	$value->select_where( 'value', sub { shift > 10 } )->{'data'} )  . ";\n";

is_deeply( $value->select_where( 'value', sub { shift > 10 } )->{'data'},
	$exp, "right two chr data" );

$value = data_table->new(
	{
		'no_doubble_cross' => 1,
		'filename' => "$plugin_path/data/output/ChIP_script2/PeakRegions.xls"
	}
);

#print "\$exp = "  . root->print_perl_var_def(	$value->select_where( 'sum', sub { shift > 16  } )->{'data'} )  . ";\n";
$exp = [
	[
		'chr22', '11251323', '11251905', '17', '1', '1', '1', '1', '1', '1',
		'1', '1', '1', '1'
	],
	[
		'chr22', '11630099', '11630677', '19', '1', '1', '1', '1', '1', '1',
		'1', '1', '1', '1'
	],
	[
		'chr22', '21001565', '21002156', '17', '1', '1', '1', '1', '1', '0',
		'1', '1', '1', '1'
	],
	[
		'chr22', '26483573', '26484112', '18', '1', '1', '1', '1', '1', '1',
		'1', '1', '1', '1'
	]
];

is_deeply( $value->select_where( 'sum', sub { shift > 16 } )->{'data'},
	$exp, "right one chr data" );

#print "\$exp = ".root->print_perl_var_def($value ).";\n
