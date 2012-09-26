#!/usr/bin/perl
use strict;
use warnings;

print join(", ", sort sortChr ("chrX", "chr2", "chr5", "chrY", "chrMt"));


# this block can be used to sort chromosome names
# it will returnered a list of chromosome names in the usual order
# ie. autosomes first, in numerical ascending order,
# and sex chromosomes then.
sub sortChr {
	my $chr1 = substr($a, 3);
	my $chr2 = substr($b, 3);
	if ($chr1 =~ /\d+/ && $chr2 =~ /\D+/) { return -1; }
	if ($chr1 =~ /\D+/ && $chr2 =~ /\d+/) { return 1; }
	if ($chr1 =~ /\d+/ && $chr2 =~ /\d+/) { return $chr1 <=> $chr2; }
	if ($chr1 =~ /\D+/ && $chr2 =~ /\D+/) { return $chr1 cmp $chr2; }
}
