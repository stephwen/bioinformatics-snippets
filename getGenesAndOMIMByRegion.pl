#!/usr/bin/perl
#
# This script takes as input either
# * a chromosome location,
# * a chromosomal region,
# * a file containing several chromosome locations or chromosome regions
# and it outputs 
# a list of genes, with their corresponding OMIM and OMIM Morbid links if available,
# and the phenotype description, if available from OMIM.
#
# Output format:
# chr:start-end    gene name    OMIM links    OMIM Morbid links	Phenotype
#
use strict;
use warnings;
use Bio::EnsEMBL::Registry;
use XML::Simple;
use LWP::Simple;
use Time::HiRes qw( usleep ualarm );

my $registry;
my $OMIMAPIKey = "Replace this with your own OMIM API key";

my $stdin = shift;

my $usage = <<EOUSAGE;
Usage: perl $0 <region>

where region can be one of the following:
\t * chr9:12211256-12233256
\t * chr9:12211260
\t * listOfRegions.txt	(file containing a list of the above formats)

EOUSAGE

if(!$stdin) { die($usage); }

if (-f $stdin) {
	open(IN, "<", $stdin);
	my @lines = <IN>;
	close(IN);
	&loadEnsembl;
	for my $line (@lines) {
		chomp($line);
		&noFile($line);
		print "\n";
	}
} else {
	&noFile($stdin);
}

sub noFile {
	my $stdin = shift;
	if ($stdin =~ m/.+:\d+-\d+/) {
	        &loadEnsembl;
	        &regionMode($stdin);
	} elsif ($stdin =~ m/.+:\d+/) {
	        &loadEnsembl;
	        my ($chr, $start) = split(/:/, $stdin);
	        $stdin .= "-".$start;
	        &regionMode($stdin);
	} else {
		die($usage);
	}
}

sub regionMode {
	my $stdin = shift;
        my ($chr, $span) = split(/:/, $stdin);
        my ($start, $end) = split(/-/, $span);
	if ($chr =~ m/chr/i) { $chr = substr($chr, 3); }
	my $slice_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Slice' );
	print "Region $chr:$start-$end\n\n";
	my $slice = $slice_adaptor->fetch_by_region( 'chromosome', $chr, $start, $end);
	my $genes = $slice->get_all_Genes();
	while ( my $gene = shift @{$genes} ) {
		my $start = $gene->seq_region_start();	
		my $end = $gene->seq_region_end();	
		my $name = $gene->external_name();
		my @phenotypes;
		my %OMIMNumbers;	# I use a hash instead of an array for this because of possible duplicates
		
    	print "chr".$chr.":".$start."-".$end."\t$name\t";
		
		my @xrefs = @{ $gene->get_all_xrefs('MIM_GENE%')};
		for my $xref (@xrefs) {
			my $omimString = $xref->display_id();
			if ($omimString =~ /(\d{6})/g) {
				print "http://omim.org/entry/".$1." ";
				$OMIMNumbers{$1} = 1;
			}
		}
		print "\t";
		@xrefs = @{ $gene->get_all_xrefs('MIM_MORBID%')};
		for my $xref (@xrefs) {
				my $omimString = $xref->display_id();
				if ($omimString =~ /(\d{6})/g) {
						print "http://omim.org/entry/".$1." ";
						$OMIMNumbers{$1} = 1;
				}
		}
		print "\t";
		my $toPrint = "";
		if (keys %OMIMNumbers) {
			for my $OMIMNumber (keys %OMIMNumbers) {
				usleep(300000);
				my $phenotype = &getPhenotypes($OMIMNumber);
				if ($phenotype =~ m/\S/) {
					$toPrint .= $phenotype." | ";
				}
			}
			if (length($toPrint) > 3) { $toPrint = substr($toPrint, 0, -3); }
		}
		print $toPrint."\n";
	}
}

sub loadEnsembl {
	$registry = 'Bio::EnsEMBL::Registry';

	$registry->load_registry_from_db(
	    -host => 'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
	    -user => 'anonymous'
	);
}

sub getPhenotypes {
	my $OMIMNumber = shift;
	my $return = "";
	my $url = "http://api.omim.org/api/entry?apiKey=".$OMIMAPIKey."&mimNumber=".$OMIMNumber."&include=geneMap&phenotypeExists=true";
	my $xml = get($url);
	my $xmlObject = new XML::Simple;
	my $data = $xmlObject->XMLin($xml, ForceArray => ['phenotypeMap']);

	if ($data->{'entryList'}->{'entry'}->{'geneMap'}->{'phenotypeMapList'}->{'phenotypeMap'}) {
		my @phenotypeMaps = @{$data->{'entryList'}->{'entry'}->{'geneMap'}->{'phenotypeMapList'}->{'phenotypeMap'}};
		for my $pM (@phenotypeMaps) {
			my $phenotype = $pM->{'phenotype'};
			$phenotype =~ s/\{//g;
			$phenotype =~ s/\}//g;
			if ($phenotype =~ m/\S/) {
				$return .= $phenotype." ";
			}
		}
	}

        if ($data->{'entryList'}->{'entry'}->{'phenotypeMapList'}->{'phenotypeMap'}) {
                my @phenotypeMaps = @{$data->{'entryList'}->{'entry'}->{'phenotypeMapList'}->{'phenotypeMap'}};
                for my $pM (@phenotypeMaps) {
                        my $phenotype = $pM->{'phenotype'};
                        $phenotype =~ s/\{//g;
                        $phenotype =~ s/\}//g;
                        if ($phenotype =~ m/\S/) {
                                $return .= $phenotype." ";
                        }
                }
        }


	return $return;
}
