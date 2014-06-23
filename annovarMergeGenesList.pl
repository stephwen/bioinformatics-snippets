#!/usr/bin/perl
#
# This script parses several genes list, as generated by the script annovarCountGenes.pl
# and generates a matrix combining the genes mutation count for each sample
#
# input:	* multiple annovarCountGenes.pl output files (format: <gene name> TAB <number of mutations>)
#
# output:	* matrix combining all the info
#

use strict;
use warnings;
use Text::CSV;
use Data::Dumper;

my $usage = <<EOUSAGE;
Usage: perl $0 <annovarCountGenes.pl output file 1> ... <annovarCountGenes.pl output file n>
EOUSAGE

if (!@ARGV) { die($usage); }

my %genes;	# key1: gene name, key2: sample name, key3: number of mutations
my @samples;

foreach my $file (@ARGV) {
	if(!$file || !-f $file) { die($usage); }
	$file =~ /([a-zA-Z0-9]+)_(\*)?/;
	my $sampleName = $1;
	push(@samples, $sampleName);

	open(my $in, "<", $file);
	while (my $line = <$in>) {
		chomp($line);
		my ($gene, $nbMut) = split(/\t/, $line);
		$genes{$gene}{'samples'}{$sampleName} = $nbMut;
		$genes{$gene}{'nbSamples'}++;
	}
	close($in);
}

print "gene";
for my $sample (sort {$a cmp $b} @samples) {
	print "\t".$sample;
}

print "\n";

for my $gene (sort { $genes{$b}{'nbSamples'} <=> $genes{$a}{'nbSamples'} } keys %genes) {
	print $gene;
	for my $sample (sort {$a cmp $b} @samples) {
		print "\t";
#		 if ($genes{$gene}{'samples'}{$sample}) { print "1"; } else { print "0"; }
		 if ($genes{$gene}{'samples'}{$sample}) { print $genes{$gene}{'samples'}{$sample}; } else { print "0"; }
	}
	print "\n";
}


#print Dumper(%genes);
