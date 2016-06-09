#! /usr/bin/perl
use strict;
use warnings;
use Test::More tests => 2;
BEGIN { use_ok 'REanalyze_SRA' }

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $value, @values, $exp );
my $OBJ = REanalyze_SRA -> new({'debug' => 1});
is_deeply ( ref($OBJ) , 'REanalyze_SRA', 'simple test of function REanalyze_SRA -> new() ');

#print "\$exp = ".root->print_perl_var_def($value ).";\n";


