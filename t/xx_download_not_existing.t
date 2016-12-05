#! /usr/bin/perl
use strict;
use warnings;
use stefans_libs::root;
use Test::More tests => 5;
use stefans_libs::flexible_data_structures::data_table;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $value, @values, $exp, $outpath, $wget_script, );

my $exec = $plugin_path . "/../bin/download_not_existing.pl";
ok( -f $exec, 'the script has been found' );

$outpath = "$plugin_path/data/output/download_not_existing";
if ( -d $outpath ) {
	system("rm -Rf $outpath");
}

$wget_script = $plugin_path."/data/testwget_script.sh";


my $cmd =
    "perl -I $plugin_path/../lib  $exec "
. " -outpath " . $outpath 
. " -wget_script " . $wget_script 
. " -n 2"
. " -debug"
;
print ( $cmd );

ok ( ! -f $outpath."/google_index.html", "file 1 does not exist before cmd call");
system( $cmd );

ok (-f $outpath."/google_index.html", "file 1 has been created by cmd call");
ok (-f $outpath."/google_index2.html", "file 2 has been created by cmd call");
ok (-f $outpath."/google_index3.html", "file 3 has been created by cmd call");


#print "\$exp = ".root->print_perl_var_def($value ).";\n";