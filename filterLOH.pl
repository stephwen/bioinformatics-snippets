#!/usr/bin/perl
#
# This script takes as input 3 files listing LOH regions and computes
# common regions and regions present in only one of the two samples.
#
use strict;
use warnings;
use Set::IntSpan qw(grep_set map_set grep_spans map_spans );


use Data::Dumper;


my $file1 = shift;
my $file2 = shift;
my $file3 = shift;

my %runs1;
my %runs2;
my %runs3;

my %runs1Only;
my %runs2Only;
my %runs3Only;

my %runs1vs2;
my %runs1vs3;
my %runs2vs3;

my %runs1vs2vs3;


open(IN, "<", $file1) || die("Unable to open $file1\n");
while (my $line = <IN>) {
	chomp($line);
	my ($Chr, $Start, $Stop) = ($line =~ /(\w*[\d\w]+):(\d+)-(\d+)/);
	if ($runs1{$Chr}) {
		my $new = new Set::IntSpan $Start."-".$Stop;
		$runs1{$Chr}->U($new);
	} else {
		$runs1{$Chr} = new Set::IntSpan $Start."-".$Stop;
	}
}
close(IN);

open(IN, "<", $file2) || die("Unable to open $file2\n");
while (my $line = <IN>) {
	chomp($line);
	my ($Chr, $Start, $Stop) = ($line =~ /(\w*[\d\w]+):(\d+)-(\d+)/);
	if ($runs2{$Chr}) {
		my $new = new Set::IntSpan $Start."-".$Stop;
		$runs2{$Chr}->U($new);
	} else {
		$runs2{$Chr} = new Set::IntSpan $Start."-".$Stop;
	}
}
close(IN);

open(IN, "<", $file3) || die("Unable to open $file3\n");
while (my $line = <IN>) {
	chomp($line);
	my ($Chr, $Start, $Stop) = ($line =~ /(\w*[\d\w]+):(\d+)-(\d+)/);
	if ($runs3{$Chr}) {
		my $new = new Set::IntSpan $Start."-".$Stop;
		$runs3{$Chr}->U($new);
	} else {
		$runs3{$Chr} = new Set::IntSpan $Start."-".$Stop;
	}
}
close(IN);




print "# $file1 only\n\n";
for my $chr (sort sortChr keys %runs1) {
	my $runs1Only = $runs1{$chr}->diff($runs2{$chr})->diff($runs3{$chr});
	for ($runs1Only->sets) { print $chr.":"; print; print "\n"; }
}


print "\n\n# $file2 only\n\n";
for my $chr (sort sortChr keys %runs2) {
	my $runs2Only = $runs2{$chr}->diff($runs1{$chr})->diff($runs3{$chr});
	for ($runs2Only->sets) { print $chr.":"; print; print "\n"; }
}

print "\n\n# $file3 only\n\n";
for my $chr (sort sortChr keys %runs3) {
	my $runs3Only = $runs3{$chr}->diff($runs1{$chr})->diff($runs2{$chr});
	for ($runs3Only->sets) { print $chr.":"; print; print "\n"; }
}


print "\n\n# $file1 inter $file2 inter $file3\n\n";
for my $chr (sort sortChr keys %runs1) {
	my $intersect = $runs1{$chr}->intersect($runs2{$chr})->intersect($runs3{$chr});
	for ($intersect->sets) { print $chr.":"; print; print "\n"; }
}

print "\n\n# $file1 inter $file2\n\n";
for my $chr (sort sortChr keys %runs1) {
	my $intersect = $runs1{$chr}->intersect($runs2{$chr});
	if ($runs3{$chr}) { $intersect = $intersect->diff($runs3{$chr}); }
	for ($intersect->sets) { print $chr.":"; print; print "\n"; }
}

print "\n\n# $file1 inter $file3\n\n";
for my $chr (sort sortChr keys %runs1) {
	my $intersect = $runs1{$chr}->intersect($runs3{$chr});
	if ($runs3{$chr}) { $intersect = $intersect->diff($runs2{$chr}); }
	for ($intersect->sets) { print $chr.":"; print; print "\n"; }
}

print "\n\n# $file2 inter $file3\n\n";
for my $chr (sort sortChr keys %runs2) {
	my $intersect = $runs2{$chr}->intersect($runs3{$chr});
	if ($runs3{$chr}) { $intersect = $intersect->diff($runs1{$chr}); }
	for ($intersect->sets) { print $chr.":"; print; print "\n"; }
}



exit;


sub sortChr {
	my $chr1;
	my $chr2;
	if ($a =~ m/chr/i) { $chr1 = substr($a, 3); } else { $chr1 = $a; }
	if ($b =~ m/chr/i) { $chr2 = substr($b, 3); } else { $chr2 = $b; }
	if ($chr1 =~ /\d+/ && $chr2 =~ /\D+/) { return -1; }
	if ($chr1 =~ /\D+/ && $chr2 =~ /\d+/) { return 1; }
	if ($chr1 =~ /\d+/ && $chr2 =~ /\d+/) { return $chr1 <=> $chr2; }
	if ($chr1 =~ /\D+/ && $chr2 =~ /\D+/) { return $chr1 cmp $chr2; }
}
