#!/usr/bin/perl
#
# This script is used to computed the average coverage per cytoband, based on the per-exon coverage
# computed with a 'hybrid' BED file, containing all exons locations, and their corresponding cytobands
#
use strict;
use warnings;

my $coverageFile = shift || die("Usage: perl $0 <coverage file>\n");

my %data;

open(IN, "<", $coverageFile);
while(my $line = <IN>) {
	chomp($line);
	my ($chr, undef, undef, $cytoband, $coverage, $nbBases, undef, undef) = split(/\t/, $line);
	if ($chr eq "all") { next; }
	if ($nbBases) {
		$data{$chr}{$cytoband}{'prod'} += $coverage*$nbBases;
		$data{$chr}{$cytoband}{'bases'} += $nbBases;
	} else {
		print "chr: $chr\n";
		print "cytoband: $cytoband\n";
		print "coverage: $coverage\n";
		print "nbBases: $nbBases\n";
		<>;
	}
}
close(IN);

for my $chr (sort sortChr keys %data) {
	for my $cytoband (keys %{$data{$chr}}) {
		my $prod = $data{$chr}{$cytoband}{'prod'};
		my $nbBases = $data{$chr}{$cytoband}{'bases'};
		if ($nbBases) {
			my $coverage = int($prod/$nbBases);
			print "$chr\t$cytoband\t$coverage\n";
		}
	}
}

sub sortChr {
	my $chr1 = substr($a, 3);
	my $chr2 = substr($b, 3);
	if ($chr1 =~ /\d+/ && $chr2 =~ /\D+/) { return -1; }
	elsif ($chr1 =~ /\D+/ && $chr2 =~ /\d+/) { return 1; }
	elsif ($chr1 =~ /\d+/ && $chr2 =~ /\d+/) { return $chr1 <=> $chr2; }
	elsif ($chr1 =~ /\D+/ && $chr2 =~ /\D+/) { return $chr1 cmp $chr2; }
}