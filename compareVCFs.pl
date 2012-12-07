#!/usr/bin/perl
#
# This script compares 2 VCF files containings variants.
#
# It outputs VCF files with variants present in
# * both input VCF files
# * 1st VCF file only
# * 2nd VCF file only
#
# It also writes out some basic statistics regarding the number of variants
# present in each file.
#
# WARNING: for now, 2 variants are considered equal if their
# chr and position are the same
#
# In future versions, variant features which will be compared will be user-specified
# (chr, pos, alt1, alt2, %alt1, etc.)
#
use strict;
use warnings;

my $file1 = shift;
my $file2 = shift;
my $outputDir = shift;

if (!$file1 || !$file2 || !$outputDir) {
	die("Usage: perl $0 VCF1 VCF2 outputDirectory\n");
}

if (!-d $outputDir) {
	mkdir($outputDir) || die("Unable to create directory $outputDir\n");
} else {
	print "directory $outputDir exists\n";
}

my $vcf1OnlyFile = $outputDir."/VCF1Only.vcf";
my $vcf2OnlyFile = $outputDir."/VCF2Only.vcf";
my $intersectionFile = $outputDir."/intersection.vcf";
my $statsFile = $outputDir."/stats.txt";

my %variants1;
my %variants2;

my %intersection;
my %vcf1only;
my %vcf2only;

my $nbVariants1 = 0;
my $nbVariants2 = 0;
my $nbVCF1 = 0;
my $nbVCF2 = 0;
my $nbInter = 0;

open(IN, "<", $file1) || die("Unable to open file $file1\n");
while(my $line = <IN>) {
	next if $line =~ /^#/;
	chomp($line);
	my ($chr, $pos, $rsId, $ref, $alt, $score, $pass, $misc) = split(/\t/, $line);
	$variants1{$chr}{$pos} = $line;
	$nbVariants1++;
}
close(IN);

open(IN, "<", $file2) || die("Unable to open file $file2\n");
while(my $line = <IN>) {
	next if $line =~ /^#/;
	chomp($line);
	my ($chr, $pos, $rsId, $ref, $alt, $score, $pass, $misc) = split(/\t/, $line);
	$variants2{$chr}{$pos} = $line;
	$nbVariants2++;
}
close(IN);

open(VCF1ONLY, ">", $vcf1OnlyFile) || die("Unable to open $vcf1OnlyFile for writing\n");
open(INTER, ">", $intersectionFile) || die("Unable to open $intersectionFile for writing\n");
for my $chr1 (sort sortChr keys %variants1) {
	for my $pos1 (sort keys %{$variants1{$chr1}}) {
		if ($variants2{$chr1}{$pos1}) {
			# intersection
			$intersection{$chr1}{$pos1} = $variants1{$chr1}{$pos1};
			print INTER $intersection{$chr1}{$pos1}."\n";
			$nbInter++;
		} else {
			# vcf1 onlyxµ
			$vcf1only{$chr1}{$pos1} = $variants1{$chr1}{$pos1};
			print VCF1ONLY $vcf1only{$chr1}{$pos1}."\n";
			$nbVCF1++;
		}
	}
}
close(VCF1ONLY);
close(INTER);

open(VCF2ONLY, ">", $vcf2OnlyFile) || die("Unable to open $vcf2OnlyFile for writing\n");
for my $chr2 (sort sortChr keys %variants2) {
	for my $pos2 (sort keys %{$variants2{$chr2}}) {
		if (!$variants1{$chr2}{$pos2}) {
			$vcf2only{$chr2}{$pos2} = $variants2{$chr2}{$pos2};
			print VCF2ONLY $vcf2only{$chr2}{$pos2}."\n";
			$nbVCF2++;
		}
	}
}
close(VCF2ONLY);

open(OUT, ">", $statsFile);
print "VCF1: $file1\n";
print OUT "VCF1: $file1\n";
print "VCF2: $file2\n";
print OUT "VCF2: $file2\n";
print "nb variants VCF1: $nbVariants1\n";
print OUT "nb variants VCF1: $nbVariants1\n";
print "nb variants VCF2: $nbVariants2\n";
print OUT "nb variants VCF2: $nbVariants2\n";
print "Intersection: $nbInter\n";
print OUT "Intersection: $nbInter\n";
print "VCF1 only: $nbVCF1\n";
print OUT "VCF1 only: $nbVCF1\n";
print "VCF2 only: $nbVCF2\n";
print OUT "VCF2 only: $nbVCF2\n";
close(OUT);


####################################################

sub sortChr {
	my $chr1 = substr($a, 3);
	my $chr2 = substr($b, 3);
	if ($chr1 =~ /\d+/ && $chr2 =~ /\D+/) { return -1; }
	if ($chr1 =~ /\D+/ && $chr2 =~ /\d+/) { return 1; }
	if ($chr1 =~ /\d+/ && $chr2 =~ /\d+/) { return $chr1 <=> $chr2; }
	if ($chr1 =~ /\D+/ && $chr2 =~ /\D+/) { return $chr1 cmp $chr2; }
}
