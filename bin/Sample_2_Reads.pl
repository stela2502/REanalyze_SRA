#! /usr/bin/perl -w

=head1 LICENCE

  Copyright (C) 2017-03-28 Stefan Lang

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

=head1 CREATED BY
   
   binCreate.pl from git@github.com:stela2502/Stefans_Lib_Esentials.git commit 379745c9cb3ad2ab4f4e5a01908b35e7dc9536df
   

=head1  SYNOPSIS

    Sample_2_Reads.pl


       -help           :print this help
       -debug          :verbose output
   
=head1 DESCRIPTION

  A filter to link / merge bam files fro a NCBI sample structure into sample specific bam files. Works as a filter on the original sra structure.

  To get further help use 'Sample_2_Reads.pl -help' at the comman line.

=cut

use Getopt::Long;
use Pod::Usage;

use strict;
use warnings;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';


my ( $help, $debug, $database);

Getopt::Long::GetOptions(

	 "-help"             => \$help,
	 "-debug"            => \$debug
);

my $warn = '';
my $error = '';



if ( $help ){
	print helpString( ) ;
	exit;
}

if ( $error =~ m/\w/ ){
	helpString($error ) ;
	exit;
}

sub helpString {
	my $errorMessage = shift;
	$errorMessage = ' ' unless ( defined $errorMessage); 
	print "$errorMessage.\n";
	pod2usage(q(-verbose) => 1);
}



my ( $task_description);

$task_description .= 'perl '.$plugin_path .'/Sample_2_Reads.pl';




## Do whatever you want!

unless ( -d "HISAT2_OUT") {
	die "You need to run this filter "
	 ."in a data folder where you have the HISAT2_OUT folder containing all hisat2 mapped bam files.\n"
}

my @t;
my $h;
while (<>) {
    chomp;
    @t = split( "/", $_ );
    $h->{ $t[8] } ||= [];
    push(@{$h->{ $t[8] } }, $t[9] );
}
foreach ( sort keys %$h ) {
	if ( @{ $h->{$_} } == 1 ) {
		print "ln -s HISAT2_OUT/@{ $h->{$_} }[0]*picard_deduplicated.bam "
		  ."HISAT2_OUT_Per_Experiment/$_.sorted_picard_deduplicated.bam\n" if (-f "HISAT2_OUT/@{ $h->{$_} }[0]*picard_deduplicated.bam");
	}
	else {
		 print  "runCommand.pl -cmd '".
     "samtools merge  - HISAT2_OUT/".join("*picard_deduplicated.bam HISAT2_OUT/", @{ $h->{$_} })."*picard_deduplicated.bam | samtools sort -\@ 5 -T \$SNIC_TMP/$_.bam - > HISAT2_OUT_Per_Experiment/$_.picard_deduplicated.bam"
     ."' -options N 1 n 5 A 'lu2016-2-7' t '02:00:00' -outfile HISAT2_OUT_Per_Experiment/$_.picard_deduplicated.bam -I_have_loaded_all_modules\n";

	}
}
