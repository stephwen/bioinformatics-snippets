#!/usr/bin/perl
#
# This script is used to detect runs of deletions in SNP �-arrays based on export file generated by
# Illumina GenomeStudio. Exported files should contain these columns:
# individualId	chr	pos	alleleA	alleleB
#
# The min number of consecutive SNPs with no alleles is set to 3.
#
use strict;
use warnings;
use File::Temp qw/ tempfile /;

my $minConsecutiveDels = 3;

my $exportFile = shift || die("Usage: perl $0 <export file>\n");
if (!-f $exportFile) {die("Unable to open input file $exportFile\n"); }

my $tmp = File::Temp->new(TEMPLATE => 'tempXXXXX');
my $tmpFilename1 = $tmp->filename(); 
my $cmd = "sed 1,11d $exportFile > $tmpFilename1";
system($cmd);

my $tmp2 = File::Temp->new(TEMPLATE => 'tempXXXXX');
my $tmpFilename2 = $tmp2->filename();
$cmd = "sort -k1,1 -k2,2 -k3,3n $tmpFilename1 > $tmpFilename2";
system($cmd);


my $currentDel;
my @allDels;

open(IN, "<", $tmpFilename2);
while (my $line = <IN>) {
	chomp($line);
	my ($sampleId, $chr, $pos, $allele1, $allele2) = split(/\t/, $line);
	next if ($pos == 0);
	if (!($allele1 eq "-" && $allele2 eq "-")) {
		# cloturer currentDel
		if ($currentDel->{'current'}) {
			$currentDel->{'end'} = $currentDel->{'current'};
			push(@allDels, $currentDel);
		}
		$currentDel = {};
	} else {
		if (!$currentDel->{'chr'}) {
			$currentDel->{'chr'} = $chr;
			$currentDel->{'start'} = $pos;
			$currentDel->{'count'} = 1;
			$currentDel->{'current'} = $pos;
		} elsif ($currentDel->{'chr'} eq $chr) {
			# allonger currentDel
			$currentDel->{'count'}++;
			$currentDel->{'current'} = $pos;
		} elsif ($currentDel->{'chr'} ne $chr) {
			# cloturer currentDel si ouverte
        		if ($currentDel->{'current'}) {
			        $currentDel->{'end'} = $currentDel->{'current'};
	        	        push(@allDels, $currentDel);
			}
			# creer currentDel
                        $currentDel->{'chr'} = $chr;
                        $currentDel->{'start'} = $pos;
                        $currentDel->{'count'} = 1;
                        $currentDel->{'current'} = $pos;
		}
	}
}
close(IN);
# cloturer currentDel
if ($currentDel->{'current'}) {
	$currentDel->{'end'} = $currentDel->{'current'};
	push(@allDels, $currentDel);
}

foreach my $deletion (@allDels) {
	if ($deletion->{'count'} >= $minConsecutiveDels) {
		print $deletion->{'chr'}."\t".$deletion->{'start'}." - ".$deletion->{'end'}."\t".$deletion->{'count'}."\n";
	}
}
