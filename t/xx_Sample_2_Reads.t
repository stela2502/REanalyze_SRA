#! /usr/bin/perl
use strict;
use warnings;
use stefans_libs::root;
use Test::More tests => 3;
use stefans_libs::flexible_data_structures::data_table;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $value, @values, $exp, );

my $exec = $plugin_path . "/../bin/Sample_2_Reads.pl";
ok( -f $exec, 'the script has been found' );
my $outpath = "$plugin_path/data/output/Sample_2_Reads";
if ( -d $outpath ) {
	system("rm -Rf $outpath");
}

open( IN, "cd $plugin_path/data && ls */*/*/*/*/*/*/*/*/*/*.sra|" )
  or die "$!\n";
@values = map { chomp; $_ } <IN>;
close(IN);

#print "\$exp = ".root->print_perl_var_def(\@values ).";\n";
$exp = [
'ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByExp/sra/DRX/DRX007/DRX007772/DRR008644/DRR008644.sra',
'ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByExp/sra/DRX/DRX007/DRX007772/DRR008644/DRR008645.sra',
'ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByExp/sra/DRX/DRX007/DRX007775/DRR008647/DRR008647.sra'
];

is_deeply( \@values, $exp, "the input files" );

my $cmd =
    "cd $plugin_path/data && ls  */*/*/*/*/*/*/*/*/*/*.sra | perl $exec "
  . " -options opath $outpath ipath $plugin_path/data/Sample_2_Reads/HISAT2_OUT/"
 # . " -debug  |";
   . " |";

my $start = time;
open( IN, $cmd );
my $duration = time - $start;
print "Execution time: $duration s\n";
@values = map { chomp; $_ } <IN>;
close(IN);

#print "\$exp = " . root->print_perl_var_def( \@values ) . ";\n";

$exp = [
	'runCommand.pl -cmd '
	  . "'samtools merge  - $plugin_path/data/Sample_2_Reads/HISAT2_OUT/DRR008644*.sorted.bam "
	  . "$plugin_path/data/Sample_2_Reads/HISAT2_OUT/DRR008644*.sorted.bam | samtools sort -@ 5 -T \$SNIC_TMP/DRX007772.sorted.bam - > $outpath/DRX007772.sorted.bam\'"
	  . " -options N 1 n 5 A \'lu2016-2-7\' t \'02:00:00\'"
	  . " -outfile $outpath/DRX007772.sorted.bam -I_have_loaded_all_modules",
	"ln -s $plugin_path/data/Sample_2_Reads/HISAT2_OUT/DRR008647*.sorted.bam"
	  . " $outpath/DRX007775.sorted.bam"
];
is_deeply( \@values, $exp, "the resulting script" );

#print "\$exp = ".root->print_perl_var_def($value ).";\n";
