#!/usr/bin/perl
use strict;
use warnings;

print join(", ", sort sortChr ("chrX", "chr2", "chr5", "chrY", "chrMt"));

print join(", ", sort sortCyto ("p12", "p13.5", "p13.2", "p15.3", "q31.2", "q31.3", "q32", "q33.1", "q33.2", "p14.1", "p12.2", "p15.33", "q11.1"));

# this block can be used to sort chromosome names
# it will return a list of chromosome names in the usual order
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

# this block can be used to sort cytoband names
# will return p arm first, q arm second
# p bands are ordered in decreasing order
# q bands are ordered in increasing order
sub sortCyto {
	my $arm1 = substr($a, 0, 1);
	my $arm2 = substr($b, 0, 1);
	my $band1 = substr($a, 1);
	my $band2 = substr($b, 1);
	if ($arm1 eq "p" && $arm2 eq "q") { return -1; }
	elsif ($arm1 eq "q" && $arm2 eq "p") { return 1; }
	elsif ($arm1 eq "p" && $arm2 eq "p") { return $band2 <=> $band1; }
	elsif ($arm1 eq "q" && $arm2 eq "q") { return $band1 <=> $band2; }
}
