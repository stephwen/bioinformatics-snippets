#!/usr/bin/perl
#
# This script parses several output files of summarize_annovar.pl
# and generates a matrix combining the genes mutation count for each sample
#
# input:	* multiple summarize_annovar.pl output files
#
# output:	* matrix combining all the info
#

use strict;
use warnings;
use Text::CSV;
use Data::Dumper;

my $usage = <<EOUSAGE;
Usage: perl $0 <summarize_annovar.pl output file 1> ... <summarize_annovar.pl output file n>
EOUSAGE

if (!@ARGV) { die($usage); }

my %mutations;	# key1: gene name, key2: sample name, key3: number of mutations
my @samples;

foreach my $file (@ARGV) {
	if(!$file || !-f $file) { die($usage); }
	$file =~ /([a-zA-Z0-9]+)_(\*)?/;
	my $sampleName = $1;
	push(@samples, $sampleName);

	open(my $in, "<", $file);
	my $csv = Text::CSV->new ({ binary => 1, eol => $/ });
	while (my $row = $csv->getline ($in)) {
		my $printLine = 1;

		my @elements = @$row;
		my ($Func, $Gene, $ExonicFunc, $AAChange, $Conserved, $SegDup, $ESP6500_ALL, 
			$thousandg2012apr_ALL, $rsID, $AVSIFT, $LJB_PhyloP, $LJB_PhyloP_Pred, 
			$LJB_SIFT, $LJB_SIFT_Pred, $LJB_PolyPhen2, $LJB_PolyPhen2_Pred, $LJB_LRT, 
			$LJB_LRT_Pred, $LJB_MutationTaster, $LJB_MutationTaster_Pred, $LJB_GERP, 
			$Chr, $Start, $End, $Ref, $obs, $Otherinfo, $o2, $o3, $o4, $o5) = @elements;

		$mutations{$Gene}{$Chr}{$Start}{$End}{$Ref}{$obs}{$Otherinfo}{'samples'}{$sampleName} = 1;
		$mutations{$Gene}{$Chr}{$Start}{$End}{$Ref}{$obs}{$Otherinfo}{'nbSamples'}++;
		}
	close($in);

}

for my $gene (keys %mutations) {
	for my $chr (keys %{$mutations{$gene}}) {
		for my $start (keys %{$mutations{$gene}{$chr}}) {
			for my $end (keys %{$mutations{$gene}{$chr}{$start}}) {
				for my $ref (keys %{$mutations{$gene}{$chr}{$start}{$end}}) {
					for my $obs (keys %{$mutations{$gene}{$chr}{$start}{$end}{$ref}}) {
						for my $otherInfo (keys %{$mutations{$gene}{$chr}{$start}{$end}{$ref}{$obs}}) {
							if ($mutations{$gene}{$chr}{$start}{$end}{$ref}{$obs}{$otherInfo}{'nbSamples'} >= 2) {
								for my $sample (keys %{$mutations{$gene}{$chr}{$start}{$end}{$ref}{$obs}{$otherInfo}{'samples'}}) {
									print $sample."\t";
								}
								print "$gene\t$chr\t$start\t$end\t$ref\t$obs\t$otherInfo\n";
							}
						}
					}
				}
			}
		}
	}
}
