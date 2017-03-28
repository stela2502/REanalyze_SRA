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

    to_download_column.pl
       -infile       :<please add some info!>
       -outfile       :<please add some info!>
       -column       :<please add some info!>
       -experiment       :<please add some info!>


       -help           :print this help
       -debug          :verbose output
   
=head1 DESCRIPTION

  Use a table file and create a download column from any of the columns.

  To get further help use 'to_download_column.pl -help' at the comman line.

=cut

use Getopt::Long;
use Pod::Usage;

use strict;
use warnings;

use stefans_libs::XML_parser;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';


my ( $help, $debug, $database, $infile, $outfile, $column, $experiment);

Getopt::Long::GetOptions(
	 "-infile=s"    => \$infile,
	 "-outfile=s"    => \$outfile,
	 "-column=s"    => \$column,
       "-experiment"    => \$experiment,

	 "-help"             => \$help,
	 "-debug"            => \$debug
);

my $warn = '';
my $error = '';

unless ( defined $infile) {
	$error .= "the cmd line switch -infile is undefined!\n";
}
unless ( defined $outfile) {
	$error .= "the cmd line switch -outfile is undefined!\n";
}
unless ( defined $column) {
	$error .= "the cmd line switch -column is undefined!\n";
}
# experiment - no checks necessary


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

$task_description .= 'perl '.$plugin_path .'/to_download_column.pl';
$task_description .= " -infile '$infile'" if (defined $infile);
$task_description .= " -outfile '$outfile'" if (defined $outfile);
$task_description .= " -column '$column'" if (defined $column);
$task_description .= " -experiment " if ( $experiment);



use stefans_libs::Version;
my $V = stefans_libs::Version->new();
my $fm = root->filemap( $outfile );
mkdir( $fm->{'path'}) unless ( -d $fm->{'path'} );

open ( LOG , ">$outfile.log") or die $!;
print LOG $task_description."\n";
close ( LOG );


## Do whatever you want!

my $helper = stefans_libs::XML_parser->new();
my $data = data_table->new();
$data ->read_file($infile);

if ( $experiment ) {
	$data = $helper->create_experiment_download_column( $data, $column, $column);
}else {
	$data = $helper->create_download_column( $data, $column, $column);
}

$data->write_file($outfile);

