#!/usr/bin/perl

use strict;
use warnings;

my $samplesDir = shift;
if (!-d $samplesDir) { die("Usage: perl $0 <samples dir>\n"); }

my %samples; #key : sample name
my %samples2; #key: field name

opendir(D, $samplesDir) || die "Can't opedir: $!\n";
while (my $dir = readdir(D)) {
	if (-d "$samplesDir/$dir" && $dir ne "." && $dir ne "..") {
#		print $dir."\n";
		open(IN, "<", "$samplesDir/$dir/mapping.stats.txt");
		while (my $line = <IN>) {
			next if $line =~ /^#/;
			next if $line =~ /^\s/;
			next if $line =~ /^BAIT/;
			my ($BAIT_SET, $GENOME_SIZE, $BAIT_TERRITORY, $TARGET_TERRITORY, $BAIT_DESIGN_EFFICIENCY, $TOTAL_READS, $PF_READS, $PF_UNIQUE_READS, $PCT_PF_READS, $PCT_PF_UQ_READS, $PF_UQ_READS_ALIGNED, $PCT_PF_UQ_READS_ALIGNED, $PF_UQ_BASES_ALIGNED, $ON_BAIT_BASES, $NEAR_BAIT_BASES, $OFF_BAIT_BASES, $ON_TARGET_BASES, $PCT_SELECTED_BASES, $PCT_OFF_BAIT, $ON_BAIT_VS_SELECTED, $MEAN_BAIT_COVERAGE, $MEAN_TARGET_COVERAGE, $PCT_USABLE_BASES_ON_BAIT, $PCT_USABLE_BASES_ON_TARGET, $FOLD_ENRICHMENT, $ZERO_CVG_TARGETS_PCT, $FOLD_80_BASE_PENALTY, $PCT_TARGET_BASES_2X, $PCT_TARGET_BASES_10X, $PCT_TARGET_BASES_20X, $PCT_TARGET_BASES_30X, $HS_LIBRARY_SIZE, $HS_PENALTY_10X, $HS_PENALTY_20X, $HS_PENALTY_30X, $AT_DROPOUT, $GC_DROPOUT, $SAMPLE,	$LIBRARY, $READ_GROUP) = split(/\t/, $line);

			$samples{$dir} = {
				"BAIT_SET"						=>	$BAIT_SET,
				"GENOME_SIZE"					=>	$GENOME_SIZE,
				"BAIT_TERRITORY"				=>	$BAIT_TERRITORY,
				"TARGET_TERRITORY"				=>	$TARGET_TERRITORY,
				"BAIT_DESIGN_EFFICIENCY"		=>	$BAIT_DESIGN_EFFICIENCY,
				"TOTAL_READS"					=>	$TOTAL_READS,
				"PF_READS"						=>	$PF_READS,
				"PF_UNIQUE_READS"				=>	$PF_UNIQUE_READS,
				"PCT_PF_READS"					=>	$PCT_PF_READS,
				"PCT_PF_UQ_READS"				=>	$PCT_PF_UQ_READS,
				"PF_UQ_READS_ALIGNED"			=>	$PF_UQ_READS_ALIGNED,
				"PCT_PF_UQ_READS_ALIGNED"		=>	$PCT_PF_UQ_READS_ALIGNED,
				"PF_UQ_BASES_ALIGNED"			=>	$PF_UQ_BASES_ALIGNED,
				"ON_BAIT_BASES"					=>	$ON_BAIT_BASES,
				"NEAR_BAIT_BASES"				=>	$NEAR_BAIT_BASES,
				"OFF_BAIT_BASES"				=>	$OFF_BAIT_BASES,
				"ON_TARGET_BASES"				=>	$ON_TARGET_BASES,
				"PCT_SELECTED_BASES"			=>	$PCT_SELECTED_BASES,
				"PCT_OFF_BAIT"					=>	$PCT_OFF_BAIT,
				"ON_BAIT_VS_SELECTED"			=>	$ON_BAIT_VS_SELECTED,
				"MEAN_BAIT_COVERAGE"			=>	$MEAN_BAIT_COVERAGE,
				"MEAN_TARGET_COVERAGE"			=>	$MEAN_TARGET_COVERAGE,
				"PCT_USABLE_BASES_ON_BAIT"		=>	$PCT_USABLE_BASES_ON_BAIT,
				"PCT_USABLE_BASES_ON_TARGET"	=>	$PCT_USABLE_BASES_ON_TARGET,
				"FOLD_ENRICHMENT"				=>	$FOLD_ENRICHMENT,
				"ZERO_CVG_TARGETS_PCT"			=>	$ZERO_CVG_TARGETS_PCT,
				"FOLD_80_BASE_PENALTY"			=>	$FOLD_80_BASE_PENALTY,
				"PCT_TARGET_BASES_2X"			=>	$PCT_TARGET_BASES_2X,
				"PCT_TARGET_BASES_10X"			=>	$PCT_TARGET_BASES_10X,
				"PCT_TARGET_BASES_20X"			=>	$PCT_TARGET_BASES_20X,
				"PCT_TARGET_BASES_30X"			=>	$PCT_TARGET_BASES_30X,
				"HS_LIBRARY_SIZE"				=>	$HS_LIBRARY_SIZE,
				"HS_PENALTY_10X"				=>	$HS_PENALTY_10X,
				"HS_PENALTY_20X"				=>	$HS_PENALTY_20X,
				"HS_PENALTY_30X"				=>	$HS_PENALTY_30X,
				"AT_DROPOUT"					=>	$AT_DROPOUT,
				"GC_DROPOUT"					=>	$GC_DROPOUT,
				"SAMPLE"						=>	$SAMPLE,
				"LIBRARY"						=>	$LIBRARY,
				"READ_GROUP"					=>	$READ_GROUP
			};
			
#			print $line;
		}
		close(IN);
	}
}

my @fields = ("BAIT_SET", "GENOME_SIZE", "BAIT_TERRITORY", "TARGET_TERRITORY", "BAIT_DESIGN_EFFICIENCY", "TOTAL_READS", "PF_READS", "PF_UNIQUE_READS", "PCT_PF_READS", "PCT_PF_UQ_READS", "PF_UQ_READS_ALIGNED", "PCT_PF_UQ_READS_ALIGNED", "PF_UQ_BASES_ALIGNED", "ON_BAIT_BASES", "NEAR_BAIT_BASES", "OFF_BAIT_BASES", "ON_TARGET_BASES", "PCT_SELECTED_BASES", "PCT_OFF_BAIT", "ON_BAIT_VS_SELECTED", "MEAN_BAIT_COVERAGE", "MEAN_TARGET_COVERAGE", "PCT_USABLE_BASES_ON_BAIT", "PCT_USABLE_BASES_ON_TARGET", "FOLD_ENRICHMENT", "ZERO_CVG_TARGETS_PCT", "FOLD_80_BASE_PENALTY", "PCT_TARGET_BASES_2X", "PCT_TARGET_BASES_10X", "PCT_TARGET_BASES_20X", "PCT_TARGET_BASES_30X", "HS_LIBRARY_SIZE", "HS_PENALTY_10X", "HS_PENALTY_20X", "HS_PENALTY_30X", "AT_DROPOUT", "GC_DROPOUT", "SAMPLE", "LIBRARY", "READ_GROUP");

for my $sample (keys %samples) {
	for my $field (@fields) {
		$samples2{$field}{$sample} = $samples{$sample}{$field};
	}
}

print("\t".join("\t", (sort keys %samples))."\n");
for my $field (@fields) {
	print $field."\t";
	for my $sample (sort keys %samples) {
		print $samples{$sample}{$field}."\t";
	}
	print "\n";
}


use Data::Dumper;
#print Dumper(%samples2);


exit;


