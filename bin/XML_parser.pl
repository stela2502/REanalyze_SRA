#! /usr/bin/perl -w

=head1 LICENCE

  Copyright (C) 2017-02-16 Stefan Lang

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

    XML_parser.pl

        -infile    :the infile for the conversion
        -outfile   :the outfile base for the tables
        
        -options 
   		NCBI_ID 'some SRA ID'  
   		      :The information for this ID id is downloaded 
   		       from NCBI and stored in the input file
   		ignore 'table1 table2 table3'
   			  :is ignoring these tables 'taxon Base'
   		useOnly 'EXPERIMENT_PACKAGE_SET EXPERIMENT_PACKAGE EXPERIMENT IDENTIFIERS TITLE'
   		      :dropps all other XML entries but the mentioned
   		addMultiple 'colname1 colname2 colname3'
   			  :there are multiple coumns of this type allowed per line
   		inspect 'string'
   			  :search for the 'string' in all columns and show the hash

       -help           :print this help
       -debug          :verbose output

    Special usage: If you provide no infile and only an outfile this string will be used as NCBI_ID.
    The data for this ID will be downloaded and processed.   

=head1 DESCRIPTION

  Download sample information from NCBI SRA and GEO archives.

  To get further help use 'XML_parser.pl -help' at the comman line.

=cut

use Getopt::Long;
use Pod::Usage;

use strict;
use warnings;

use stefans_libs::XML_parser;
use XML::Simple;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';


my ( $help, $debug, $database, $infile, $outfile, $options, @options);

Getopt::Long::GetOptions(
	 "-infile=s"    => \$infile,
	 "-outfile=s"    => \$outfile,
       "-options=s{,}"    => \@options,

	 "-help"             => \$help,
	 "-debug"            => \$debug
);

my $warn = '';
my $error = '';

unless ( defined $infile) {
	$warn .= "the cmd line switch -infile is undefined!\n";
}
unless ( defined $outfile) {
	$error .= "the cmd line switch -outfile is undefined!\n";
}
unless ( defined $options[0]) {
	$warn .= "the cmd line switch -options is undefined!\n";
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

$task_description .= 'perl '.$plugin_path .'/XML_parser.pl';
$task_description .= " -infile '$infile'" if (defined $infile);
$task_description .= " -outfile '$outfile'" if (defined $outfile);
$task_description .= ' -options "'.join( '" "', @options ).'"' if ( defined $options[0]);


for ( my $i = 0 ; $i < @options ; $i += 2 ) {
	$options[ $i + 1 ] =~ s/\n/ /g;
	$options->{ $options[$i] } = $options[ $i + 1 ];
}
###### default options ########
#$options->{'something'} ||= 'default value';
##############################

if ( ! $infile and ! $options->{'NCBI_ID'} ) {
	$infile = "$outfile.xml";
	$options->{'NCBI_ID'} = $outfile;
}

my $fm = root->filemap( $outfile );
unless ( -d $fm->{'path'} ) {
	mkdir( $fm->{'path'});
}

open ( LOG , ">$outfile.log") or die $!;
print LOG $task_description."\n";
close ( LOG );


## Do whatever you want!

my $xml = XMLin($infile);

print XMLout( $xml );

my $IDS = stefans_libs::XML_parser->new( { debug => $debug } );

$IDS->options( $options );

$debug = 0;
my $main_id = 1;

print scalar( $IDS ->parse_NCBI ( $xml ) )
    . " entries analyzed.\n"
    . "Is the resulting table close to the required / wanted output?\n";

## now I expect to have multiple entries with an .<integer> ending. These should be sample specific and that is a problem!

$IDS->write_files( $outfile, 1 );
$IDS->write_summary_file ($outfile."_SUMMARY.xls" );

print "Done!\n";

