#! /usr/bin/perl -w

=head1 LICENCE

  Copyright (C) 2016-06-17 Stefan Lang

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

    ChIP_analysis_script.pl
       -files     :The MACS2 result files containing the summit information
       -samples   :The/any sample description file you have (tab separated)
       -outfile   :the R outfile
       -options   :format: key_1 value_1 key_2 value_2 ... key_n value_n
          
          RobjName  :The R object name - make it phony (ddefaults to outfile name)
          region    :the max length of a region of summits (default = 50bp)

       -help           :print this help
       -debug          :verbose output
   
=head1 DESCRIPTION

  Create a ChIP analysis R script based on the ChIPseeker R package.

  To get further help use 'ChIP_analysis_script.pl -help' at the comman line.

=cut

use Getopt::Long;
use Pod::Usage;

use Cwd;

use stefans_libs::flexible_data_structures::data_table;
use stefans_libs::SampleTable;

use strict;
use warnings;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';

my ( $help, $debug, $database, @files, $samples, $outfile, $options, @options );

Getopt::Long::GetOptions(
	"-files=s{,}"   => \@files,
	"-samples=s"    => \$samples,
	"-outfile=s"    => \$outfile,
	"-options=s{,}" => \@options,

	"-help"  => \$help,
	"-debug" => \$debug
);

my $warn  = '';
my $error = '';

unless ( defined $files[0] ) {
	$error .= "the cmd line switch -files is undefined!\n";
}
unless ( defined $samples ) {
	$error .= "the cmd line switch -samples is undefined!\n";
}
unless ( defined $outfile ) {
	$error .= "the cmd line switch -outfile is undefined!\n";
}
unless ( defined $options[0] ) {
	$error .= "the cmd line switch -options is undefined!\n";
}

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

### initialize default options:

#$options->{'n'} ||= 10;

###

my ($task_description);

$task_description .= 'perl ' . $plugin_path . '/ChIP_analysis_script.pl';
$task_description .= ' -files "' . join( '" "', @files ) . '"'
  if ( defined $files[0] );
$task_description .= " -samples '$samples'" if ( defined $samples );
$task_description .= " -outfile '$outfile'" if ( defined $outfile );
$task_description .= ' -options "' . join( '" "', @options ) . '"'
  if ( defined $options[0] );

my $fm = root->filemap($outfile);
unless ( -d $fm->{'path'} ) {

	system("mkdir -p $fm->{'path'}");
}

for ( my $i = 0 ; $i < @options ; $i += 2 ) {
	$options[ $i + 1 ] =~ s/\n/ /g;
	$options->{ $options[$i] } = $options[ $i + 1 ];
}
###### default options ########
#$options->{'something'} ||= 'default value';
$options->{'RobjName'} ||= $fm->{'filename_core'};
$options->{'region'} ||= 50;
##############################

open( LOG, ">$outfile.log" ) or die $!;
print LOG $task_description . "\n";
close(LOG);

## Do whatever you want!

open ( OUT, ">$fm->{'path'}/Load_SLURM_ChIP_analysis.sh") or die $!;
print OUT "module load GCC/4.9.3-binutils-2.25  OpenMPI/1.8.8 R/3.2.3\n";
close ( OUT );
system ( "bash $fm->{'path'}/Load_SLURM_ChIP_analysis.sh ") unless ( $debug );



## prepare the Samples.xls file

my $data_table = data_table->new( { 'filename' => $samples } );

my $OBJ = stefans_libs::SampleTable->new(
	{ 'data_table' => $data_table, 'filenames' => \@files } );
my $ret;

( $data_table, $ret ) = $OBJ->fix_the_table($fm);

$data_table->write_file("$fm->{'path'}/Samples.xls");

## now the Samples.xls file is done - get the data into the R object

my $Rfile = "library(data.table)\n";
$Rfile .= "read_summit <- function ( file ) {\n\t"
  . "t <- read.delim( file=file, header=F )\n\t"
  . "ret <- list()\n\t"
  . "names<- unique(as.vector(t[,1]))\n\t"
  . "ret <- lapply( names, function ( x ) { as.vector(t[which(t[,1] == x ),2]) } )\n\t"
  . "names(ret) <- names\n\t"
  . "ret\n}\n\n"
  . "samples <- read.delim( file='Samples.xls', header=T )\n"
  . "all_dat <- lapply( as.vector(samples[,'filename'] ), read_summit )\n"
  . "names(all_dat) <- as.vector(samples[,'filename'] )\n"
  . "n <- names(all_dat[[1]])\n"
  
  ;


$Rfile .="
all_chr <- list()
for ( x in all_dat ) {
	n <- names(x)
	for ( i in 1:length(n) ) { 
		if (  length( (id = match( n[i], names(all_chr) ) ) ) == 0 || is.na(id) ) {
			all_chr[[length(all_chr)+1]] <- x[[i]]
			names(all_chr)[length(all_chr)] = n[i]
		}else{
			all_chr[[id]]<- c( all_chr[[id]], x[[i]] )
		}
	}
}

## and now get the regions of interest based on a max region length

mdist <- $options->{'region'}
n <- names( all_chr )
if ( n[1] != 'chr1' ) {
	n<- names(all_chr) <- paste('chr',n,sep='')
}
bed <- NULL
all_beds <- lapply(  1:length(all_chr), function ( i ) { 
	bed = NULL
	start = 0
	last = 5000
	for ( v in data.table(x=all_chr[[i]],key='x')\$x ) {
		if ( v - start > mdist ) {
			if ( last - start < 500 ) {
				bed[nrow(bed),c(2,3)] = c( start -50, last +50)
			}
			bed <- rbind ( bed, c( n[i], v, v+mdist, 1 ))
			start <- v
			last <- v
		}else {
			last <- v
			bed[nrow(bed),4] <- as.numeric(bed[nrow(bed),4]) +1
		}
	}
	bed
} )

for ( i in  1:length(all_chr) ) {
	bed <- rbind ( bed, all_beds[[i]] )
}

bed <- bed[ - which( bed[,4] == '1'), ]

write.table( bed, file='PeakRegions.bedGraph', sep='\t', quote=F, col.names=F, row.names=F )

";

open ( OUT ,">$fm->{'path'}/ChIP_data_2_bed_file.R" ) or die $!;
print OUT $Rfile;
close ( OUT );

chdir ( $fm->{'path'} );
warn "please run the R script '$fm->{'path'}/ChIP_data_2_bed_file.R' to create the 'PeakRegions.bed' file (SLOW)\n";
system( "R CMD BATCH ChIP_data_2_bed_file.R") if ( $debug );

## and now create the real outfile

open ( OUT ,">$outfile" ) or die "I could not create the main outfile $outfile\n$!\n";
print OUT "#This is not implemented at the moment\n";
print "outfile does not contain useful data!\n";
close ( OUT );