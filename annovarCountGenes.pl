#!/usr/bin/perl
#
# This script parses the output of summarize_annovar.pl
# and counts the number of times each gene is present
#

use strict;
use warnings;

my $file = shift;
my %genes;

if (!$file || !-f $file) {	die("usage: perl $0 <annovar output>\n"); }

open(IN, "<", $file);
while (my $line = <IN>) {
	if (1..1) { next; }
	my @fields = split(/,/, $line);
	my $gene = $fields[1];
	$gene =~ s/"//g;
	if ($genes{$gene}) { $genes{$gene}++; } else { $genes{$gene} = 1; }
}
close(IN);

for my $gene (sort hashValueDescendingNum keys %genes) {
	print $gene."\t".$genes{$gene}."\n";
}

sub hashValueDescendingNum {
   $genes{$b} <=> $genes{$a};
}
