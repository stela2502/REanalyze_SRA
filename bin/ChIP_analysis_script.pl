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
       -files     :<please add some info!> you can specify more entries to that
       -samples       :<please add some info!>
       -outfile       :<please add some info!>
       -options     :<please add some info!> you can specify more entries to that
                         format: key_1 value_1 key_2 value_2 ... key_n value_n


       -help           :print this help
       -debug          :verbose output
   
=head1 DESCRIPTION

  Create a ChIP analysis R script based on the ChIPseeker R package.

  To get further help use 'ChIP_analysis_script.pl -help' at the comman line.

=cut

use Getopt::Long;
use Pod::Usage;

use strict;
use warnings;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';


my ( $help, $debug, $database, @files, $samples, $outfile, $options, @options);

Getopt::Long::GetOptions(
       "-files=s{,}"    => \@files,
	 "-samples=s"    => \$samples,
	 "-outfile=s"    => \$outfile,
       "-options=s{,}"    => \@options,

	 "-help"             => \$help,
	 "-debug"            => \$debug
);

my $warn = '';
my $error = '';

unless ( defined $files[0]) {
	$error .= "the cmd line switch -files is undefined!\n";
}
unless ( defined $samples) {
	$error .= "the cmd line switch -samples is undefined!\n";
}
unless ( defined $outfile) {
	$error .= "the cmd line switch -outfile is undefined!\n";
}
unless ( defined $options[0]) {
	$error .= "the cmd line switch -options is undefined!\n";
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

### initialize default options:

#$options->{'n'} ||= 10;

###


my ( $task_description);

$task_description .= 'perl '.$plugin_path .'/ChIP_analysis_script.pl';
$task_description .= ' -files "'.join( '" "', @files ).'"' if ( defined $files[0]);
$task_description .= " -samples '$samples'" if (defined $samples);
$task_description .= " -outfile '$outfile'" if (defined $outfile);
$task_description .= ' -options "'.join( '" "', @options ).'"' if ( defined $options[0]);


for ( my $i = 0 ; $i < @options ; $i += 2 ) {
	$options[ $i + 1 ] =~ s/\n/ /g;
	$options->{ $options[$i] } = $options[ $i + 1 ];
}
###### default options ########
#$options->{'something'} ||= 'default value';
##############################
open ( LOG , ">$outfile.log") or die $!;
print LOG $task_description."\n";
close ( LOG );


## Do whatever you want!

## prepare the Samples.xls file
my $fm = root->filemap( $outfile );
my $data_table = data_table->new( { 'filename' => $samples } );

my $OBJ = stefans_libs::SampleTable->new({ 'data_table' => $data_table, 'filenames' => \@files} );
my $ret;

( $data_table, $ret ) = $OBJ -> fix_the_table ( $fm );

$data_table->write_file("$fm->{'path'}/Samples.xls");

## now the Samples.xls file is done - get the data into the R object


