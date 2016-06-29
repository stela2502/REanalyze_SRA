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
#$to_null = " 2> /dev/null";

my $exec = $plugin_path . "/../bin/ChIP_analysis_script.pl";
ok( -f $exec, 'the script has been found' );
my $outpath = "$plugin_path/data/output/ChIP_analysis_script";
if ( -d $outpath ) {
	system("rm -Rf $outpath");
}

## find the data files
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

ok(
	-f "$plugin_path/data/output/ChIP_data3/DRR008961_hisat.sorted_summits.bed",
	"input summit data (DRR008961_hisat.sorted_summits.bed)"
);

$samples = "$plugin_path/data/ChIP_samples.xls";
ok( -f $samples, "input summit sample data" );

$outfile = "$plugin_path/data/output/ChIP_script3/FANTOM_ChrY.R";

@options = ( 'region', 500 );

if ( -d "$plugin_path/data/output/ChIP_script3/" ) {
	system("rm -Rf $plugin_path/data/output/ChIP_script3/");
}

my $cmd =
    "perl -I $plugin_path/../lib  $exec "
  . " -files $plugin_path/data/output/ChIP_data3/*.bed"
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

#print "\$exp = ".root->print_perl_var_def($value ).";\n
