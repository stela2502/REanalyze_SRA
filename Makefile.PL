#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.

use ExtUtils::MakeMaker;

opendir( DIR, "bin/" ) or die "I could not open the bin folder\n$!\n";

WriteMakefile(
	NAME         => "REanalyze_SRA",
	VERSION_FROM => "lib/REanalyze_SRA.pm",
	EXE_FILES    => [ map {"bin/$_" } grep !/^\./,  grep '*.pl', readdir(DIR) ],
	PREREQ_PM    => {
		'Stefans_Libs_Essentials' => 1.02,
		'stefans_libs-GenomeDB' => 0.1,
		'Digest::MD5'		  => 0,
		'Data::Dumper' => 0,
		'XML::Simple' => 0,
	  }

);
closedir(DIR);
