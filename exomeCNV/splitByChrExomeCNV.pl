#!/usr/bin/perl
#
# ExomeCNV requires one input file per chr. This script is used to split
# a coverage file based on chr name
#
use strict;
use warnings;

my $inputFile = shift || die("Usage: perl $0 <input file> <output prefix>\n");
my $outputPrefix = shift || die("Usage: perl $0 <input file> <output prefix>\n");

my $outputFile;
my $previousChr;

open(IN, "<", $inputFile) || die("Unable to open input file $inputFile\n");
readline(IN);	# skip first line
while (my $line = <IN>) {
	my (undef, $chr, undef, undef, undef, undef, undef, undef, undef) = split(/\t/, $line);
	if (!$previousChr || $previousChr ne $chr) {
		if ($previousChr) { close(OUT); }
		$previousChr = $chr;
		$outputFile = $outputPrefix.".".$chr.".exomeCNV.coverage.txt";
		open(OUT, ">", $outputFile);
		print OUT "probe\tchr\tprobe_start\tprobe_end\ttargeted base\tsequenced base\tcoverage\taverage coverage\tbase with >10 coverage\n";
	}
	print OUT $line;
}
close(IN);
close(OUT);