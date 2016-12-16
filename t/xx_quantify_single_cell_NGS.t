#! /usr/bin/perl
use strict;
use warnings;
use stefans_libs::root;
use Test::More tests => 2;
use stefans_libs::flexible_data_structures::data_table;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $value, @values, $exp, $gtf_feature_type, $gtf, $n, $outfile, @bams, $gtf_art_type, );

my $exec = $plugin_path . "/../bin/quantify_single_cell_NGS.pl";
ok( -f $exec, 'the script has been found' );
my $outpath = "$plugin_path/data/output/quantify_single_cell_NGS";
if ( -d $outpath ) {
	system("rm -Rf $outpath");
}


my $cmd =
    "perl -I $plugin_path/../lib  $exec "
. " -gtf_feature_type " . $gtf_feature_type 
. " -gtf " . $gtf 
. " -n " . $n 
. " -outfile " . $outfile 
. " -bams " . join(' ', @bams )
. " -gtf_art_type " . $gtf_art_type 
. " -paires " # or not?
. " -debug";
system( $cmd );
#print "\$exp = ".root->print_perl_var_def($value ).";\n";