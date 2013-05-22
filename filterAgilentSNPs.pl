#!/usr/bin/perl
use strict;
use warnings;

my $file1 = "SNP1_02_GENOTYPE.csv";
my $file2 = "SNP3_10_GENOTYPE.csv";

my %SNPs1;
my %SNPs2;

my %pos;

open(IN, "<", $file1);
while (my $line = <IN>) {
	next if 1..25;
	chomp($line);
	$line =~ s/\"//g;
	my (undef, undef, undef, $rsID, $chr, $position, $genotype, undef, undef) = split(/\t/, $line);
	if ($chr eq "chrX") {
		$SNPs1{$position} = {
			"genotype"	=>	$genotype,
			"chr"		=>	$chr,
			"rsID"		=>	$rsID,
		};
		$pos{$position} = 1;
	}
}
close(IN);

open(IN, "<", $file2);
while (my $line = <IN>) {
	next if 1..25;
	chomp($line);
	$line =~ s/\"//g;
	my (undef, undef, undef, $rsID, $chr, $position, $genotype, undef, undef) = split(/\t/, $line);
	if ($chr eq "chrX") {
		$SNPs2{$position} = {
			"genotype"	=>	$genotype,
			"chr"		=>	$chr,
			"rsID"		=>	$rsID,
		};
		$pos{$position} = 1;
	}
}
close(IN);

my $i = 0;
my $j = 0;

for my $position (sort { $a <=> $b } keys %pos) {
	# if ($SNPs2{$position} && $SNPs2{$position}->{"genotype"} eq $SNPs1{$position}->{"genotype"}) {
		print $SNPs1{$position}->{"chr"}.":";
		print $position."\t";
		print $SNPs1{$position}->{"rsID"}."\t";
		if ($SNPs1{$position}->{"genotype"}) { print $SNPs1{$position}->{"genotype"}; }
		print "\t";
		if ($SNPs2{$position}->{"genotype"}) { print $SNPs2{$position}->{"genotype"}; }
		print "\n";
	# }
	
	if ($SNPs1{$position}->{"genotype"} && $SNPs2{$position}->{"genotype"} && ($SNPs1{$position}->{"genotype"} eq $SNPs2{$position}->{"genotype"} &&  $SNPs1{$position}->{"genotype"} ne "NN" )) { $i++; } else { $j++; }
}

print "\nSNPs identiques : $i\n";
print "SNPs differents : $j\n";
