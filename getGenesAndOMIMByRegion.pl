#!/usr/bin/perl
#
# This script outputs a list of genes, and their corresponding OMIM links if available,
# when given a chromosome location or a chromosome region, or a file containing
# several chromosome locations or chromosome regions
#
use strict;
use warnings;
use Bio::EnsEMBL::Registry;

my $registry;

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
    		print "chr".$chr.":".$start."-".$end."\t$name\t";
		my @xrefs = @{ $gene->get_all_xrefs('MIM_GENE%') };
		for my $xref (@xrefs) {
			my $omimString = $xref->display_id();
			if ($omimString =~ /(\d{6})/g) {
				print "http://omim.org/entry/".$1." ";
			}
		}
		print "\n";
	}
}

sub loadEnsembl {
	$registry = 'Bio::EnsEMBL::Registry';

	$registry->load_registry_from_db(
	    -host => 'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
	    -user => 'anonymous'
	);
}