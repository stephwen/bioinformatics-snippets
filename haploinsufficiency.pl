#!/usr/bin/perl
#
# This script parses a dataset of haploinsuffiency probability (computed by Huang et al. http://www.plosgenetics.org/article/info%3Adoi%2F10.1371%2Fjournal.pgen.1001154)
# and annotates a list of genes provided as input
#

use strict;
use warnings;

my %hiValues;

my $dataset = shift;
my $genes = shift;

my $usage = <<EOUSAGE;
Usage: perl $0 <dataset file from Huang et al.> <gene name or gene list>

where
	- the dataset can be downloaded here:
	  http://www.plosgenetics.org/article/info%3Adoi%2F10.1371%2Fjournal.pgen.1001154#s5
	  (Dataset S2.: HI_prediction_with_imputation.bed)
	  
	- gene name can be either a single gene identifier (eg. BRCA2) or a file list containing several gene identifiers


EOUSAGE

if (!$dataset || !-f $dataset || !$genes) { die($usage); }

open(IN, "<", $dataset);
while (my $line = <IN>) {
	next if 1..1;
	chomp($line);
	my ($chr, $start, $end, $data, undef, undef, undef, undef, undef) = split(/\t/, $line);
	my ($gene, $hi, $percent) = split(/\|/, $data);
	$hiValues{$gene}{'hi'} = $hi;
	$hiValues{$gene}{'percent'} = $percent;
}
close(IN);

if (-f $genes) {
	open(IN, "<", $genes);
	my @lines = <IN>;
	close(IN);
	for my $line (@lines) {
		chomp($line);
		&noFile($line);
		print "\n";
	}
} else { &noFile($genes); }

#############################################

sub noFile {
	my $gene = shift;
	if ($hiValues{$gene}) {
		print $hiValues{$gene}{'percent'};
	} else {
		print "xxx";
	}
}