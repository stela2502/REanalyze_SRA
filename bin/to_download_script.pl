#! /usr/bin/perl -w

=head1 LICENCE

  Copyright (C) 2017-01-18 Stefan Lang

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

    to_download_script.pl
       -infiles     :<please add some info!> you can specify more entries to that
       -outfile       :<please add some info!>


       -help           :print this help
       -debug          :verbose output
   
=head1 DESCRIPTION

  get SUMMARY tables and merge the download scripts

  To get further help use 'to_download_script.pl -help' at the comman line.

=cut

use Getopt::Long;
use Pod::Usage;

use strict;
use warnings;

#use stefans_libs::root;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';


my ( $help, $debug, $database, @infiles, $outfile);

Getopt::Long::GetOptions(
       "-infiles=s{,}"    => \@infiles,
	 "-outfile=s"    => \$outfile,

	 "-help"             => \$help,
	 "-debug"            => \$debug
);

my $warn = '';
my $error = '';

unless ( defined $infiles[0]) {
	$error .= "the cmd line switch -infiles is undefined!\n";
}
unless ( defined $outfile) {
	$error .= "the cmd line switch -outfile is undefined!\n";
}


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

$task_description .= 'perl '.$plugin_path .'/to_download_script.pl';
$task_description .= ' -infiles "'.join( '" "', @infiles ).'"' if ( defined $infiles[0]);
$task_description .= " -outfile '$outfile'" if (defined $outfile);


#my $fm = root->filemap($outfile);
#unless ( -d $fm->{'path'} ) {
#	mkdir( $fm->{'path'} );
#}
open ( LOG , ">$outfile.log") or die $!;
print LOG $task_description."\n";
close ( LOG );

my @line;
my @outfile;

open (OUT, ">$outfile" ) or die "I could not open the outfile '$outfile'\n$!\n";
foreach my $ifile ( @infiles ){
	open ( IN, "<$ifile" ) or die "I could not open the infile '$ifile'\n\!\n";
	while ( <IN> ) {
		chomp();
		@line = split( /\t/, $_ );
		unless ($line[-1] eq "Download") {
			@outfile = split(/["'\s]+/, $line[-1]);
			$line[-1] =~ s/\-O/-t 2 -O/ unless ( $line[-1] =~ m/-t 2/ );
			print OUT "if ! [ -f '$outfile[2]' ]; then\n\t$line[-1]\nfi\n";
		} 
	}
	## get rid of the no data files (failed download)
	print  OUT " find . -name '*.sra' -size 0 -print0 | xargs -0 rm\n";
	close ( IN );
}
close ( OUT );


