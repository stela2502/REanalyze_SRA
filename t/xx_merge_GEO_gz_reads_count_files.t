#! /usr/bin/perl
use strict;
use warnings;
use stefans_libs::root;
use Test::More tests => 2;
use stefans_libs::flexible_data_structures::data_table;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $value, @values, $exp, @infiles, @options, $outfile, );

my $exec = $plugin_path . "/../bin/merge_GEO_gz_reads_count_files.pl";
ok( -f $exec, 'the script has been found' );
my $outpath = "$plugin_path/data/output/merge_GEO_gz_reads_count_files";
if ( -d $outpath ) {
	system("rm -Rf $outpath");
}


my $cmd =
    "perl -I $plugin_path/../lib  $exec "
. " -infiles " . join(' ', @infiles )
. " -options " . join(' ', @options )
. " -outfile " . $outfile 
. " -debug";
my $start = time;
system( $cmd );
my $duration = time - $start;
print "Execution time: $duration s\n";
#print "\$exp = ".root->print_perl_var_def($value ).";\n";