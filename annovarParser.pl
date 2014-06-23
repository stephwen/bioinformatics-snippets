#!/usr/bin/perl
#
# This script parses the output of summarize_annovar.pl
# and discards synonymous SNVs
#

use strict;
use warnings;
use Text::CSV;

my $annovarInput = shift;

if (!$annovarInput || !-f $annovarInput) {	die("usage: perl $0 <annovar output>\n"); }

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
		if ($ExonicFunc eq "synonymous SNV") { $printLine = 0; }
	}
		
	if ($printLine) { 
		my $status = $csv->combine(@elements);
		my $line   = $csv->string();
		print $line; 
	}
}
close($in);
