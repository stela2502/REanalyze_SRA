#! /usr/bin/perl -w

=head1 LICENCE

  Copyright (C) 2016-12-07 Stefan Lang

  This program is free software; you can redistribute it 
  and/or modify it under the terms of the GNU General Public License 
  as published by the Free Software Foundation; 
  either version 3 of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful, 
  but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
  See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License 
  along with this program; if not, see <http://www.gnu.org/licenses/>.

=head1  SYNOPSIS

    quantify_single_cell_NGS.pl
       -bams     :a list of bam files
       -gtf      :the gtf file to use
       -outfile  :the final StefansExpressionSet file
       -tmp_path :the temp path (default tmp in the outfiles's path)
       -help     :print this help
       -debug    :verbose output
       
       ## options for the Rsubread::featureCounts call
       
       -gtf_feature_type 
                :the feature to quantify (default = exon)
       -gtf_attr_type    
                :the attributeType (default = gene_id)
       -paired  :is the data paried
       -n       :how many processes to read the data (for the R process)
   
=head1 DESCRIPTION

  Having more than 600 samples in a NGS data set broke the Rsubread and therefore this tool got produced. 
  It will read any list of bam files in chunks of 500 samples per set and use a separate R instance each time.

  To get further help use 'quantify_single_cell_NGS.pl -help' at the comman line.

=cut

use Getopt::Long;
use Pod::Usage;

use stefans_libs::root;
use strict;
use warnings;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';

my ( $help, $debug, $database, @bams, $gtf, $tmp_path, $gtf_feature_type,
	$gtf_attr_type, $paired, $n, @slurm, $outfile );

Getopt::Long::GetOptions(
	"-bams=s{,}"          => \@bams,
	"-gtf=s"              => \$gtf,
	"-gtf_feature_type=s" => \$gtf_feature_type,
	"-gtf_attr_type=s"    => \$gtf_attr_type,
	"-paired"             => \$paired,
	"-n=s"                => \$n,
	"-outfile=s"          => \$outfile,
	"-tmp_path=s"         => \$tmp_path,
	"-slurm=s{,}"          => \@slurm,

	"-help"  => \$help,
	"-debug" => \$debug
);

my $warn  = '';
my $error = '';

unless ( -f $bams[0] ) {
	$error .= "the cmd line switch -bams is undefined!\n";
}
unless ( -f $gtf ) {
	$error .= "the cmd line switch -gtf is undefined!\n";
}
unless ( defined $gtf_feature_type ) {
	$gtf_feature_type = 'exon';
}
unless ( defined $gtf_attr_type ) {
	$gtf_attr_type = 'gene_id';
}

# paired - no checks necessary
unless ( defined $n ) {
	$n = 2;
}
unless ( defined $tmp_path ) {
	$tmp_path = 'tmp';
}
unless ( defined $outfile ) {
	$error .= "the cmd line switch -outfile is undefined!\n";
}

map {
	$warn .= "file $_ must not be given as relative path!\n"
	  if ( $_ =~ m/^\./ )
} @bams;

if ($help) {
	print helpString();
	exit;
}

if ( $error =~ m/\w/ ) {
	helpString($error);
	exit;
}

sub helpString {
	my $errorMessage = shift;
	$errorMessage = ' ' unless ( defined $errorMessage );
	print "$errorMessage.\n";
	pod2usage( q(-verbose) => 1 );
}

my ($task_description);

$task_description .= 'perl ' . $plugin_path . '/quantify_single_cell_NGS.pl';
$task_description .= ' -bams "' . join( '" "', @bams ) . '"'
  if ( defined $bams[0] );
$task_description .= " -gtf '$gtf'" if ( defined $gtf );
$task_description .= " -gtf_feature_type '$gtf_feature_type'"
  if ( defined $gtf_feature_type );
$task_description .= " -gtf_attr_type '$gtf_attr_type'"
  if ( defined $gtf_attr_type );
$task_description .= " -paired " if ($paired);
$task_description .= " -n '$n'"  if ( defined $n );
$task_description .= " -tmp_path '$tmp_path'" unless ( $tmp_path eq "tmp" );
$task_description .= " -outfile '$outfile'" if ( defined $outfile );

my $fm = root->filemap($outfile);

unless ( -d $fm->{'path'} ) {
	mkdir( $fm->{'path'} );
}

if ( $tmp_path eq "tmp" ) {
	$tmp_path = "$fm->{'path'}/tmp/";
}
unless ( -d $tmp_path ) {
	mkdir($tmp_path);
}

open( LOG, ">$outfile.log" ) or die $!;
print LOG $task_description . "\n";
close(LOG);

## Do whatever you want!
my ($max);
my $a = 1;
if ($paired) {
	$paired = "T";
}
else {
	$paired = "F";
}
my $slurm;
if (@slurm) {
	use stefans_libs::SLURM;
	for ( my $i = 0 ; $i < @slurm ; $i += 2 ) {
		$slurm->{ $slurm[$i] } = $slurm[ $i + 1 ];
	}
	$slurm->{'n'} = $n;
	$slurm->{'N'} = 1 unless( $slurm->{'N'});
	$slurm->{'debug'} = $debug;
	$slurm = stefans_libs::SLURM->new($slurm);
}

for ( my $i = 0 ; $i < @bams ; $i += 500 ) {
	open( OUT, ">$tmp_path/bams.$a.txt" )
	  or die "I could not create the bam file '$tmp_path/bams.$a.txt'\n$!\n";
	$max = $i + 499;
	$max = $#bams if ( $max > $#bams );
	print OUT join(
		"\n",
		map {
			if   ( $_ =~ m/^\./ ) { "../$_" }
			else                  { $_ }
		} @bams[ $i .. $max ]
	);
	close(OUT);
	open( SCR, ">$tmp_path/quantify.$a.R" )
	  or die "I could not create the script file '$tmp_path/script.$a.R'\n$!\n";
	print SCR join(
		"\n",
		"library( StefansExpressionSet)",
		"library(Rsubread)",
"dat$a <- read.bams( '$tmp_path/bams.$a.txt', '$gtf', nthreads =  $n, GTF.featureType = '$gtf_feature_type',
					GTF.attrType = '$gtf_attr_type',isPairedEnd = $paired )",
		"save(dat$a, file='$tmp_path/Robject$a.RData')",
		"system('touch $tmp_path/Robject$a.RData.finished')"
	);
	close(SCR);
	if ( !-f "$tmp_path/Robject$a.RData" ) {
		if (@slurm) {
				$slurm->run( "R CMD BATCH $tmp_path/quantify.$a.R", root->filemap("$tmp_path/Robject$a.RData") );
		}else{
			print "creating Robject$a.RData\n";
			system("R CMD BATCH $tmp_path/quantify.$a.R") unless ($debug);
		}
	}
	else {
		print "outfile $tmp_path/Robject$a.RData does exist\n";
	}
	$a++;
}
$a--;

open( SCR, ">$tmp_path/sumup.R" )
  or die "I could not create the script file '$tmp_path/sumup.R'\n$!\n";
my @files = map { "$tmp_path/Robject$_.RData" } 1 .. $a;
print SCR join(
	"\n",
	(map{ "if ( ! file.exists( '$tmp_path/Robject$_.RData.finished' ) ) { Sys.sleep(10) }" } 1..$a),
	"load('$tmp_path/Robject1.RData')\n",
	"dat <- dat1",
	(
		map {
			my $id = $_;
			join( "\n",
				"load('$tmp_path/Robject$id.RData')",
				"dat\$counts <- cbind(dat\$counts, dat$id\$counts )",
				"dat\$stat <- cbind(dat\$stat, dat$id\$stat[,-1] )" )
		} 2 .. $a
	),
	"save(dat, file='$outfile')",
);
close(SCR);

system("R CMD BATCH $tmp_path/sumup.R") unless ($debug);

print
"The file '$outfile' should now contain a R table object that can be further processed in any R script\n";

