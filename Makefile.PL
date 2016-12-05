#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.


use inc::Module::Install;

name "REanalyze_SRA";
version_from "lib/REanalyze_SRA.pm";
author 'Stefan Lang <Stefan.Lang@med.lu.se>';

requires	'Stefans_Libs_Essentials' => 1.02;
requires 'stefans_libs-GenomeDB' => 0.1;
requires		'XML::Simple' => 0;
requires 'Parallel::ForkManager' => 0;


opendir( DIR, "bin/" ) or die "I could not open the bin folder\n$!\n";
map { install_script "bin/$_" } grep !/^\./,  grep '*.pl', readdir(DIR);
close ( DIR );


auto_install();
WriteAll;
