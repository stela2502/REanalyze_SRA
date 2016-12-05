#! /usr/bin/perl
use strict;
use warnings;
use stefans_libs::root;
use Test::More tests => 2;
use stefans_libs::flexible_data_structures::data_table;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $value, @values, $exp, $outfile, $infile, @options, );

my $exec = $plugin_path . "/../bin/XML_parser.pl";
ok( -f $exec, 'the script has been found' );
my $outpath = "$plugin_path/data/output/XML_parser";
if ( -d $outpath ) {
	system("rm -Rf $outpath");
}

$outfile= "$outpath/SRP066673";

$infile = "$plugin_path/data/SRP066673.xml";
ok ( -f $infile, "infile '$infile'");

@options = ('useOnly', '"EXPERIMENT_PACKAGE_SET EXPERIMENT_PACKAGE EXPERIMENT IDENTIFIERS TITLE accession Organization Pool RUN_SET RUN SAMPLE STUDY SUBMISSION"', 
'inspect', 'TITLE',
'ignore', 'Bases');

my $cmd =
    "perl -I $plugin_path/../lib  $exec "
. " -outfile " . $outfile 
. " -infile " . $infile 
. " -options " . join(' ', @options )
. " -debug";
system( $cmd );

#print "\$exp = ".root->print_perl_var_def($value ).";\n";