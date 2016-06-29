package stefans_libs::SampleTable;

#use FindBin;
#use lib "$FindBin::Bin/../lib/";
use strict;
use warnings;

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


=for comment

This document is in Pod format.  To read this, use a Pod formatter,
like 'perldoc perlpod'.

=head1 NAME

stefans_libs::SampleTable

=head1 DESCRIPTION

Modify a sample table to (1) identify the column that links to a list of files and (2) restict the samples file to only those rows, that actually have a file representation.

=head2 depends on


=cut

=head1 METHODS

=head2 new ( $hash )

new returns a new object reference of the class stefans_libs::SampleTable.
All entries of the hash will be copied into the objects hash - be careful t use that right!

=cut

sub new {

	my ( $class, $hash ) = @_;

	my ($self);

	$self = {};
	foreach ( keys %{$hash} ) {
		$self->{$_} = $hash->{$_};
	}

	bless $self, $class if ( $class eq "stefans_libs::SampleTable" );

	Carp::confess("I need a {'data_table'=> \$obj} at stratup.")
	  unless ( ref( $self->{'data_table'} ) eq "data_table" );
	Carp::confess("I need a {'filenames'=> \$obj} at stratup.")
	  unless ( ref( $self->{'filenames'} ) eq "ARRAY" );

	return $self;

}

sub pos_unique {
	my ( $self, $col_id ) = @_;
	my @pos =
	  map { $self->to_file_pos($_) }
	  @{ $self->{data_table}
		  ->GetAsArray( @{ $self->{data_table}->{'header'} }[$col_id] )
	  };
	my $test;
	foreach ( @pos ) {
		next unless ( defined $_ );
		return 0 if ( defined $test->{$_} );
		$test->{$_} = 1;
	}
	return 1;
}

sub fix_the_table {
	my ( $self, $fm, $data_table, $files ) = @_;
	$data_table = $self->_make_sure_internal( $data_table, 'data_table' );
	$files      = $self->_make_sure_internal( $files,      'filenames' );
	my @fileCols = $self->check_4_link2files( @{ $data_table->{'data'} }[0] );
	my $i = 1;
	while ( @fileCols == 0 ) {
		@fileCols =
		  $self->check_4_link2files( @{ $data_table->{'data'} }[ $i++ ] );
		for ( my $i = @fileCols-1; $i >=0 ; $i -- ){
			splice(@fileCols,$i, 1 ) unless ( $self->pos_unique($fileCols[$i]) );
		}
		last if ( $i == $data_table->Rows() );
	}

	unless ( @fileCols > 0 ) {
		Carp::confess(
"Sorry, but I could not link the samples table to the files you have given me!"
		);
	}
	if ( @fileCols > 1 ) {
		warn
"I use the first file column @{$data_table->{'header'}}[$fileCols[0]]\n";
	}
	$self->reorder_files( $data_table->GetAsArray( $fileCols[0] ) );
	$data_table->add_column(
		'filename',
		map {
			my $f = root->filemap($_);
			root->relative_path( $fm, $f ) . "/" . $f->{'filename'}
		  } @{ $self->{'filenames'} }
	);
	return $data_table, $fileCols[0];
}

sub _make_sure_internal {
	my ( $self, $obj, $name ) = @_;
	if ( ref($obj) =~ m/\w/ ) {
		$self->{$name} = $obj;
	}
	return $self->{$name};
}

sub match_to_one_file {
	my ( $self, $data ) = @_;
	my $r = 0;
	foreach ( @{ $self->{'filenames'} } ) {
		$r++ if ( $_ =~ m/$data/ );
	}
	return $r == 1;
}

sub check_4_link2files {
	my ( $self, $array ) = @_;
	grep /\d/,
	  map { $_ if ( $self->match_to_one_file( @$array[$_] ) ) }
	  0 .. ( scalar(@$array) - 1 );
}

sub to_file_pos {
	my ( $self, $data ) = @_;
	for ( my $i = 0 ; $i < @{ $self->{'filenames'} } ; $i++ ) {
		if ( @{ $self->{'filenames'} }[$i] =~ m/$data/ ) {
			return $i;
		}
	}

	#warn "entry '$data' did not link to a file!";
	return undef;
}

sub reorder_files {
	my ( $self, $array ) = @_;
	my $data_table = $self->{'data_table'};
	my @pos = map { $self->to_file_pos($_) } @$array;
	my @undefined = grep ( /\d+/,
		map {
			if ( !defined( $pos[$_] ) ) { $_ }
		} 0 .. $#pos );
	foreach ( sort { $b <=> $a } @undefined ) {

		#warn "I have to drop the line $_ as no file corresponds to that id\n";
		splice( @pos,                       $_, 1 );
		splice( @{ $data_table->{'data'} }, $_, 1 )
		  ;    ## drop the columns that have no file attached
	}
	warn "I have " . scalar(@pos) . " files left\n";
	$self->{'filenames'} = [ @{ $self->{'filenames'} }[@pos] ];
}

sub is_complete {
	my ( $self, $array ) = @_;
	my $OK = 1;
	map { $OK = 0 unless ( defined $_ and $_ =~ m/\w/ ) } @$array;
	return $OK;
}

sub uniqe {
	my ( $self, $array ) = @_;
	my $d = { map { $_ => 1 } @$array };
	return keys %$d;
}

1;
