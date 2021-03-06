package stefans_libs::XML_parser;

#  Copyright (C) 2016-05-18 Stefan Lang

#  This program is free software; you can redistribute it
#  and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation;
#  either version 3 of the License, or (at your option) any later version.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#  See the GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program; if not, see <http://www.gnu.org/licenses/>.

use Digest::MD5 qw(md5_hex);
use stefans_libs::flexible_data_structures::data_table;
use Encode;
use strict;
use Data::Dumper;
use stefans_libs::XML_parser::TableInformation;

=head 2 

the Package IDS should help in deparsing a xml document into tables.
The basic idear is to get as view tables as possible. 
Therefore the real table structure is most likely not recovered.

=cut

sub new {
	my ( $class, $hash ) = @_;
	my ($self);

	$self = {
		'tables_lastID'       => {},
		'problematic_columns' => {},
		'values'              => [],
		'tables'              => {},
		'deparse_level'       => 2,
		'drop_first'          => 2,
		'debug'               => 0,
		'done'                => {},
	};

	bless $self, $class if ( $class eq "stefans_libs::XML_parser" );
	foreach ( keys %$hash ) {
		$self->{$_} = $hash->{$_};
	}
	return $self;
}

=head2

register_column add the value to the column if it is not already taken.
It also checks whether the last row has been 'filled' if not it flicks back one entry!

=cut

sub table_and_colname {
	my ( $self, $column, $entryID ) = @_;
	my @tmp = split( "-", $column );
	my $table_name;

	for ( my $i = 0 ; $i < $self->{'drop_first'} ; $i++ ) {
		shift(@tmp);
	}
	$table_name = join( "-",
		@tmp[ 0 .. ( $self->{'deparse_level'} - $self->{'drop_first'} ) ] );

	for (
		my $i = 0 ;
		$i < ( $self->{'deparse_level'} - $self->{'drop_first'} ) ;
		$i++
	  )
	{
		shift(@tmp);
	}
	if ( $table_name eq "" ) {
		$table_name = 'undefined';
	}
	my $data_table = $self->register_table( $table_name, $entryID );
	$column = join( "-", @tmp );
	return ( $data_table, $column );
}

sub col_id_4_entry {
	my ( $self, $data_table, $column, $value, $entryID, $new_line ) = @_;

	#warn "col_id_4_entry: column = $column; value = $value\n";
	if ( $value =~ m/^(\w\d+)_r1$/ ) {
		$value = $1;
	}
	if ( $value =~ m/^([[:alpha:]][[:alpha:]][[:alpha:]]+)\d\d\d+$/ ) {
		warn "change column name $column to $1\n" if ( $self->{'debug'} );
		$column = $1;
	}
	my ($pos) = $data_table->Header_Position($column);
	if ( !defined $pos ) {
		($pos) = $data_table->Add_2_Header($column);
	}
	my @tmp;
	if ( !$new_line ) {
		@{ $data_table->{'data'} }[ $entryID - 1 ] = []
		  unless ( defined @{ $data_table->{'data'} }[ $entryID - 1 ] );
		if ( defined @{ @{ $data_table->{'data'} }[ $entryID - 1 ] }[$pos] ) {
			## oops - multiple times the same $column?? get a new column each time
			Carp::cluck("shure you wanted to add the same column again?\n")
			  if ( $self->{'debug'} );
			my $i = 0;
			foreach ( grep( $column, @{ $data_table->{'header'} } ) ) {
				$i++;
				($pos) = $data_table->Add_2_Header( $column . "#$i" );
				unless (
					defined @{ @{ $data_table->{'data'} }[ $entryID - 1 ] }
					[$pos] )
				{
					$i = 0;
					last;
				}
			}
			if ( $i > 0 ) {    ## we found no empty column...
				$tmp[0] =
				  scalar( grep( $column, @{ $data_table->{'header'} } ) );
				($pos) = $data_table->Add_2_Header( $column . "#$tmp[0]" );
			}
		}
	}
	$pos;
}

sub add_if_empty {
	my ( $self, $orig_column, $value, $entryID ) = @_;
	if ( $value =~ m/^(\w\d+)_r1$/ ) {
		$value = $1;
	}
	my ( $data_table, $column ) =
	  $self->table_and_colname( $orig_column, $entryID );
	$entryID = $data_table->Rows();
	my $pos =
	  $self->col_id_4_entry( $data_table, $column, $value, $entryID, 1 );
	@{ $data_table->{'data'} }[ $entryID - 1 ] ||= [];
	if ( !defined @{ @{ $data_table->{'data'} }[ $entryID - 1 ] }[$pos] ) {
		@{ @{ $data_table->{'data'} }[ $entryID - 1 ] }[$pos] = $value;
	}
	return 0;
}

sub add_if_unequal {
	my ( $self, $orig_column, $value, $entryID ) = @_;
	if ( $value =~ m/^(\w\d+)_r1$/ ) {
		$value = $1;
	}
	my ( $data_table, $column ) =
	  $self->table_and_colname( $orig_column, $entryID );
	$entryID = $data_table->Rows();
	my $pos =
	  $self->col_id_4_entry( $data_table, $column, $value, $entryID, 1 );
	unless ( defined @{ $data_table->{'data'} }[ $entryID - 1 ] ) {
		@{ $data_table->{'data'} }[ $entryID - 1 ] ||= [];
		@{ @{ $data_table->{'data'} }[ $entryID - 1 ] }[$pos] = $value;
	}
	elsif ( defined @{ @{ $data_table->{'data'} }[ $entryID - 1 ] }[$pos] ) {
		if ( @{ @{ $data_table->{'data'} }[ $entryID - 1 ] }[$pos] eq $value ) {
			## nothing has to be done!
			warn
"you try to add the same value again: $orig_column, $value, $entryID \n"
			  if ( $self->{'debug'} );
			return 0;
		}
		else {
			$self->add_if_empty( $orig_column, $value, $entryID + 1 );
			return 1;
		}
	}
	if ( !defined @{ @{ $data_table->{'data'} }[ $entryID - 1 ] }[$pos] ) {
		@{ @{ $data_table->{'data'} }[ $entryID - 1 ] }[$pos] = $value;
	}
	return 0;
}

sub register_column {
	my ( $self, $orig_column, $value, $entryID, $new_line, $prohibitDeepRec ) =
	  @_;
	if ( $value =~ m/^(\w\d+)_r1$/ ) {
		$value = $1;
	}
	$new_line        ||= 0;
	$prohibitDeepRec ||= 0;
	my ( $data_table, $pos, $delta, $column );
	$delta = 0;    ## the default no change to the entryID necessary

	( $data_table, $column ) =
	  $self->table_and_colname( $orig_column, $entryID );
	$entryID = $data_table->Rows();
	$entryID = 0 if ( $entryID < 0 );
	$pos =
	  $self->col_id_4_entry( $data_table, $column, $value, $entryID,
		$new_line );
	@{ $data_table->{'data'} }[ $entryID - 1 ] = []
	  unless ( defined @{ $data_table->{'data'} }[ $entryID - 1 ] );

	print
"I have got the table $data_table, columnID $pos and the row ($entryID-1)\n"
	  if ( $self->{'debug'} );

	#@{ $data_table->{'data'} }[ $entryID - 2 ] ||= [];
	if ( $new_line
		and defined @{ @{ $data_table->{'data'} }[ $entryID - 1 ] }[$pos] )
	{
		if ( @{ @{ $data_table->{'data'} }[ $entryID - 1 ] }[$pos] eq $value ) {
			## this entry is most likely a duplicate!
			return 0;
		}
		if ( $prohibitDeepRec < 3 ) {
			push( @{ $data_table->{'data'} }, [] );    ## chamge of logics!!
			$delta =
			  $self->register_column( $orig_column, $value, ( $entryID + 1 ),
				1, $prohibitDeepRec + 1 );
			$delta++;
		}
		else {
			return 0;    ## most likely crap anyhow!
			die "even the next 3 lines were not free - why? $entryID/"
			  . $data_table->Rows()
			  . " $pos $orig_column $value $prohibitDeepRec\n"
			  . "has the value '@{ @{ $data_table->{'data'} }[ $entryID - 1]}[$pos]'\n"
			  . "See file .emergencyBreak.xls\n";
		}
	}
	else {
		@{ @{ $data_table->{'data'} }[ $data_table->Rows() - 1 ] }[$pos] =
		  $value;
	}
	$self->check_last_row($data_table);
	return $delta;
}

sub check_last_row {
	my ( $self, $data_table ) = @_;

	## probably the whole row is empty?
	sub check {
		local $SIG{__WARN__} = sub { };
		my $data_table = shift;
		return !join( "",
			@{ @{ $data_table->{'data'} }[ $data_table->Rows() - 1 ] } ) =~
		  m/\w/;
	}
	if ( &check($data_table) ) {
		splice( @{ $data_table->{'data'} }, $data_table->Rows() - 1, 1 );
		warn "I have dropped a row in the table\n" if ( $self->{'debug'} );
	}
}

sub register_table {
	my ( $self, $tname, $entryID ) = @_;
	unless ( defined $self->{'tables'}->{$tname} ) {
		$self->{'tables'}->{$tname}        = data_table->new();
		$self->{'tables_lastID'}->{$tname} = 0;
	}
	if ( $self->{'tables'}->{$tname}->Rows() == 0 ) {
		warn "I have added a row in the table\n" if ( $self->{'debug'} );
		push( @{ $self->{'tables'}->{$tname}->{'data'} }, [] );
	}
	return $self->{'tables'}->{$tname};
}

sub write_files {
	my ( $self, $fname, $drop ) = @_;
	unless ( defined $drop ) { $drop = 1 }
	my ( $this, $unique, $key, $tmp );

	if ($drop) {
		$self->drop_no_acc();
		$self->drop_duplicates();
	}
	foreach my $name ( keys %{ $self->{'tables'} } ) {
		## I want to get rid of duplicates first!
		$this = $self->{'tables'}->{$name};
		unless ( ref($this) eq "data_table" ) {
			warn "the table '$name' is no data table! (" . ref($this) . ")\n";
			next;
		}
		if ( $this->Rows == 0 ) {
			warn "no data in table $name\n";
			next;
		}
		$self->rename_acc_columns($name);
		$tmp = $fname . "_" . $name . ".xls";
		print join( " ", $tmp, $self->{'tables'}->{$name}->Rows, 'lines' )
		  . "\n";
		$self->{'tables'}->{$name}->write_file($tmp);
	}
}

=head3 rename_acc_columns ($tname)

This function uses the $self->{'tables'}->{$tname} data_table and checks all columns for NCBI IDs (/^[['upper']][['upper']][['upper']]+\d\d\+/)
If one column contains only IDS the column name will be changed to the string part of the ID.
If multiple column contain the same ID type, the columns will be merged.

=cut

sub rename_acc_columns {
	my ( $self, $tname ) = @_;
	return $self;
	my @colnames = @{ $self->{'tables'}->{$tname}->{'header'} };
	my ( $IDtype, $OK, $from_to, $to_from, $merge_problem );

	foreach my $cname (@colnames) {
		$IDtype = '';
		$OK     = 0;
		foreach ( @{ $self->{'tables'}->{$tname}->GetAsArray($cname) } ) {
			if ($_) {
				if ( $_ =~ m/^([[:upper:]][[:upper:]][[:upper:]]+)\d\d\d+$/ ) {
					$IDtype = $1;
					$OK     = 1;
				}
				else {
					$OK = 0;
					last;
				}
			}
		}
		if ($OK) {
			$from_to->{$cname} = $IDtype;
			$to_from->{$IDtype} ||= [];
			push( @{ $to_from->{$IDtype} }, $cname );

			#$self->{'tables'}->{$tname}->rename_column($cname, $IDtype );
		}
	}
	$merge_problem = 0;
	foreach my $cname ( keys %$from_to ) {
		$IDtype = $from_to->{$cname};
		if ( scalar( @{ $to_from->{$IDtype} } ) == 1 ) {
			$self->{'tables'}->{$tname}->rename_column( $cname, $IDtype );
		}
		else {
			## oops more than one column with the same IDtype...
			my $tmp;
			my @data = map
			{ ## this checks for a unique ID in all columns of the same ID type per line
				$tmp = '';
				foreach my $val (
					map {
						if   ( ref($_) eq "ARRAY" ) { @$_ }
						else                        { $_ }
					} $self->{'tables'}->{$tname}
					->get_value_4_line_and_column( $_, $to_from->{$IDtype} )
				  )
				{
					unless ($tmp) {
						$tmp = $val;
					}
					elsif ($val) {
						unless ( $tmp eq $val ) {
							warn "$tname: While merging the columns '"
							  . join( ', ', @{ $to_from->{$IDtype} } )
							  . "' I encountered a entry missmatch on line $_ ($val !== $tmp)";
							$merge_problem = 1;
						}
					}
				}
			} 0 .. ( $self->{'tables'}->{$tname}->Rows() - 1 );
			## now add the data with the right name and drop the old columns....
			$self->{'tables'}->{$tname}->add_column( $IDtype, \@data );
			foreach ( @{ $to_from->{$IDtype} } ) {
				$self->{'tables'}->{$tname}->drop_column($_);
			}
		}
	}
	if ($merge_problem) {
		$self->{'tables'}->{$tname} = undef;
	}
	return $self;
}

=head3 load_set( @files )

This function is used to debug the summary file creation.
This function has to become way more efficient.

=cut

sub load_set {
	my ( $self, @files ) = @_;
	my ( @tmp, $fm );
	foreach my $file (@files) {
		$fm = root->filemap($file);
		next if ( $fm->{'filename_core'} =~ m/SUMMARY.xls$/ );
		@tmp = split( "_", $fm->{'filename_core'} );
		shift(@tmp);
		$self->{'tables'}->{ join( "_", @tmp ) } =
		  data_table->new( { filename => $file } );
	}
	return $self;
}

=head3 write_summary_file

Here I try to identify all NCBI IDS and sum up a hopefully interesting and meaningful final data table

=cut

sub createSummaryTable {
	my ($self) = @_;
	## now collect all IDS?
	## there are IDs in the range of
	## DRP DRR
	## SRA SRR
	## ERP ERR
	## SRP SRR
	## and in addition SAMN, GSE, GSM, PRINJA and so on....

	my ( $table_name, $summary_hash, $ret );

	foreach $table_name ( 'RUN_SET', 'EXPERIMENT', 'SAMPLE', 'Pool', 'STUDY' ) {
		Carp::confess("This dataset has no $table_name information")
		  unless ( $table_name =~ m/\w/
			and $self->{'tables'}->{$table_name}->Rows() > 0 );
		$summary_hash = stefans_libs::XML_parser::TableInformation->new(
			{
				'debug'      => $self->{'debug'},
				'name'       => $table_name,
				'data_table' => $self->{'tables'}->{$table_name}
			}
		)->get_all_data( $summary_hash, $table_name );
		if ( ref($summary_hash) eq "ARRAY" )
		{    # internal error - the IDS submitted are the ones I should look at
			return $summary_hash;
		}
	}

	eval {
		if ( defined $summary_hash ) {
			my $obj = stefans_libs::XML_parser::TableInformation->new(
				{ 'debug' => $self->{'debug'}, 'name' => 'SUMMARY' } );
			$ret = $obj->hash_of_hashes_2_data_table($summary_hash);
			## now I only need to create the wget download for the NCBI sra files
			$ret->Add_2_Header('Download');
			$self->create_download_column( $ret, 'SRR', 'SRA', 'SRP', 'SRX' );
			$self->create_download_column( $ret, 'ERR', 'ERP', 'ERR' );
			$self->create_download_column( $ret, 'ERR', 'ERR' );
			$self->create_download_column( $ret, 'DRR', 'DRP' );

			#$ret->write_file($fname);
		}
	};
	unless ( defined $ret ) {
		warn "Fallback to runset only\n";
		$ret = $self->{'tables'}->{'RUN_SET'};
		$ret->Add_2_Header('Download');
		$self->create_download_column( $ret, 'SRR', 'SRA', 'SRP', 'SRX' );
		$self->create_download_column( $ret, 'ERR', 'ERP', 'ERR' );
		$self->create_download_column( $ret, 'ERR', 'ERR' );
		$self->create_download_column( $ret, 'DRR', 'DRP' );
		
		$self->create_experiment_download_column( $ret, "SRX");
		$self->create_experiment_download_column( $ret, "ERX");
		$self->create_experiment_download_column( $ret, "DRX");
	}
	return $ret;
}

sub write_summary_file {
	my ( $self, $fname ) = @_;

	my $ret = $self->createSummaryTable();
	if ( ref($ret) eq "data_table" ) {
		$ret->write_file($fname);
	}

	return $ret;
}

sub create_experiment_download_column {
	my ( $self, $ret, $acc, @sample ) = @_;

	if ( defined $ret->Header_Position('Download') ) {
		my $OK = 1;
		map { $OK = 0 unless ( $_ =~ m/wget/ ); }
		  @{ $ret->GetAsArray('Download') };
		return $ret if ($OK);
	}
	my $accession_col = [];
	my $sample_col    = [];
	my $add           = 0;
	( @$accession_col[$add] ) = $ret->Header_Position($acc);
	return $ret unless ( defined @$accession_col[$add] );
	
# ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByExp/sra/ERX/ERX690/ERX690616/ERR746934/
	my ($download_col) = $ret->Add_2_Header('Download');
	my $serv = "ftp://ftp-trace.ncbi.nih.gov";
	my ( $sra, $srr );
	for ( my $i = 0 ; $i < $ret->Rows() ; $i++ ) {
		for ( my $a = 0 ; $a < 3 ; $a++ ) {
			next if ( defined @{ @{ $ret->{'data'} }[$i] }[ $download_col ] and @{ @{ $ret->{'data'} }[$i] }[ $download_col ] =~ m/wget/ );
			next unless ( defined @$accession_col[$a] );
			$srr = @{ @{ $ret->{'data'} }[$i] }[ @$accession_col[$a] ];

  #print "sra (@$sample_col[$a]) =$sra and srr (@$accession_col[$a]) = $srr \n";
			if ( $self->is_acc($srr) ) {
				@{ @{ $ret->{'data'} }[$i] }[$download_col] = "wget -r '"
				  . join( "/",
					$serv,
					"sra/sra-instant/reads/ByExp/sra",
					substr( $srr, 0, 3 ),
					substr( $srr, 0, 6 ), $srr )."'";
				last;
			}

		}
	}
	return $ret;
}

sub create_download_column {
	my ( $self, $ret, $acc, @sample ) = @_;

	if ( defined $ret->Header_Position('Download') ) {
		my $OK = 1;
		map { $OK = 0 unless ( $_ =~ m/wget/ ); }
		  @{ $ret->GetAsArray('Download') };
		return $ret if ($OK);
	}
	my $accession_col = [];
	my $sample_col    = [];
	my $add           = 0;
	for ( ; $add > 0 ; $add-- ) {
		last if ( defined @$accession_col[$add] );
	}
	( @$accession_col[$add] ) = $ret->Header_Position($acc);
	if ( defined @$accession_col[$add] ) {
		foreach (@sample) {
			unless ( defined @$sample_col[$add] ) {
				( @$sample_col[$add] ) = $ret->Header_Position($_);
			}
		}
	}

	unless ( defined @$sample_col[$add] ) {
		@$accession_col[$add] = undef;
	}
	else {
#print "this should work!  @$accession_col[$add] + @$sample_col[$add]\n";
# /sra/sra-instant/reads/ByRun/sra/{SRR|ERR|DRR}/<first 6 characters of accession>/<accession>/<accession>.sra
#or by experiment?
# ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByExp/sra/ERX/ERX690/ERX690616/ERR746934/
		my ($download_col) = $ret->Add_2_Header('Download');
		my $serv = "ftp://ftp-trace.ncbi.nih.gov";
		my ( $sra, $srr );
		for ( my $i = 0 ; $i < $ret->Rows() ; $i++ ) {
			for ( my $a = 0 ; $a < 3 ; $a++ ) {
				next unless ( defined @$accession_col[$a] );
				$srr = @{ @{ $ret->{'data'} }[$i] }[ @$accession_col[$a] ];
				$sra = @{ @{ $ret->{'data'} }[$i] }[ @$sample_col[$a] ];

  #print "sra (@$sample_col[$a]) =$sra and srr (@$accession_col[$a]) = $srr \n";
				if ( $self->is_acc($sra) and $self->is_acc($srr) ) {
					@{ @{ $ret->{'data'} }[$i] }[$download_col] =
					    "wget -O '"
					  . $srr
					  . ".sra' '"
					  . join( "/",
						$serv,
						"sra/sra-instant/reads/ByRun/sra",
						substr( $srr, 0, 3 ),
						substr( $srr, 0, 6 ),
						$srr, $srr . '.sra' )
					  . "'";
					last;
				}

			}
		}
	}
	return $ret;
}

sub create_subsets {
	my ( $self, $Colmatch, $name ) = @_;
	$name ||= 'newColumn';
	Carp::confess("I need a string to match the columns to\n")
	  unless ( defined $Colmatch );
	foreach my $this ( values %{ $self->{'tables'} } ) {
		next unless ( ref($this) eq "data_table" );
		next if ( defined $this->Header_Position($name) );
		my @acc_cols = grep ( /$Colmatch/, @{ $this->{'header'} } );
		next if ( scalar(@acc_cols) == 0 );
		$this->define_subset( $name, \@acc_cols );
	}
	$self;
}

sub drop_no_acc {
	my ($self) = @_;
	unless ( defined $self->{'done'}->{'drop_no_acc'} ) {
		$self->create_subsets( 'accession', 'accs' );
		local $SIG{__WARN__} = sub { };
		foreach my $this ( values %{ $self->{'tables'} } ) {
			next unless ( ref($this) eq "data_table" );
			## I want to get rid of duplicates first!
			my @data;
			next unless ( defined $this->Header_Position('accs') );
			for ( my $i = $this->Rows() - 1 ; $i > -1 ; $i-- ) {
				if (
					join(
						"", $this->get_value_4_line_and_column( $i, 'accs' )
					) =~ m/\w/
				  )
				{
					unshift( @data, [ @{ @{ $this->{'data'} }[$i] } ] );
				}
			}
			$this->{'data'} = \@data;
		}
		$self->{'done'}->{'drop_no_acc'} = 1;
	}
	return $self;
}

sub drop_duplicates {
	my ($self) = @_;
	my ( $tmp, $key, $unique );
	unless ( defined $self->{'done'}->{'drop_duplicates'} ) {
		local $SIG{__WARN__} = sub { };
		foreach my $this ( values %{ $self->{'tables'} } ) {
			my @data;
			for ( my $i = $this->Rows() - 1 ; $i > -1 ; $i-- ) {
				## drop the duplicates
				@{ $this->{'data'} }[$i] ||= [];
				{
					$tmp = join( '', @{ @{ $this->{'data'} }[$i] } );
					$key = md5_hex( Encode::encode_utf8($tmp) );
				}
				unless ( defined $unique->{$key} ) {
					unshift( @data, [ @{ @{ $this->{'data'} }[$i] } ] );
					$unique->{$key} = 1;
				}
			}

			#$self->{'tables'}->{$name}->{'data'} = \@data;
		}
		$self->{'done'}->{'drop_duplicates'} = 1;
	}
	## and now I need to drop duplicate entries in the tables too.
	foreach my $this ( values %{ $self->{'tables'} } ) {
		## which one is the uniqe ID
		my $max_uniques = 0;
		my $colname;
		my @vals;

		foreach my $cname ( @{ $this->{'header'} } ) {
			my $OK = 1;
			@vals = @{ $this->GetAsArray($cname) };
			map { $OK = 0 unless ( $self->is_acc($_) ) } @vals;
			if ($OK) {
				my %seen;
				if ( scalar( grep { !$seen{$_}++ } @vals ) > $max_uniques ) {
					$colname     = $cname;
					$max_uniques = scalar( keys %seen );
				}
			}
		}
		next unless ($colname);
		warn "ID column is $colname with $max_uniques unique entries\n";
		@vals = @{ $this->GetAsArray($colname) };
		my $seen;
		for ( my $i = 0 ; $i < @vals ; $i++ ) {
			$seen->{ $vals[$i] } ||= [];
			push( @{ $seen->{ $vals[$i] } }, $i );
		}
		my @drop;
		foreach my $ID ( keys %$seen ) {
			if ( @{ $seen->{$ID} } > 1 ) {
				if ( $ID eq "" ) {
					push( @drop, @{ $seen->{$ID} } );
				}
				else {
					push( @drop,
						@{ $seen->{$ID} }
						  [ 1 .. scalar( @{ $seen->{$ID} } ) - 1 ] );
				}
			}
		}
		if (@drop) {
			foreach my $drop ( sort { $b <=> $a } @drop ) {
				my $i = 0;
				foreach my $pob_value (
					@{ splice( @{ $this->{'data'} }, $drop, 1 ) } )
				{
					if ($pob_value) {
						$self->{'problematic_columns'}
						  ->{ @{ $this->{'header'} }[$i] }++;
					}
					$i++;
				}
				warn "I drop row $drop due a duplicate/missing main ID\n";
			}
		}
	}

	return $self;
}

sub options {
	my ( $self, $name, $replacement ) = @_;
	if ( ref($name) eq "HASH" and !defined $self->{'options'} ) {
		$self->{'options'} = $name;
	}
	elsif ( defined $name ) {
		if ( defined $replacement ) {
			$self->{'options'}->{$name} = $replacement;
		}
		return $self->{'options'}->{$name};
	}
	return $self->{'options'};
}

sub parse_NCBI {
	my ( $self, $hash, $area, $entryID, $new_line ) = @_;
	if ( defined $self->options('inspect') ) {
		my $target = $self->options('inspect');
		if (
			join(
				" ",
				map {
					if ( ref($_) eq "HASH" ) { ( keys %$_, values %$_ ) }
					elsif ( ref($_) eq "ARRAY" ) { @$_ }
					else                         { $_ }
				} $hash
			) =~ m/$target/
		  )
		{
			$self->print_and_die( $hash,
				    "You have searched for the string '"
				  . $self->options('inspect')
				  . "':\n" );
		}
	}
	$entryID  ||= 1;
	$new_line ||= 0;
	$area     ||= '';
	if ( $self->{'debug'} ) {
		print "The actual entryID: $entryID\n";
		return if ( $entryID >= 2 );
	}
	my ( $str, $keys, $delta, $tmp, @tmp );
	$delta = 0;
	if ( ref($hash) eq "ARRAY" ) {
		foreach (@$hash) {
			$delta = $self->parse_NCBI( $_, $area, $entryID, 1 );
			$entryID += $delta;
		}
	}
	elsif ( ref($hash) eq "HASH" ) {
		$str = lc( join( " ", sort keys %$hash ) );

		#If it is some numers - ignore that
		if ( $str eq "count value" ) {
			return 0;    ## I skip the crap!
		}
		if ( $str eq "tag value" || $str eq "tag units value" ) {
			$keys = { map { lc($_) => $_ } keys %$hash };
			@tmp = split( "-", $area );
			pop(@tmp);
			$area = join( "-", @tmp );
			## Here I do not want to create a new entry!
			$delta = $self->add_if_empty( "$area-" . $hash->{ $keys->{'tag'} },
				$hash->{ $keys->{'value'} }, $entryID );
		}
		elsif ( $str =~ m/content/ and $str =~ m/namespace/ ) {
			$delta = $self->add_if_empty( $area . ".$hash->{'namespace'}",
				$hash->{'content'}, $entryID );
		}
		elsif ( $str eq 'refcenter refname' ) {
			$delta = $self->add_if_empty( $area . ".$hash->{'refcenter'}",
				$hash->{'refname'}, $entryID );
		}
		else {
			## If I have an accession or PRIMARY_ID entry I want to process that first!
			$tmp = 0;
			my $overall_delta = 0;
			foreach my $key (
				sort {
					my @a = split( "-", $a );
					my @b = split( "-", $b );
					lc( $a[$#a] ) cmp lc( $b[$#b] )
				} keys %$hash
			  )
			{
				if ( defined $self->options('useOnly') ) {
					unless ( lc($key) eq $key ) {
						unless ( $self->options('useOnly')->{$key} ) {
							warn "I skipp the key '$key'\n";
							return $delta;
						}
					}
				}
				if ( defined $self->options('ignore') ) {
					if ( $self->options('ignore')->{$key} ) {
						warn "I skipp the key '$key'\n";
						return $delta;
					}
				}
				$hash->{$key} =~ s/\s+/ /g;
				print "$key  =>  $hash->{$key} on line $entryID\n"
				  if ( $self->{'debug'} and $tmp++ == 0 );
				## this might need a new line, but that is not 100% sure!
				$str = 0;
				foreach ( @{ $self->options('addMultiple') } ) {
					if ( $key =~ m/$_/ ) {
						$delta =
						  $self->parse_NCBI( $hash->{$key}, "$area-$key",
							$entryID, 0 );
						$str = 1;
					}
				}
				if ( $str == 0 ) {
					$delta =
					  $self->parse_NCBI( $hash->{$key}, "$area-$key", $entryID,
						1 );
				}

				#				$overall_delta = $delta unless ( $delta == 0);
				( $entryID, $delta ) = $self->__cleanup( $entryID, $delta );
				print "\t\tafterwards we are on line $entryID\n"
				  if ( $tmp == 1 and $self->{'debug'} );
			}
			$delta = $overall_delta
			  ;    ## I need to report back if I (ever) changed my entryID!!
		}
	}
	else {         ## some real data

#		return 0 if ( defined $values -> { $hash } ) ;
#		as the new column might come from a new hash, that might need merging to the last line - check that!
		foreach ( @{ $self->options('addMultiple') } ) {
			if ( $area =~ m/$_/ ) {
				$delta = $self->register_column( $area, $hash, $entryID, 0 );
			}
		}
		if ( $area =~ m/accession$/ ) {
			$delta = $self->register_column( $area, $hash, $entryID, 1 );
		}

		#elsif ( $hash =~ m/^(\w\w\w\d+)_?r?1?$/ ) {    ## an accession!
		elsif ( $hash =~ m/^\w\w\w\d+$/ ) {    ## an accession!
			$delta = $self->add_if_unequal( $area, $hash, $entryID );
		}
		else {
			$delta = $self->register_column( $area, $hash, $entryID, 1 );
		}
	}

	return
	  $delta
	  ;    ## we did add some data or respawned so if necessary update the id!
}

sub __cleanup {
	my ( $self, $entryID, $delta ) = @_;
	$delta ||= 0;
	$delta = 1  if ( $delta > 1 );
	$delta = -1 if ( $delta < -1 );
	$entryID += $delta;
	return ( $entryID, $delta );
}

sub print_and_die {
	my ( $self, $xml ) = @_;
	print " \$exp = " . root->print_perl_var_def($xml) . ";\n ";

	#	print Dumper($xml);
	Carp::confess(shift);
}

sub print_debug {
	my ( $self, $hash, $area, $entryID, $new_line, $delta, $str ) = @_;
	$str ||= '';
	print
	  "$str final delta = $delta for $area, line =$entryID, and hash $hash\n"
	  if ( $self->{'debug'} );
}

sub is_acc {
	my ( $self, $acc ) = @_;
	return 0 unless ( defined $acc );
	return $acc =~ m/^[[:alpha:]][[:alpha:]][[:alpha:]]+\d\d\d+$/;
}

1;
