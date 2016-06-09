#! /usr/bin/perl
use strict;
use warnings;

use Test::More tests => 11;

use stefans_libs::flexible_data_structures::data_table;

use FindBin;
my $plugin_path = $FindBin::Bin;

my ( $cmd, $value, @values, $tmp, $exp);

$cmd = "perl -I $plugin_path/../lib $plugin_path/../bin/subset_summary_table.pl -summary_file $plugin_path/data/output/SRP001371_SUMMARY.xls "
	. "-options match 'RNA CD34' -outfile $plugin_path/data/output/data_and/wget";
print $cmd."\n";
if ( -d "$plugin_path/data/output/data_and/" ) {
	system( "rm -Rf $plugin_path/data/output/data_and/" );
}
system( $cmd);

ok ( -d "$plugin_path/data/output/data_and/", "outpath created" );
foreach ( 'wget.sh', 'wget.log', 'Samples.xls' ) {
	ok ( -f "$plugin_path/data/output/data_and/$_", "outfile $_ created");
}

my $data_table = data_table->new( { filename=> "$plugin_path/data/output/data_and/Samples.xls" } );

ok( $data_table->Rows == 17, "16 samples selected (".$data_table->Rows.")" );

$value = $data_table->GetAsHash( 'SRR', 'SAMPLE-DESCRIPTION'  );

#print "\$exp = ".root->print_perl_var_def($value ).";\n";

$exp = {
  'SRR453397' => 'flow sorted CD34+ cells from cord blood',
  'SRR453395' => 'flow sorted CD34+ cells from cord blood',
  'SRR453405' => 'flow sorted CD34+ cells from cord blood',
  'SRR453398' => 'flow sorted CD34+ cells from cord blood',
  'SRR453401' => 'flow sorted CD34+ cells from cord blood',
  'SRR453394' => 'flow sorted CD34+ cells from cord blood',
  'SRR453392' => 'flow sorted CD34+ cells from cord blood',
  'SRR453402' => 'flow sorted CD34+ cells from cord blood',
  'SRR453391' => 'flow sorted CD34+ cells from cord blood',
  'SRR453399' => 'flow sorted CD34+ cells from cord blood',
  'SRR453404' => 'flow sorted CD34+ cells from cord blood',
  'SRR453403' => 'flow sorted CD34+ cells from cord blood',
  'SRR453407' => 'flow sorted CD34+ cells from cord blood',
  'SRR453396' => 'flow sorted CD34+ cells from cord blood',
  'SRR453393' => 'flow sorted CD34+ cells from cord blood',
  'SRR453406' => 'flow sorted CD34+ cells from cord blood',
  'SRR453400' => 'flow sorted CD34+ cells from cord blood'
};

is_deeply( $value , $exp, "The right samples have been selected\n" );

$cmd = "perl -I $plugin_path/../lib $plugin_path/../bin/subset_summary_table.pl -summary_file $plugin_path/data/output/SRP001371_SUMMARY.xls "
	. "-options match 'RNA CD34' match_any 1 -outfile $plugin_path/data/output/data_or/wget";
	
if ( -d "$plugin_path/data/output/data_or/" ) {
	system( "rm -Rf $plugin_path/data/output/data_or/" );
}
system( $cmd);

ok ( -d "$plugin_path/data/output/data_or/", "outpath created" );
foreach ( 'wget.sh', 'wget.log', 'Samples.xls' ) {
	ok ( -f "$plugin_path/data/output/data_or/$_", "outfile $_ created");
}

$data_table = data_table->new( { filename=> "$plugin_path/data/output/data_or/Samples.xls" } );

ok( $data_table->Rows == 227, "227 samples selected (any got ".$data_table->Rows." samples)" );

