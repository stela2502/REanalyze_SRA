#! /usr/bin/perl -w

=head1 LICENCE

  Copyright (C) 2016-12-05 Stefan Lang

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

    download_not_existing.pl
       -wget_script   :the wget script to use
                       each line in the script has to look like that:
                       wget -O 'outfile' 'web link'
                       
       -outpath       :the outpath
       -n             :number of processors (default 1)


       -help           :print this help
       -debug          :verbose output
   
=head1 DESCRIPTION

  use a wget script and download the files mentioned in the script if they are not already downloded.

  To get further help use 'download_not_existing.pl -help' at the comman line.

=cut

use Getopt::Long;
use Pod::Usage;
use Parallel::ForkManager;

use strict;
use warnings;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';

my ( $help, $debug, $database, $wget_script, $n, $outpath );

Getopt::Long::GetOptions(
	"-wget_script=s" => \$wget_script,
	"-outpath=s"     => \$outpath,
	"-n=s"           => \$n,

	"-help"  => \$help,
	"-debug" => \$debug
);

my $warn  = '';
my $error = '';

unless ( defined $wget_script ) {
	$error .= "the cmd line switch -wget_script is undefined!\n";
}
unless ( defined $outpath ) {
	$error .= "the cmd line switch -outpath is undefined!\n";
}
unless ( $n ) { $n = 1;}

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

$task_description .= 'perl ' . $plugin_path . '/download_not_existing.pl';
$task_description .= " -wget_script '$wget_script'" if ( defined $wget_script );
$task_description .= " -outpath '$outpath'" if ( defined $outpath );
$task_description .= " -n $n";

mkdir($outpath) unless ( -d $outpath );
open( LOG, ">$outpath/" . $$ . "_download_not_existing.pl.log" ) or die $!;
print LOG $task_description . "\n";
close(LOG);

## Do whatever you want!

open( IN, "<$wget_script" ) or die "$!\n";
my ( @line, @data, $hash );
while (<IN>) {
	if ( $_ =~ m/^\s*wget/ ) {
		chomp($_);
		@line = split( /\s+/, $_ );
		$line[2] =~ s/'//g;
		my $ofile = $outpath . "/$line[2]";
		unless ( -f  $ofile ) {
			$hash = { file => $ofile, cmd => $_ };
			$hash->{'cmd'} =~ s!$line[2]!$ofile!;
			push( @data, $hash );
		}
	}
}
close(IN);

if ( $n > 1 ) {
	my $pm = Parallel::ForkManager->new($n);

  FILES:
	foreach my $info (@data) {
		my $pid = $pm->start and next FILES;
		print $info->{'cmd'} . "\n";
		eval { exec( $info->{'cmd'} ) unless ($debug); };
		$pm->finish;    # Terminates the child process but exec should do that already...
	}

	$pm->wait_all_children;

}
else {
	foreach my $info (@data) {
		print $info->{'cmd'} . "\n";
		eval { system( $info->{'cmd'} ) unless ($debug); };
	}
}

