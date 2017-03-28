#! /usr/bin/perl
use strict;
use warnings;
use stefans_libs::root;
use Test::More tests => 2;
use stefans_libs::flexible_data_structures::data_table;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $value, @values, $exp, $column, $infile, $outfile, );

my $exec = $plugin_path . "/../bin/to_download_column.pl";
ok( -f $exec, 'the script has been found' );
my $outpath = "$plugin_path/data/output/to_download_column";
if ( -d $outpath ) {
	system("rm -Rf $outpath");
}

$infile = $plugin_path."/data/to_download_column_input.xls";
$outfile = $outpath."/outfile.xls";
$column = 'DRX';

my $cmd =
    "perl -I $plugin_path/../lib  $exec "
. " -column " . $column 
. " -experiment " # or not?
. " -infile " . $infile 
. " -outfile " . $outfile 
. " -debug";


my $start = time;
system( $cmd );
my $duration = time - $start;
print "Execution time: $duration s\n";


my $result = data_table->new();
$result->read_file($outfile);
$value = $result->GetAsArray('Download');
#print "\$exp = ".root->print_perl_var_def($value ).";\n";
$exp = [ 'wget -r \'ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByExp/sra/DRX/DRX062/DRX062665\'', 'wget -r \'ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByExp/sra/DRX/DRX062/DRX062664\'', 'wget -r \'ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByExp/sra/DRX/DRX062/DRX062663\'', 'wget -r \'ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByExp/sra/DRX/DRX062/DRX062662\'', 'wget -r \'ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByExp/sra/DRX/DRX062/DRX062661\'', 'wget -r \'ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByExp/sra/DRX/DRX062/DRX062660\'', 'wget -r \'ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByExp/sra/DRX/DRX062/DRX062659\'', 'wget -r \'ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByExp/sra/DRX/DRX062/DRX062658\'', 'wget -r \'ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByExp/sra/DRX/DRX062/DRX062657\'' ];

is_deeply( $value, $exp, "download column" );

#print "\$exp = ".root->print_perl_var_def($value ).";\n";