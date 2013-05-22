#!/usr/bin/perl
#
# This script will get you the cytoband name if you provide a chr and position
# It needs a cytoBand.bed file formatted this way
#
# chr1	0	2300000	p36.33
# chr1	2300000	5400000	p36.32
# chr1	5400000	7200000	p36.31
#
#

use strict;
use warnings;
use File::Basename;

my $coords = shift;
my $wd = dirname($0);
my $cytobandsBedFile = $wd."/cytoBand.bed";

if (!$coords) { die("Usage: perl $0 chr:pos\n"); }
my ($inChr, $inPos) = split(/:/, $coords);

my @bands;

open(IN, "<", $cytobandsBedFile) || die("Unable to open $cytobandsBedFile\n");
while (my $line = <IN>) {
	chomp($line);
	my ($chr, $start, $end, $bandName) = split(/\t/, $line);
	push(@bands, {
		"chr"	=>	$chr,
		"start"	=>	$start,
		"end"	=>	$end,
		"band"	=>	$bandName
	});
}
close(IN);

for my $band (@bands) {
		if ($band->{'chr'} eq $inChr && $band->{'start'} <= $inPos && $band->{'end'} >= $inPos) {
			print $band->{'chr'}."\t".$band->{'band'};
		}
}