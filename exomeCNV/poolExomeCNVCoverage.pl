#!/usr/bin/perl
#
# This script is used to 'pool' several coverage files used as input of ExomeCNV
# to produce a file containing the average of values among all samples
#
# The only fields to be averaged are coverage and average coverage.
#
use strict;
use warnings;

my $pool;	# hashRef. 	keys: chr, probe. 
			#			Value: 	lineStart: probe, chr, probe_start, probe_end, targeted base, sequenced base
			#					coverage
			#					average coverage
			#					lineEnd: base with >10 coverage

		
if (!@ARGV) { die("Usage: perl $0 <input file 1> ... <input file n>\n"); } # I should use GetOpts but this is just a quick hack.
#if (!@ARGV) { die("Usage: perl $0 <input file 1> ... <input file n> <output files prefix>\n"); } # I should use GetOpts but this is just a quick hack.
#my $outputPrefix = pop(@ARGV);
my @inputFiles = @ARGV;
my $nbSamples = $#inputFiles + 1;

foreach my $inputFile (@inputFiles) {
	open(IN, "<", $inputFile) || die("Unable to open input file $inputFile\n");
	readline(IN);	# skip first line
	while (my $line = <IN>) {
		chomp($line);
		my ($probe, $chr, $probe_start, $probe_end, $targeted_base, $sequenced_base, $coverage, $average_coverage, $base_with)
		= split(/\t/, $line);
		if ($pool->{$chr}->{$probe}) {
			$pool->{$chr}->{$probe}->{'coverage'} += $coverage;
			$pool->{$chr}->{$probe}->{'average_coverage'} += $average_coverage;		
		} else {
			$pool->{$chr}->{$probe}->{'lineStart'} = $probe."\t".$chr."\t".$probe_start."\t".$probe_end."\t".$targeted_base."\t".$sequenced_base;
			$pool->{$chr}->{$probe}->{'coverage'} = $coverage;
			$pool->{$chr}->{$probe}->{'average_coverage'} = $average_coverage;
			$pool->{$chr}->{$probe}->{'lineEnd'} = $base_with;
		}
	}
}

for my $chr (sort sortChr keys %$pool) {
	# my $outFile = $outputPrefix.".".$chr.".exomeCNV.coverage.txt";
	# open(OUT, ">", $outFile);
	print "probe\tchr\tprobe_start\tprobe_end\ttargeted base\tsequenced base\tcoverage\taverage coverage\tbase with >10 coverage\n";
	for my $probe (sort keys %{$pool->{$chr}}) {
		print $pool->{$chr}->{$probe}->{'lineStart'}."\t";
		$pool->{$chr}->{$probe}->{'coverage'} /= $nbSamples;
		print $pool->{$chr}->{$probe}->{'coverage'}."\t";
		$pool->{$chr}->{$probe}->{'average_coverage'} /= $nbSamples;
		print $pool->{$chr}->{$probe}->{'average_coverage'}."\t";
		print $pool->{$chr}->{$probe}->{'lineEnd'}."\n";
	}
	# close(OUT);
}


sub sortChr {
	my $chr1 = substr($a, 3);
	my $chr2 = substr($b, 3);
	if ($chr1 =~ /\d+/ && $chr2 =~ /\D+/) { return -1; }
	if ($chr1 =~ /\D+/ && $chr2 =~ /\d+/) { return 1; }
	if ($chr1 =~ /\d+/ && $chr2 =~ /\d+/) { return $chr1 <=> $chr2; }
	if ($chr1 =~ /\D+/ && $chr2 =~ /\D+/) { return $chr1 cmp $chr2; }
}