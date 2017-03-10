#! /usr/bin/perl
use strict;
use warnings;
use XML::Simple;

use Test::More tests => 24;
BEGIN { use_ok 'stefans_libs::XML_parser' };

use FindBin;
my $plugin_path = $FindBin::Bin;

my $outfile = "$plugin_path/data/output/XML_parser/";
if ( -d $outfile ) {
	system( 'rm -Rf '.$outfile);
}else {
	system( 'mkdir -p '.$outfile);
}
$outfile .= "SRR2094196";

my ( $value, @values, $exp );
my $IDX = stefans_libs::XML_parser->new();

$IDX->options( {'addMultiple' => [] , 'ignore' => {'tax_analysis' => 1} } ); 

is_deeply( ref($IDX), 'stefans_libs::XML_parser',
	'simple test of function stefans_libs::XML_parser -> new()' );

ok ( $exp = $IDX->parse_NCBI(&get_hash() ) == 1, "got exactly one entry back ($exp)" );

print " \$exp = " . root->print_perl_var_def( [ sort keys%{$IDX->{'tables'}}] ) . ";\n ";
$exp = [ 'Member', 'PRIMARY_ID', 'Read', 'SUBMITTER_ID.GEO', 'accession', 'count', 'cs_native', 'nreads', 'nspots', 'refname', 'undefined' ];

is_deeply([ sort keys %{$IDX->{'tables'}}], $exp, "right tables created");

$IDX->write_files( $outfile, 1 );

#$IDX->write_summary_file( $outfile . "_SUMMARY.xls" ); ## this breaks with this entry!

#print " \$exp = " . root->print_perl_var_def( \@values ) . ";\n ";


sub get_hash {
	return my $exp = {
		'Bases' => {
			'Base' => [
				{
					'count' => '345227241',
					'value' => 'A'
				},
				{
					'count' => '304755796',
					'value' => 'C'
				},
				{
					'count' => '300370412',
					'value' => 'G'
				},
				{
					'count' => '345925829',
					'value' => 'T'
				},
				{
					'count' => '48922',
					'value' => 'N'
				}
			],
			'count'     => '1296328200',
			'cs_native' => 'false'
		},
		'EXPERIMENT_REF' => {
			'accession' => 'SRX1089822',
			'refname'   => 'GSM1816079'
		},
		'IDENTIFIERS' => {
			'PRIMARY_ID'   => 'SRR2094196',
			'SUBMITTER_ID' => {
				'content'   => 'GSM1816079_r1',
				'namespace' => 'GEO'
			}
		},
		'Pool' => {
			'Member' => {
				'IDENTIFIERS' => {
					'EXTERNAL_ID' => [
						{
							'content'   => 'SAMN03852526',
							'namespace' => 'BioSample'
						},
						{
							'content'   => 'GSM1816079',
							'namespace' => 'GEO'
						}
					],
					'PRIMARY_ID' => 'SRS985833'
				},
				'accession'    => 'SRS985833',
				'bases'        => '1296328200',
				'member_name'  => undef,
				'organism'     => 'Homo sapiens',
				'sample_name'  => 'GSM1816079',
				'sample_title' => 'H3K27me3-A0',
				'spots'        => '25926564',
				'tax_id'       => '9606'
			}
		},
		'Statistics' => {
			'Read' => {
				'average' => '50',
				'count'   => '25926564',
				'index'   => '0',
				'stdev'   => '0'
			},
			'nreads' => '1',
			'nspots' => '25926564'
		},
		'accession'             => 'SRR2094196',
		'alias'                 => 'GSM1816079_r1',
		'cluster_name'          => 'public',
		'is_public'             => 'true',
		'load_done'             => 'true',
		'published'             => '2016-01-11 16:55:07',
		'size'                  => '825799743',
		'static_data_available' => '1',
		'tax_analysis'          => {
			'aligns_to_version'     => '0.34',
			'analyzed_spot_count'   => '25926564',
			'dbs_mtime'             => '2016-06-28 06:01:03',
			'dbs_name'              => 'tree_index.dbs',
			'dbss_mtime'            => '2016-07-07 08:15:09',
			'dbss_name'             => 'tree_filter.dbss',
			'identified_spot_count' => '12030115',
			'parser_version'        => '0.4',
			'taxon'                 => {
				'Viruses' => {
					'rank'       => 'superkingdom',
					'self_count' => '0',
					'tax_id'     => '10239',
					'taxon'      => {
						'Retro-transcribing viruses' => {
							'self_count' => '0',
							'tax_id'     => '35268',
							'taxon'      => {
								'name'       => 'Retroviridae',
								'rank'       => 'family',
								'self_count' => '0',
								'tax_id'     => '11632',
								'taxon'      => {
									'name'       => 'Orthoretrovirinae',
									'rank'       => 'subfamily',
									'self_count' => '0',
									'tax_id'     => '327045',
									'taxon'      => {
										'name'       => 'Lentivirus',
										'rank'       => 'genus',
										'self_count' => '0',
										'tax_id'     => '11646',
										'taxon'      => {
											'name' =>
											  'Primate lentivirus group',
											'self_count' => '3',
											'tax_id'     => '11652',
											'taxon'      => {
												'name' =>
'Human immunodeficiency virus 1',
												'rank'        => 'species',
												'self_count'  => '8',
												'tax_id'      => '11676',
												'total_count' => '8'
											},
											'total_count' => '11'
										},
										'total_count' => '11'
									},
									'total_count' => '11'
								},
								'total_count' => '11'
							},
							'total_count' => '11'
						},
						'dsDNA viruses, no RNA stage' => {
							'self_count' => '0',
							'tax_id'     => '35237',
							'taxon'      => {
								'name'       => 'Baculoviridae',
								'rank'       => 'family',
								'self_count' => '0',
								'tax_id'     => '10442',
								'taxon'      => {
									'name'       => 'Alphabaculovirus',
									'rank'       => 'genus',
									'self_count' => '0',
									'tax_id'     => '558016',
									'taxon'      => {
										'name' =>
'Autographa californica multiple nucleopolyhedrovirus',
										'rank'       => 'species',
										'self_count' => '0',
										'tax_id'     => '307456',
										'taxon'      => {
											'name' =>
'Autographa californica nucleopolyhedrovirus',
											'self_count'  => '1',
											'tax_id'      => '46015',
											'total_count' => '1'
										},
										'total_count' => '1'
									},
									'total_count' => '1'
								},
								'total_count' => '1'
							},
							'total_count' => '1'
						}
					},
					'total_count' => '12'
				},
				'cellular organisms' => {
					'self_count' => '0',
					'tax_id'     => '131567',
					'taxon'      => {
						'Bacteria' => {
							'rank'       => 'superkingdom',
							'self_count' => '40224',
							'tax_id'     => '2',
							'taxon'      => {
								'Proteobacteria' => {
									'rank'       => 'phylum',
									'self_count' => '311',
									'tax_id'     => '1224',
									'taxon'      => {
										'Alphaproteobacteria' => {
											'rank'       => 'class',
											'self_count' => '0',
											'tax_id'     => '28211',
											'taxon'      => {
												'Pelagibacterales' => {
													'rank'       => 'order',
													'self_count' => '0',
													'tax_id'     => '54526',
													'taxon'      => {
														'name' =>
														  'Pelagibacteraceae',
														'rank' => 'family',
														'self_count' => '0',
														'tax_id' => '1655514',
														'taxon'  => {
															'name' =>
'Candidatus Pelagibacter',
															'rank' => 'genus',
															'self_count' => '0',
															'tax_id' =>
															  '198251',
															'taxon' => {
																'name' =>
'Candidatus Pelagibacter ubique',
																'rank' =>
																  'species',
																'self_count' =>
																  '0',
																'tax_id' =>
																  '198252',
																'taxon' => {
																	'name' =>
'Candidatus Pelagibacter ubique HTCC1002',
																	'self_count'
																	  => '13',
																	'tax_id' =>
																	  '314261',
'total_count'
																	  => '13'
																},
																'total_count'
																  => '13'
															},
															'total_count' =>
															  '13'
														},
														'total_count' => '13'
													},
													'total_count' => '13'
												},
												'Rhizobiales' => {
													'rank'        => 'order',
													'self_count'  => '2',
													'tax_id'      => '356',
													'total_count' => '2'
												},
												'Sphingomonadales' => {
													'rank'       => 'order',
													'self_count' => '0',
													'tax_id'     => '204457',
													'taxon'      => {
														'name' =>
														  'Sphingomonadaceae',
														'rank' => 'family',
														'self_count' => '0',
														'tax_id'     => '41297',
														'taxon'      => {
															'name' =>
															  'Sphingomonas',
															'rank' => 'genus',
															'self_count' => '5',
															'tax_id' => '13687',
															'total_count' => '5'
														},
														'total_count' => '5'
													},
													'total_count' => '5'
												}
											},
											'total_count' => '20'
										},
										'Betaproteobacteria' => {
											'rank'       => 'class',
											'self_count' => '0',
											'tax_id'     => '28216',
											'taxon'      => {
												'name' => 'Burkholderiales',
												'rank' => 'order',
												'self_count' => '8',
												'tax_id'     => '80840',
												'taxon'      => {
													'Burkholderiaceae' => {
														'rank' => 'family',
														'self_count' => '0',
														'tax_id' => '119060',
														'taxon'  => {
															'Burkholderia' => {
																'rank' =>
																  'genus',
																'self_count' =>
																  '0',
																'tax_id' =>
																  '32008',
																'taxon' => {
																	'name' =>
'Burkholderia cepacia complex',
																	'rank' =>
'species group',
																	'self_count'
																	  => '0',
																	'tax_id' =>
																	  '87882',
																	'taxon' => {
																		'name'
																		  => 'Burkholderia sp. AU4i',
																		'rank'
																		  => 'species',
'self_count'
																		  => '3',
																		'tax_id'
																		  => '1335308',
'total_count'
																		  => '3'
																	},
'total_count'
																	  => '3'
																},
																'total_count'
																  => '3'
															},
															'Ralstonia' => {
																'rank' =>
																  'genus',
																'self_count' =>
																  '10',
																'tax_id' =>
																  '48736',
																'total_count'
																  => '10'
															}
														},
														'total_count' => '13'
													},
													'Comamonadaceae' => {
														'rank' => 'family',
														'self_count' => '0',
														'tax_id'     => '80864',
														'taxon'      => {
															'name' =>
															  'Curvibacter',
															'rank' => 'genus',
															'self_count' => '2',
															'tax_id' =>
															  '281915',
															'total_count' => '2'
														},
														'total_count' => '2'
													}
												},
												'total_count' => '23'
											},
											'total_count' => '23'
										},
										'Gammaproteobacteria' => {
											'rank'       => 'class',
											'self_count' => '22',
											'tax_id'     => '1236',
											'taxon'      => {
												'Enterobacterales' => {
													'rank'       => 'order',
													'self_count' => '0',
													'tax_id'     => '91347',
													'taxon'      => {
														'Enterobacteriaceae' =>
														  {
															'rank' => 'family',
															'self_count' =>
															  '46',
															'tax_id' => '543',
															'taxon'  => {
																'name' =>
																  'Escherichia',
																'rank' =>
																  'genus',
																'self_count' =>
																  '0',
																'tax_id' =>
																  '561',
																'taxon' => {
																	'name' =>
'Escherichia coli',
																	'rank' =>
																	  'species',
																	'self_count'
																	  => '33',
																	'tax_id' =>
																	  '562',
'total_count'
																	  => '33'
																},
																'total_count'
																  => '33'
															},
															'total_count' =>
															  '79'
														  },
														'Hafniaceae' => {
															'rank' => 'family',
															'self_count' => '0',
															'tax_id' =>
															  '1903412',
															'taxon' => {
																'name' =>
																  'Hafnia',
																'rank' =>
																  'genus',
																'self_count' =>
																  '0',
																'tax_id' =>
																  '568',
																'taxon' => {
																	'name' =>
'Hafnia alvei',
																	'rank' =>
																	  'species',
																	'self_count'
																	  => '1',
																	'tax_id' =>
																	  '569',
'total_count'
																	  => '1'
																},
																'total_count'
																  => '1'
															},
															'total_count' => '1'
														}
													},
													'total_count' => '80'
												},
												'Pseudomonadales' => {
													'rank'       => 'order',
													'self_count' => '0',
													'tax_id'     => '72274',
													'taxon'      => {
														'name' =>
														  'Pseudomonadaceae',
														'rank' => 'family',
														'self_count' => '0',
														'tax_id' => '135621',
														'taxon'  => {
															'name' =>
															  'Pseudomonas',
															'rank' => 'genus',
															'self_count' =>
															  '539',
															'tax_id' => '286',
															'taxon'  => {
'Pseudomonas fluorescens group'
																  => {
																	'rank' =>
'species group',
																	'self_count'
																	  => '0',
																	'tax_id' =>
																	  '136843',
																	'taxon' => {
'Pseudomonas fluorescens'
																		  => {
'rank'
																			  =>
'species',
'self_count'
																			  =>
'62',
'tax_id'
																			  =>
'294',
'total_count'
																			  =>
'62'
																		  },
'Pseudomonas sp. FH4'
																		  => {
'rank'
																			  =>
'species',
'self_count'
																			  =>
'1',
'tax_id'
																			  =>
'1284393',
'total_count'
																			  =>
'1'
																		  }
																	},
'total_count'
																	  => '63'
																  },
'Pseudomonas sp. CF150'
																  => {
																	'rank' =>
																	  'species',
																	'self_count'
																	  => '1',
																	'tax_id' =>
																	  '911240',
'total_count'
																	  => '1'
																  },
'Pseudomonas stutzeri group'
																  => {
																	'rank' =>
'species group',
																	'self_count'
																	  => '0',
																	'tax_id' =>
																	  '136846',
																	'taxon' => {
																		'name'
																		  => 'Pseudomonas stutzeri subgroup',
																		'rank'
																		  => 'species subgroup',
'self_count'
																		  => '0',
																		'tax_id'
																		  => '578833',
																		'taxon'
																		  => {
'name'
																			  =>
'Pseudomonas stutzeri',
'rank'
																			  =>
'species',
'self_count'
																			  =>
'0',
'tax_id'
																			  =>
'316',
'taxon'
																			  =>
																			  {
'name'
																				  =>
'Pseudomonas stutzeri ATCC 17588 = LMG 11199',
'self_count'
																				  =>
'1',
'tax_id'
																				  =>
'96563',
'total_count'
																				  =>
'1'
																			  },
'total_count'
																			  =>
'1'
																		  },
'total_count'
																		  => '1'
																	},
'total_count'
																	  => '1'
																  }
															},
															'total_count' =>
															  '604'
														},
														'total_count' => '604'
													},
													'total_count' => '604'
												},
												'Xanthomonadales' => {
													'rank'       => 'order',
													'self_count' => '0',
													'tax_id'     => '135614',
													'taxon'      => {
														'name' =>
														  'Xanthomonadaceae',
														'rank' => 'family',
														'self_count' => '0',
														'tax_id'     => '32033',
														'taxon'      => {
															'name' =>
'Stenotrophomonas',
															'rank' => 'genus',
															'self_count' => '5',
															'tax_id' => '40323',
															'total_count' => '5'
														},
														'total_count' => '5'
													},
													'total_count' => '5'
												}
											},
											'total_count' => '711'
										}
									},
									'total_count' => '1065'
								},
								'Terrabacteria group' => {
									'self_count' => '0',
									'tax_id'     => '1783272',
									'taxon'      => {
										'Actinobacteria' => {
											'rank'       => 'phylum',
											'self_count' => '0',
											'tax_id'     => '201174',
											'taxon'      => {
												'name' => 'Actinobacteria',
												'rank' => 'class',
												'self_count' => '0',
												'tax_id'     => '1760',
												'taxon'      => {
													'Bifidobacteriales' => {
														'rank'       => 'order',
														'self_count' => '0',
														'tax_id'     => '85004',
														'taxon'      => {
															'name' =>
'Bifidobacteriaceae',
															'rank' => 'family',
															'self_count' => '1',
															'tax_id' => '31953',
															'taxon'  => {
																'name' =>
																  'Gardnerella',
																'rank' =>
																  'genus',
																'self_count' =>
																  '0',
																'tax_id' =>
																  '2701',
																'taxon' => {
																	'name' =>
'Gardnerella vaginalis',
																	'rank' =>
																	  'species',
																	'self_count'
																	  => '1',
																	'tax_id' =>
																	  '2702',
'total_count'
																	  => '1'
																},
																'total_count'
																  => '1'
															},
															'total_count' => '2'
														},
														'total_count' => '2'
													},
													'Micrococcales' => {
														'rank'       => 'order',
														'self_count' => '0',
														'tax_id'     => '85006',
														'taxon'      => {
															'name' =>
'Microbacteriaceae',
															'rank' => 'family',
															'self_count' => '1',
															'tax_id' => '85023',
															'total_count' => '1'
														},
														'total_count' => '1'
													},
													'Propionibacteriales' => {
														'rank'       => 'order',
														'self_count' => '0',
														'tax_id'     => '85009',
														'taxon'      => {
															'name' =>
'Propionibacteriaceae',
															'rank' => 'family',
															'self_count' => '0',
															'tax_id' => '31957',
															'taxon'  => {
																'name' =>
'Propionibacterium',
																'rank' =>
																  'genus',
																'self_count' =>
																  '137',
																'tax_id' =>
																  '1743',
																'total_count'
																  => '137'
															},
															'total_count' =>
															  '137'
														},
														'total_count' => '137'
													}
												},
												'total_count' => '140'
											},
											'total_count' => '140'
										},
										'Firmicutes' => {
											'rank'       => 'phylum',
											'self_count' => '0',
											'tax_id'     => '1239',
											'taxon'      => {
												'Bacilli' => {
													'rank'       => 'class',
													'self_count' => '0',
													'tax_id'     => '91061',
													'taxon'      => {
														'Bacillales' => {
															'rank' => 'order',
															'self_count' => '0',
															'tax_id' => '1385',
															'taxon'  => {
																'name' =>
																  'Bacillaceae',
																'rank' =>
																  'family',
																'self_count' =>
																  '3',
																'tax_id' =>
																  '186817',
																'total_count'
																  => '3'
															},
															'total_count' => '3'
														},
														'Lactobacillales' => {
															'rank' => 'order',
															'self_count' => '0',
															'tax_id' =>
															  '186826',
															'taxon' => {
																'name' =>
'Streptococcaceae',
																'rank' =>
																  'family',
																'self_count' =>
																  '0',
																'tax_id' =>
																  '1300',
																'taxon' => {
'Lactococcus'
																	  => {
																		'rank'
																		  => 'genus',
'self_count'
																		  => '0',
																		'tax_id'
																		  => '1357',
																		'taxon'
																		  => {
'name'
																			  =>
'Lactococcus lactis',
'rank'
																			  =>
'species',
'self_count'
																			  =>
'1',
'tax_id'
																			  =>
'1358',
'total_count'
																			  =>
'1'
																		  },
'total_count'
																		  => '1'
																	  },
'Streptococcus'
																	  => {
																		'rank'
																		  => 'genus',
'self_count'
																		  => '9',
																		'tax_id'
																		  => '1301',
'total_count'
																		  => '9'
																	  }
																},
																'total_count'
																  => '10'
															},
															'total_count' =>
															  '10'
														}
													},
													'total_count' => '13'
												},
												'Negativicutes' => {
													'rank'       => 'class',
													'self_count' => '0',
													'tax_id'     => '909932',
													'taxon'      => {
														'name' =>
														  'Veillonellales',
														'rank'       => 'order',
														'self_count' => '0',
														'tax_id' => '1843489',
														'taxon'  => {
															'name' =>
															  'Veillonellaceae',
															'rank' => 'family',
															'self_count' => '1',
															'tax_id' => '31977',
															'total_count' => '1'
														},
														'total_count' => '1'
													},
													'total_count' => '1'
												}
											},
											'total_count' => '14'
										}
									},
									'total_count' => '154'
								}
							},
							'total_count' => '41443'
						},
						'Eukaryota' => {
							'rank'       => 'superkingdom',
							'self_count' => '45239',
							'tax_id'     => '2759',
							'taxon'      => {
								'name'       => 'Opisthokonta',
								'self_count' => '3633',
								'tax_id'     => '33154',
								'taxon'      => {
									'name'       => 'Metazoa',
									'rank'       => 'kingdom',
									'self_count' => '0',
									'tax_id'     => '33208',
									'taxon'      => {
										'name'       => 'Eumetazoa',
										'self_count' => '707',
										'tax_id'     => '6072',
										'taxon'      => {
											'name'       => 'Bilateria',
											'self_count' => '19987',
											'tax_id'     => '33213',
											'taxon'      => {
												'name'       => 'Deuterostomia',
												'self_count' => '431',
												'tax_id'     => '33511',
												'taxon'      => {
													'name'       => 'Chordata',
													'rank'       => 'phylum',
													'self_count' => '84',
													'tax_id'     => '7711',
													'taxon'      => {
														'name' => 'Craniata',
														'rank' => 'subphylum',
														'self_count' => '0',
														'tax_id'     => '89593',
														'taxon'      => {
															'name' =>
															  'Vertebrata',
															'self_count' => '0',
															'tax_id' => '7742',
															'taxon'  => {
																'name' =>
'Gnathostomata',
																'self_count' =>
																  '1589',
																'tax_id' =>
																  '7776',
																'taxon' => {
																	'name' =>
'Teleostomi',
																	'self_count'
																	  => '0',
																	'tax_id' =>
																	  '117570',
																	'taxon' => {
																		'name'
																		  => 'Euteleostomi',
'self_count'
																		  => '8351',
																		'tax_id'
																		  => '117571',
																		'taxon'
																		  => {
'name'
																			  =>
'Sarcopterygii',
'self_count'
																			  =>
'1841',
'tax_id'
																			  =>
'8287',
'taxon'
																			  =>
																			  {
'name'
																				  =>
'Dipnotetrapodomorpha',
'self_count'
																				  =>
'0',
'tax_id'
																				  =>
'1338369',
'taxon'
																				  =>
																				  {
'name'
																					  =>
'Tetrapoda',
'self_count'
																					  =>
'1217',
'tax_id'
																					  =>
'32523',
'taxon'
																					  =>
																					  {
'name'
																						  =>
'Amniota',
'self_count'
																						  =>
'64397',
'tax_id'
																						  =>
'32524',
'taxon'
																						  =>
																						  {
'name'
																							  =>
'Mammalia',
'rank'
																							  =>
'class',
'self_count'
																							  =>
'5746',
'tax_id'
																							  =>
'40674',
'taxon'
																							  =>
																							  {
'name'
																								  =>
'Theria',
'self_count'
																								  =>
'11391',
'tax_id'
																								  =>
'32525',
'taxon'
																								  =>
																								  {
'name'
																									  =>
'Eutheria',
'self_count'
																									  =>
'178671',
'tax_id'
																									  =>
'9347',
'taxon'
																									  =>
																									  {
'Afrotheria'
																										  =>
																										  {
'rank'
																											  =>
'superorder',
'self_count'
																											  =>
'0',
'tax_id'
																											  =>
'311790',
'taxon'
																											  =>
																											  {
'name'
																												  =>
'Sirenia',
'rank'
																												  =>
'order',
'self_count'
																												  =>
'0',
'tax_id'
																												  =>
'9774',
'taxon'
																												  =>
																												  {
'name'
																													  =>
'Trichechidae',
'rank'
																													  =>
'family',
'self_count'
																													  =>
'0',
'tax_id'
																													  =>
'9775',
'taxon'
																													  =>
																													  {
'name'
																														  =>
'Trichechus',
'rank'
																														  =>
'genus',
'self_count'
																														  =>
'0',
'tax_id'
																														  =>
'9776',
'taxon'
																														  =>
																														  {
'name'
																															  =>
'Trichechus manatus',
'rank'
																															  =>
'species',
'self_count'
																															  =>
'0',
'tax_id'
																															  =>
'9778',
'taxon'
																															  =>
																															  {
'name'
																																  =>
'Trichechus manatus latirostris',
'rank'
																																  =>
'subspecies',
'self_count'
																																  =>
'31',
'tax_id'
																																  =>
'127582',
'total_count'
																																  =>
'31'
																															  }
																															,
'total_count'
																															  =>
'31'
																														  }
																														,
'total_count'
																														  =>
'31'
																													  }
																													,
'total_count'
																													  =>
'31'
																												  }
																												,
'total_count'
																												  =>
'31'
																											  }
																											,
'total_count'
																											  =>
'31'
																										  }
																										,
'Boreoeutheria'
																										  =>
																										  {
'self_count'
																											  =>
'240320',
'tax_id'
																											  =>
'1437010',
'taxon'
																											  =>
																											  {
'Euarchontoglires'
																												  =>
																												  {
'rank'
																													  =>
'superorder',
'self_count'
																													  =>
'219373',
'tax_id'
																													  =>
'314146',
'taxon'
																													  =>
																													  {
'Glires'
																														  =>
																														  {
'self_count'
																															  =>
'0',
'tax_id'
																															  =>
'314147',
'taxon'
																															  =>
																															  {
'name'
																																  =>
'Rodentia',
'rank'
																																  =>
'order',
'self_count'
																																  =>
'0',
'tax_id'
																																  =>
'9989',
'taxon'
																																  =>
																																  {
'Hystricognathi'
																																	  =>
																																	  {
'rank'
																																		  =>
'suborder',
'self_count'
																																		  =>
'20',
'tax_id'
																																		  =>
'33550',
'taxon'
																																		  =>
																																		  {
'Bathyergidae'
																																			  =>
																																			  {
'rank'
																																				  =>
'family',
'self_count'
																																				  =>
'0',
'tax_id'
																																				  =>
'10167',
'taxon'
																																				  =>
																																				  {
'name'
																																					  =>
'Heterocephalus',
'rank'
																																					  =>
'genus',
'self_count'
																																					  =>
'0',
'tax_id'
																																					  =>
'10180',
'taxon'
																																					  =>
																																					  {
'name'
																																						  =>
'Heterocephalus glaber',
'rank'
																																						  =>
'species',
'self_count'
																																						  =>
'25',
'tax_id'
																																						  =>
'10181',
'total_count'
																																						  =>
'25'
																																					  }
																																					,
'total_count'
																																					  =>
'25'
																																				  }
																																				,
'total_count'
																																				  =>
'25'
																																			  }
																																			,
'Caviidae'
																																			  =>
																																			  {
'rank'
																																				  =>
'family',
'self_count'
																																				  =>
'0',
'tax_id'
																																				  =>
'10139',
'taxon'
																																				  =>
																																				  {
'name'
																																					  =>
'Cavia',
'rank'
																																					  =>
'genus',
'self_count'
																																					  =>
'0',
'tax_id'
																																					  =>
'10140',
'taxon'
																																					  =>
																																					  {
'name'
																																						  =>
'Cavia porcellus',
'rank'
																																						  =>
'species',
'self_count'
																																						  =>
'14',
'tax_id'
																																						  =>
'10141',
'total_count'
																																						  =>
'14'
																																					  }
																																					,
'total_count'
																																					  =>
'14'
																																				  }
																																				,
'total_count'
																																				  =>
'14'
																																			  }
																																		  }
																																		,
'total_count'
																																		  =>
'59'
																																	  }
																																	,
'Sciurognathi'
																																	  =>
																																	  {
'rank'
																																		  =>
'suborder',
'self_count'
																																		  =>
'0',
'tax_id'
																																		  =>
'33553',
'taxon'
																																		  =>
																																		  {
'name'
																																			  =>
'Muroidea',
'self_count'
																																			  =>
'0',
'tax_id'
																																			  =>
'337687',
'taxon'
																																			  =>
																																			  {
'name'
																																				  =>
'Muridae',
'rank'
																																				  =>
'family',
'self_count'
																																				  =>
'0',
'tax_id'
																																				  =>
'10066',
'taxon'
																																				  =>
																																				  {
'name'
																																					  =>
'Murinae',
'rank'
																																					  =>
'subfamily',
'self_count'
																																					  =>
'0',
'tax_id'
																																					  =>
'39107',
'taxon'
																																					  =>
																																					  {
'name'
																																						  =>
'Mus',
'rank'
																																						  =>
'genus',
'self_count'
																																						  =>
'0',
'tax_id'
																																						  =>
'10088',
'taxon'
																																						  =>
																																						  {
'name'
																																							  =>
'Mus',
'rank'
																																							  =>
'subgenus',
'self_count'
																																							  =>
'0',
'tax_id'
																																							  =>
'862507',
'taxon'
																																							  =>
																																							  {
'name'
																																								  =>
'Mus musculus',
'rank'
																																								  =>
'species',
'self_count'
																																								  =>
'907',
'tax_id'
																																								  =>
'10090',
'total_count'
																																								  =>
'907'
																																							  }
																																							,
'total_count'
																																							  =>
'907'
																																						  }
																																						,
'total_count'
																																						  =>
'907'
																																					  }
																																					,
'total_count'
																																					  =>
'907'
																																				  }
																																				,
'total_count'
																																				  =>
'907'
																																			  }
																																			,
'total_count'
																																			  =>
'907'
																																		  }
																																		,
'total_count'
																																		  =>
'907'
																																	  }
																																  }
																																,
'total_count'
																																  =>
'966'
																															  }
																															,
'total_count'
																															  =>
'966'
																														  }
																														,
'Primates'
																														  =>
																														  {
'rank'
																															  =>
'order',
'self_count'
																															  =>
'360469',
'tax_id'
																															  =>
'9443',
'taxon'
																															  =>
																															  {
'Haplorrhini'
																																  =>
																																  {
'rank'
																																	  =>
'suborder',
'self_count'
																																	  =>
'98926',
'tax_id'
																																	  =>
'376913',
'taxon'
																																	  =>
																																	  {
'Simiiformes'
																																		  =>
																																		  {
'rank'
																																			  =>
'infraorder',
'self_count'
																																			  =>
'1637695',
'tax_id'
																																			  =>
'314293',
'taxon'
																																			  =>
																																			  {
'Catarrhini'
																																				  =>
																																				  {
'rank'
																																					  =>
'parvorder',
'self_count'
																																					  =>
'2218229',
'tax_id'
																																					  =>
'9526',
'taxon'
																																					  =>
																																					  {
'Cercopithecoidea'
																																						  =>
																																						  {
'rank'
																																							  =>
'superfamily',
'self_count'
																																							  =>
'0',
'tax_id'
																																							  =>
'314294',
'taxon'
																																							  =>
																																							  {
'name'
																																								  =>
'Cercopithecidae',
'rank'
																																								  =>
'family',
'self_count'
																																								  =>
'2232',
'tax_id'
																																								  =>
'9527',
'taxon'
																																								  =>
																																								  {
'Cercopithecinae'
																																									  =>
																																									  {
'rank'
																																										  =>
'subfamily',
'self_count'
																																										  =>
'1534',
'tax_id'
																																										  =>
'9528',
'taxon'
																																										  =>
																																										  {
'Cercocebus'
																																											  =>
																																											  {
'rank'
																																												  =>
'genus',
'self_count'
																																												  =>
'0',
'tax_id'
																																												  =>
'9529',
'taxon'
																																												  =>
																																												  {
'name'
																																													  =>
'Cercocebus atys',
'rank'
																																													  =>
'species',
'self_count'
																																													  =>
'221',
'tax_id'
																																													  =>
'9531',
'total_count'
																																													  =>
'221'
																																												  }
																																												,
'total_count'
																																												  =>
'221'
																																											  }
																																											,
'Chlorocebus'
																																											  =>
																																											  {
'rank'
																																												  =>
'genus',
'self_count'
																																												  =>
'0',
'tax_id'
																																												  =>
'392815',
'taxon'
																																												  =>
																																												  {
'name'
																																													  =>
'Chlorocebus sabaeus',
'rank'
																																													  =>
'species',
'self_count'
																																													  =>
'523',
'tax_id'
																																													  =>
'60711',
'total_count'
																																													  =>
'523'
																																												  }
																																												,
'total_count'
																																												  =>
'523'
																																											  }
																																											,
'Macaca'
																																											  =>
																																											  {
'rank'
																																												  =>
'genus',
'self_count'
																																												  =>
'319',
'tax_id'
																																												  =>
'9539',
'taxon'
																																												  =>
																																												  {
'name'
																																													  =>
'Macaca nemestrina',
'rank'
																																													  =>
'species',
'self_count'
																																													  =>
'163',
'tax_id'
																																													  =>
'9545',
'total_count'
																																													  =>
'163'
																																												  }
																																												,
'total_count'
																																												  =>
'482'
																																											  }
																																											,
'Mandrillus'
																																											  =>
																																											  {
'rank'
																																												  =>
'genus',
'self_count'
																																												  =>
'0',
'tax_id'
																																												  =>
'9567',
'taxon'
																																												  =>
																																												  {
'name'
																																													  =>
'Mandrillus leucophaeus',
'rank'
																																													  =>
'species',
'self_count'
																																													  =>
'195',
'tax_id'
																																													  =>
'9568',
'total_count'
																																													  =>
'195'
																																												  }
																																												,
'total_count'
																																												  =>
'195'
																																											  }
																																											,
'Papio'
																																											  =>
																																											  {
'rank'
																																												  =>
'genus',
'self_count'
																																												  =>
'0',
'tax_id'
																																												  =>
'9554',
'taxon'
																																												  =>
																																												  {
'name'
																																													  =>
'Papio anubis',
'rank'
																																													  =>
'species',
'self_count'
																																													  =>
'247',
'tax_id'
																																													  =>
'9555',
'total_count'
																																													  =>
'247'
																																												  }
																																												,
'total_count'
																																												  =>
'247'
																																											  }
																																										  }
																																										,
'total_count'
																																										  =>
'3202'
																																									  }
																																									,
'Colobinae'
																																									  =>
																																									  {
'rank'
																																										  =>
'subfamily',
'self_count'
																																										  =>
'273',
'tax_id'
																																										  =>
'9569',
'taxon'
																																										  =>
																																										  {
'Colobus'
																																											  =>
																																											  {
'rank'
																																												  =>
'genus',
'self_count'
																																												  =>
'0',
'tax_id'
																																												  =>
'9570',
'taxon'
																																												  =>
																																												  {
'name'
																																													  =>
'Colobus angolensis',
'rank'
																																													  =>
'species',
'self_count'
																																													  =>
'0',
'tax_id'
																																													  =>
'54131',
'taxon'
																																													  =>
																																													  {
'name'
																																														  =>
'Colobus angolensis palliatus',
'rank'
																																														  =>
'subspecies',
'self_count'
																																														  =>
'533',
'tax_id'
																																														  =>
'336983',
'total_count'
																																														  =>
'533'
																																													  }
																																													,
'total_count'
																																													  =>
'533'
																																												  }
																																												,
'total_count'
																																												  =>
'533'
																																											  }
																																											,
'Rhinopithecus'
																																											  =>
																																											  {
'rank'
																																												  =>
'genus',
'self_count'
																																												  =>
'0',
'tax_id'
																																												  =>
'542827',
'taxon'
																																												  =>
																																												  {
'name'
																																													  =>
'Rhinopithecus roxellana',
'rank'
																																													  =>
'species',
'self_count'
																																													  =>
'567',
'tax_id'
																																													  =>
'61622',
'total_count'
																																													  =>
'567'
																																												  }
																																												,
'total_count'
																																												  =>
'567'
																																											  }
																																										  }
																																										,
'total_count'
																																										  =>
'1373'
																																									  }
																																								  }
																																								,
'total_count'
																																								  =>
'6807'
																																							  }
																																							,
'total_count'
																																							  =>
'6807'
																																						  }
																																						,
'Hominoidea'
																																						  =>
																																						  {
'rank'
																																							  =>
'superfamily',
'self_count'
																																							  =>
'1471662',
'tax_id'
																																							  =>
'314295',
'taxon'
																																							  =>
																																							  {
'Hominidae'
																																								  =>
																																								  {
'rank'
																																									  =>
'family',
'self_count'
																																									  =>
'1080775',
'tax_id'
																																									  =>
'9604',
'taxon'
																																									  =>
																																									  {
'Homininae'
																																										  =>
																																										  {
'rank'
																																											  =>
'subfamily',
'self_count'
																																											  =>
'2820018',
'tax_id'
																																											  =>
'207598',
'taxon'
																																											  =>
																																											  {
'Gorilla'
																																												  =>
																																												  {
'rank'
																																													  =>
'genus',
'self_count'
																																													  =>
'0',
'tax_id'
																																													  =>
'9592',
'taxon'
																																													  =>
																																													  {
'name'
																																														  =>
'Gorilla gorilla',
'rank'
																																														  =>
'species',
'self_count'
																																														  =>
'0',
'tax_id'
																																														  =>
'9593',
'taxon'
																																														  =>
																																														  {
'name'
																																															  =>
'Gorilla gorilla gorilla',
'rank'
																																															  =>
'subspecies',
'self_count'
																																															  =>
'3143',
'tax_id'
																																															  =>
'9595',
'total_count'
																																															  =>
'3143'
																																														  }
																																														,
'total_count'
																																														  =>
'3143'
																																													  }
																																													,
'total_count'
																																													  =>
'3143'
																																												  }
																																												,
'Homo'
																																												  =>
																																												  {
'rank'
																																													  =>
'genus',
'self_count'
																																													  =>
'228',
'tax_id'
																																													  =>
'9605',
'taxon'
																																													  =>
																																													  {
'name'
																																														  =>
'Homo sapiens',
'rank'
																																														  =>
'species',
'self_count'
																																														  =>
'1470850',
'tax_id'
																																														  =>
'9606',
'taxon'
																																														  =>
																																														  {
'name'
																																															  =>
'Homo sapiens neanderthalensis',
'rank'
																																															  =>
'subspecies',
'self_count'
																																															  =>
'3',
'tax_id'
																																															  =>
'63221',
'total_count'
																																															  =>
'3'
																																														  }
																																														,
'total_count'
																																														  =>
'1470853'
																																													  }
																																													,
'total_count'
																																													  =>
'1471081'
																																												  }
																																												,
'Pan'
																																												  =>
																																												  {
'rank'
																																													  =>
'genus',
'self_count'
																																													  =>
'5576',
'tax_id'
																																													  =>
'9596',
'taxon'
																																													  =>
																																													  {
'Pan paniscus'
																																														  =>
																																														  {
'rank'
																																															  =>
'species',
'self_count'
																																															  =>
'1614',
'tax_id'
																																															  =>
'9597',
'total_count'
																																															  =>
'1614'
																																														  }
																																														,
'Pan troglodytes'
																																														  =>
																																														  {
'rank'
																																															  =>
'species',
'self_count'
																																															  =>
'2177',
'tax_id'
																																															  =>
'9598',
'total_count'
																																															  =>
'2177'
																																														  }
																																													  }
																																													,
'total_count'
																																													  =>
'9367'
																																												  }
																																											  }
																																											,
'total_count'
																																											  =>
'4303609'
																																										  }
																																										,
'Ponginae'
																																										  =>
																																										  {
'rank'
																																											  =>
'subfamily',
'self_count'
																																											  =>
'0',
'tax_id'
																																											  =>
'607660',
'taxon'
																																											  =>
																																											  {
'name'
																																												  =>
'Pongo',
'rank'
																																												  =>
'genus',
'self_count'
																																												  =>
'0',
'tax_id'
																																												  =>
'9599',
'taxon'
																																												  =>
																																												  {
'name'
																																													  =>
'Pongo abelii',
'rank'
																																													  =>
'species',
'self_count'
																																													  =>
'2043',
'tax_id'
																																													  =>
'9601',
'total_count'
																																													  =>
'2043'
																																												  }
																																												,
'total_count'
																																												  =>
'2043'
																																											  }
																																											,
'total_count'
																																											  =>
'2043'
																																										  }
																																									  }
																																									,
'total_count'
																																									  =>
'5386427'
																																								  }
																																								,
'Hylobatidae'
																																								  =>
																																								  {
'rank'
																																									  =>
'family',
'self_count'
																																									  =>
'0',
'tax_id'
																																									  =>
'9577',
'taxon'
																																									  =>
																																									  {
'name'
																																										  =>
'Nomascus',
'rank'
																																										  =>
'genus',
'self_count'
																																										  =>
'0',
'tax_id'
																																										  =>
'325165',
'taxon'
																																										  =>
																																										  {
'name'
																																											  =>
'Nomascus leucogenys',
'rank'
																																											  =>
'species',
'self_count'
																																											  =>
'1616',
'tax_id'
																																											  =>
'61853',
'total_count'
																																											  =>
'1616'
																																										  }
																																										,
'total_count'
																																										  =>
'1616'
																																									  }
																																									,
'total_count'
																																									  =>
'1616'
																																								  }
																																							  }
																																							,
'total_count'
																																							  =>
'6859705'
																																						  }
																																					  }
																																					,
'total_count'
																																					  =>
'9084741'
																																				  }
																																				,
'Platyrrhini'
																																				  =>
																																				  {
'rank'
																																					  =>
'parvorder',
'self_count'
																																					  =>
'490',
'tax_id'
																																					  =>
'9479',
'taxon'
																																					  =>
																																					  {
'Aotidae'
																																						  =>
																																						  {
'rank'
																																							  =>
'family',
'self_count'
																																							  =>
'0',
'tax_id'
																																							  =>
'376918',
'taxon'
																																							  =>
																																							  {
'name'
																																								  =>
'Aotus',
'rank'
																																								  =>
'genus',
'self_count'
																																								  =>
'0',
'tax_id'
																																								  =>
'9504',
'taxon'
																																								  =>
																																								  {
'name'
																																									  =>
'Aotus nancymaae',
'rank'
																																									  =>
'species',
'self_count'
																																									  =>
'479',
'tax_id'
																																									  =>
'37293',
'total_count'
																																									  =>
'479'
																																								  }
																																								,
'total_count'
																																								  =>
'479'
																																							  }
																																							,
'total_count'
																																							  =>
'479'
																																						  }
																																						,
'Cebidae'
																																						  =>
																																						  {
'rank'
																																							  =>
'family',
'self_count'
																																							  =>
'124',
'tax_id'
																																							  =>
'9498',
'taxon'
																																							  =>
																																							  {
'Callitrichinae'
																																								  =>
																																								  {
'rank'
																																									  =>
'subfamily',
'self_count'
																																									  =>
'0',
'tax_id'
																																									  =>
'9480',
'taxon'
																																									  =>
																																									  {
'name'
																																										  =>
'Callithrix',
'rank'
																																										  =>
'genus',
'self_count'
																																										  =>
'0',
'tax_id'
																																										  =>
'9481',
'taxon'
																																										  =>
																																										  {
'name'
																																											  =>
'Callithrix jacchus',
'rank'
																																											  =>
'species',
'self_count'
																																											  =>
'549',
'tax_id'
																																											  =>
'9483',
'total_count'
																																											  =>
'549'
																																										  }
																																										,
'total_count'
																																										  =>
'549'
																																									  }
																																									,
'total_count'
																																									  =>
'549'
																																								  }
																																								,
'Saimiriinae'
																																								  =>
																																								  {
'rank'
																																									  =>
'subfamily',
'self_count'
																																									  =>
'0',
'tax_id'
																																									  =>
'378850',
'taxon'
																																									  =>
																																									  {
'name'
																																										  =>
'Saimiri',
'rank'
																																										  =>
'genus',
'self_count'
																																										  =>
'0',
'tax_id'
																																										  =>
'9520',
'taxon'
																																										  =>
																																										  {
'name'
																																											  =>
'Saimiri boliviensis',
'rank'
																																											  =>
'species',
'self_count'
																																											  =>
'0',
'tax_id'
																																											  =>
'27679',
'taxon'
																																											  =>
																																											  {
'name'
																																												  =>
'Saimiri boliviensis boliviensis',
'rank'
																																												  =>
'subspecies',
'self_count'
																																												  =>
'490',
'tax_id'
																																												  =>
'39432',
'total_count'
																																												  =>
'490'
																																											  }
																																											,
'total_count'
																																											  =>
'490'
																																										  }
																																										,
'total_count'
																																										  =>
'490'
																																									  }
																																									,
'total_count'
																																									  =>
'490'
																																								  }
																																							  }
																																							,
'total_count'
																																							  =>
'1163'
																																						  }
																																					  }
																																					,
'total_count'
																																					  =>
'2132'
																																				  }
																																			  }
																																			,
'total_count'
																																			  =>
'10724568'
																																		  }
																																		,
'Tarsiiformes'
																																		  =>
																																		  {
'rank'
																																			  =>
'infraorder',
'self_count'
																																			  =>
'0',
'tax_id'
																																			  =>
'376912',
'taxon'
																																			  =>
																																			  {
'name'
																																				  =>
'Tarsiidae',
'rank'
																																				  =>
'family',
'self_count'
																																				  =>
'0',
'tax_id'
																																				  =>
'9475',
'taxon'
																																				  =>
																																				  {
'name'
																																					  =>
'Carlito',
'rank'
																																					  =>
'genus',
'self_count'
																																					  =>
'0',
'tax_id'
																																					  =>
'1868481',
'taxon'
																																					  =>
																																					  {
'name'
																																						  =>
'Carlito syrichta',
'rank'
																																						  =>
'species',
'self_count'
																																						  =>
'350',
'tax_id'
																																						  =>
'9478',
'total_count'
																																						  =>
'350'
																																					  }
																																					,
'total_count'
																																					  =>
'350'
																																				  }
																																				,
'total_count'
																																				  =>
'350'
																																			  }
																																			,
'total_count'
																																			  =>
'350'
																																		  }
																																	  }
																																	,
'total_count'
																																	  =>
'10823844'
																																  }
																																,
'Strepsirrhini'
																																  =>
																																  {
'rank'
																																	  =>
'suborder',
'self_count'
																																	  =>
'0',
'tax_id'
																																	  =>
'376911',
'taxon'
																																	  =>
																																	  {
'name'
																																		  =>
'Lemuriformes',
'rank'
																																		  =>
'infraorder',
'self_count'
																																		  =>
'0',
'tax_id'
																																		  =>
'376915',
'taxon'
																																		  =>
																																		  {
'name'
																																			  =>
'Cheirogaleidae',
'rank'
																																			  =>
'family',
'self_count'
																																			  =>
'0',
'tax_id'
																																			  =>
'30615',
'taxon'
																																			  =>
																																			  {
'name'
																																				  =>
'Microcebus',
'rank'
																																				  =>
'genus',
'self_count'
																																				  =>
'0',
'tax_id'
																																				  =>
'13149',
'taxon'
																																				  =>
																																				  {
'name'
																																					  =>
'Microcebus murinus',
'rank'
																																					  =>
'species',
'self_count'
																																					  =>
'78',
'tax_id'
																																					  =>
'30608',
'total_count'
																																					  =>
'78'
																																				  }
																																				,
'total_count'
																																				  =>
'78'
																																			  }
																																			,
'total_count'
																																			  =>
'78'
																																		  }
																																		,
'total_count'
																																		  =>
'78'
																																	  }
																																	,
'total_count'
																																	  =>
'78'
																																  }
																															  }
																															,
'total_count'
																															  =>
'11184391'
																														  }
																													  }
																													,
'total_count'
																													  =>
'11404730'
																												  }
																												,
'Laurasiatheria'
																												  =>
																												  {
'rank'
																													  =>
'superorder',
'self_count'
																													  =>
'188',
'tax_id'
																													  =>
'314145',
'taxon'
																													  =>
																													  {
'Carnivora'
																														  =>
																														  {
'rank'
																															  =>
'order',
'self_count'
																															  =>
'0',
'tax_id'
																															  =>
'33554',
'taxon'
																															  =>
																															  {
'name'
																																  =>
'Feliformia',
'rank'
																																  =>
'suborder',
'self_count'
																																  =>
'0',
'tax_id'
																																  =>
'379583',
'taxon'
																																  =>
																																  {
'name'
																																	  =>
'Felidae',
'rank'
																																	  =>
'family',
'self_count'
																																	  =>
'0',
'tax_id'
																																	  =>
'9681',
'taxon'
																																	  =>
																																	  {
'name'
																																		  =>
'Acinonychinae',
'rank'
																																		  =>
'subfamily',
'self_count'
																																		  =>
'0',
'tax_id'
																																		  =>
'338151',
'taxon'
																																		  =>
																																		  {
'name'
																																			  =>
'Acinonyx',
'rank'
																																			  =>
'genus',
'self_count'
																																			  =>
'0',
'tax_id'
																																			  =>
'32535',
'taxon'
																																			  =>
																																			  {
'name'
																																				  =>
'Acinonyx jubatus',
'rank'
																																				  =>
'species',
'self_count'
																																				  =>
'5',
'tax_id'
																																				  =>
'32536',
'total_count'
																																				  =>
'5'
																																			  }
																																			,
'total_count'
																																			  =>
'5'
																																		  }
																																		,
'total_count'
																																		  =>
'5'
																																	  }
																																	,
'total_count'
																																	  =>
'5'
																																  }
																																,
'total_count'
																																  =>
'5'
																															  }
																															,
'total_count'
																															  =>
'5'
																														  }
																														,
'Cetartiodactyla'
																														  =>
																														  {
'self_count'
																															  =>
'0',
'tax_id'
																															  =>
'91561',
'taxon'
																															  =>
																															  {
'Cetacea'
																																  =>
																																  {
'rank'
																																	  =>
'order',
'self_count'
																																	  =>
'38',
'tax_id'
																																	  =>
'9721',
'total_count'
																																	  =>
'38'
																																  }
																																,
'Tylopoda'
																																  =>
																																  {
'rank'
																																	  =>
'suborder',
'self_count'
																																	  =>
'0',
'tax_id'
																																	  =>
'9834',
'taxon'
																																	  =>
																																	  {
'name'
																																		  =>
'Camelidae',
'rank'
																																		  =>
'family',
'self_count'
																																		  =>
'0',
'tax_id'
																																		  =>
'9835',
'taxon'
																																		  =>
																																		  {
'name'
																																			  =>
'Camelus',
'rank'
																																			  =>
'genus',
'self_count'
																																			  =>
'11',
'tax_id'
																																			  =>
'9836',
'total_count'
																																			  =>
'11'
																																		  }
																																		,
'total_count'
																																		  =>
'11'
																																	  }
																																	,
'total_count'
																																	  =>
'11'
																																  }
																															  }
																															,
'total_count'
																															  =>
'49'
																														  }
																														,
'Chiroptera'
																														  =>
																														  {
'rank'
																															  =>
'order',
'self_count'
																															  =>
'0',
'tax_id'
																															  =>
'9397',
'taxon'
																															  =>
																															  {
'name'
																																  =>
'Megachiroptera',
'rank'
																																  =>
'suborder',
'self_count'
																																  =>
'0',
'tax_id'
																																  =>
'30559',
'taxon'
																																  =>
																																  {
'name'
																																	  =>
'Pteropodidae',
'rank'
																																	  =>
'family',
'self_count'
																																	  =>
'0',
'tax_id'
																																	  =>
'9398',
'taxon'
																																	  =>
																																	  {
'name'
																																		  =>
'Pteropodinae',
'rank'
																																		  =>
'subfamily',
'self_count'
																																		  =>
'0',
'tax_id'
																																		  =>
'77225',
'taxon'
																																		  =>
																																		  {
'name'
																																			  =>
'Rousettus',
'rank'
																																			  =>
'genus',
'self_count'
																																			  =>
'0',
'tax_id'
																																			  =>
'9406',
'taxon'
																																			  =>
																																			  {
'name'
																																				  =>
'Rousettus aegyptiacus',
'rank'
																																				  =>
'species',
'self_count'
																																				  =>
'8',
'tax_id'
																																				  =>
'9407',
'total_count'
																																				  =>
'8'
																																			  }
																																			,
'total_count'
																																			  =>
'8'
																																		  }
																																		,
'total_count'
																																		  =>
'8'
																																	  }
																																	,
'total_count'
																																	  =>
'8'
																																  }
																																,
'total_count'
																																  =>
'8'
																															  }
																															,
'total_count'
																															  =>
'8'
																														  }
																														,
'Perissodactyla'
																														  =>
																														  {
'rank'
																															  =>
'order',
'self_count'
																															  =>
'0',
'tax_id'
																															  =>
'9787',
'taxon'
																															  =>
																															  {
'name'
																																  =>
'Rhinocerotidae',
'rank'
																																  =>
'family',
'self_count'
																																  =>
'0',
'tax_id'
																																  =>
'9803',
'taxon'
																																  =>
																																  {
'name'
																																	  =>
'Ceratotherium',
'rank'
																																	  =>
'genus',
'self_count'
																																	  =>
'0',
'tax_id'
																																	  =>
'9806',
'taxon'
																																	  =>
																																	  {
'name'
																																		  =>
'Ceratotherium simum',
'rank'
																																		  =>
'species',
'self_count'
																																		  =>
'0',
'tax_id'
																																		  =>
'9807',
'taxon'
																																		  =>
																																		  {
'name'
																																			  =>
'Ceratotherium simum simum',
'rank'
																																			  =>
'subspecies',
'self_count'
																																			  =>
'45',
'tax_id'
																																			  =>
'73337',
'total_count'
																																			  =>
'45'
																																		  }
																																		,
'total_count'
																																		  =>
'45'
																																	  }
																																	,
'total_count'
																																	  =>
'45'
																																  }
																																,
'total_count'
																																  =>
'45'
																															  }
																															,
'total_count'
																															  =>
'45'
																														  }
																													  }
																													,
'total_count'
																													  =>
'295'
																												  }
																											  }
																											,
'total_count'
																											  =>
'11645345'
																										  }
																									  }
																									,
'total_count'
																									  =>
'11824047'
																								  }
																								,
'total_count'
																								  =>
'11835438'
																							  }
																							,
'total_count'
																							  =>
'11841184'
																						  }
																						,
'total_count'
																						  =>
'11905581'
																					  }
																					,
'total_count'
																					  =>
'11906798'
																				  }
																				,
'total_count'
																				  =>
'11906798'
																			  },
'total_count'
																			  =>
'11908639'
																		  },
'total_count'
																		  => '11916990'
																	},
'total_count'
																	  => '11916990'
																},
																'total_count'
																  => '11918579'
															},
															'total_count' =>
															  '11918579'
														},
														'total_count' =>
														  '11918579'
													},
													'total_count' => '11918663'
												},
												'total_count' => '11919094'
											},
											'total_count' => '11939081'
										},
										'total_count' => '11939788'
									},
									'total_count' => '11939788'
								},
								'total_count' => '11943421'
							},
							'total_count' => '11988660'
						}
					},
					'total_count' => '12030103'
				}
			},
			'total_spot_count' => '25926564'
		},
		'total_bases' => '1296328200',
		'total_spots' => '25926564'
	};

}
