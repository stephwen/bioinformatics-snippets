#!/usr/bin/perl
#
# This script parses an output of annovar and filters it based on the NHLBI-ESP 6500 exome project 
# allele frequency and the 1000 Genomes project allele frequency
#
# input:	* annovar exome_summary output file
#			* min frequency (optionnal, default: 0.1)
#
# output:	file with same format as annovar exome_summary output file, but with only variants whose 
#			frequency is <= min specified frequency (default: 0.1)
#

use strict;
use warnings;
use Text::CSV;
use Data::Dumper;

my $annovarInput = shift;
my $minFreq = shift;

if (!$minFreq) { $minFreq = 0.05; }

my $usage = <<EOUSAGE;
Usage: perl $0 <annovar exome_summary output file> <min allele frequency>

where <min allele frequency> is optionnal, and has a default value of 0.1
EOUSAGE

if (!$annovarInput) { die($usage); }


open(my $in, "<", $annovarInput);
my $csv = Text::CSV->new ({ binary => 1, eol => $/ });
while (my $row = $csv->getline ($in)) {
	my $printLine = 1;

	my @elements = @$row;
	my ($Func, $Gene, $ExonicFunc, $AAChange, $Conserved, $SegDup, $ESP6500_ALL, 
		$thousandg2012apr_ALL, $rsID, $AVSIFT, $LJB_PhyloP, $LJB_PhyloP_Pred, 
		$LJB_SIFT, $LJB_SIFT_Pred, $LJB_PolyPhen2, $LJB_PolyPhen2_Pred, $LJB_LRT, 
		$LJB_LRT_Pred, $LJB_MutationTaster, $LJB_MutationTaster_Pred, $LJB_GERP, 
		$Chr, $Start, $End, $Ref, $obs, $Otherinfo, $o2, $o3, $o4, $o5) = @elements;

	if (!(1..1)) {
		if ($ESP6500_ALL && $thousandg2012apr_ALL && ($ESP6500_ALL > $minFreq || $thousandg2012apr_ALL > $minFreq)) { $printLine = 0; }
	}
		
	if ($printLine) { 
		my $status = $csv->combine(@elements);
		my $line   = $csv->string();
		print $line; 
	}
}
close($in);
