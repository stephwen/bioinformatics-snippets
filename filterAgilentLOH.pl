#!/usr/bin/perl
#
# This script takes as input two files listing deletions, amplifications, and LOH
# detected on Agilent micro-arrays. These files are generated by some Agilent software
# and contain tab-delimited columns
#
# The purpose of this script is to compare LOH regions in 2 samples, and compute
# common regions and regions present in only one of the two samples.
#
use strict;
use warnings;
use Set::IntSpan qw(grep_set map_set grep_spans map_spans );


use Data::Dumper;


my $file1 = shift;
my $file2 = shift;

my %runs1;
my %runs2;

my %runs1Only;
my %runs2Only;
my %runsBoth;

open(IN, "<", $file1) || die("Unable to open $file1\n");
while (my $line = <IN>) {
	next if 1..26;
	chomp($line);
	my ($Index, $ArrayName, $Class, $Chr, $Cytoband, $SizeBP, $Start, $Stop,
		$MaxCytoband, $MaxSizeBP, $MaxStartBP, $MaxStopBP, $Type, $Probes,
		$pValuePerLOHScore, $AvgCGHLR, $GeneNames, $CNVDGV_hg19, $Cytoband_hg19,
		$Genes_hg19, $PseudoAutosomalRegions_hg19, $CNVDGV_hg18, $Cytoband_hg18,
		$Genes_hg18, $PseudoAutosomalRegions_hg18) = split(/\t/, $line);
		$MaxStartBP =~ s/,//g;
		$MaxStopBP =~ s/,//g;
	if ($Type eq "LOH") {
		if ($runs1{$Chr}) {
			my $new = new Set::IntSpan $MaxStartBP."-".$MaxStopBP;
			$runs1{$Chr}->U($new);
		} else {
			$runs1{$Chr} = new Set::IntSpan $MaxStartBP."-".$MaxStopBP;
		}
	}
}
close(IN);


open(IN, "<", $file2) || die("Unable to open $file2\n");
while (my $line = <IN>) {
	next if 1..26;
	chomp($line);
	my ($Index, $ArrayName, $Class, $Chr, $Cytoband, $SizeBP, $Start, $Stop,
		$MaxCytoband, $MaxSizeBP, $MaxStartBP, $MaxStopBP, $Type, $Probes,
		$pValuePerLOHScore, $AvgCGHLR, $GeneNames, $CNVDGV_hg19, $Cytoband_hg19,
		$Genes_hg19, $PseudoAutosomalRegions_hg19, $CNVDGV_hg18, $Cytoband_hg18,
		$Genes_hg18, $PseudoAutosomalRegions_hg18) = split(/\t/, $line);
		$MaxStartBP =~ s/,//g;
		$MaxStopBP =~ s/,//g;
	if ($Type eq "LOH") {
		if ($runs2{$Chr}) {
			my $new = new Set::IntSpan $MaxStartBP."-".$MaxStopBP;
			$runs2{$Chr}->U($new);
		} else {
			$runs2{$Chr} = new Set::IntSpan $MaxStartBP."-".$MaxStopBP;
		}
	}
}
close(IN);

print "$file1 only\n\n";
for my $chr (sort sortChr keys %runs1) {
	my $runs1Only = $runs1{$chr}->diff($runs2{$chr});
	for ($runs1Only->sets) { print "chr".$chr.":"; print; print "\n"; }
}


print "\n\n$file2 only\n\n";
for my $chr (sort sortChr keys %runs2) {
	my $runs2Only = $runs2{$chr}->diff($runs1{$chr});
	for ($runs2Only->sets) { print "chr".$chr.":"; print; print "\n"; }
}

print "\n\nintersection\n\n";
for my $chr (sort sortChr keys %runs1) {
	my $intersect = $runs1{$chr}->intersect($runs2{$chr});
	for ($intersect->sets) { print "chr".$chr.":"; print; print "\n"; }
}



exit;

# print Dumper(@runs1);

for my $chr1 (keys %runs1) {
	for my $run1 (@{$runs1{$chr1}}) {
		for my $run2 (@{$runs2{$chr1}}) {
			if ($run1->intersect($run2)->empty) {
				push(@{$runs1Only{$chr1}}, $run1);
			} else {
				my $intersection = $run1->intersect($run2);
				push(@{$runsBoth{$chr1}}, $intersection);
				
				my @diffs = $run1->diff($run2)->sets;
				foreach my $diff (@diffs) {
					push(@{$runs1Only{$chr1}}, $diff);
				}
			}
		}
	}
}

for my $chr2 (keys %runs2) {
	for my $run2 (@{$runs2{$chr2}}) {
		for my $run1 (@{$runs1{$chr2}}) {
			if ($run2->intersect($run1)->empty) {
				push(@{$runs2Only{$chr2}}, $run2);
			} else {
				my $intersection = $run2->intersect($run1);
				push(@{$runsBoth{$chr2}}, $intersection);
				
				my @diffs = $run2->diff($run1)->sets;
				foreach my $diff (@diffs) {
					push(@{$runs2Only{$chr2}}, $diff);
				}
			}
		}
	}
}

print "LOH $file1\n";

for my $chr (sort sortChr keys %runs1Only) {
	my @runs = @{$runs1Only{$chr}};
	foreach my $run (@runs) {
		print "chr".$chr."\t".$run."\n";
	}
}

print "LOH $file2\n";

for my $chr (sort sortChr keys %runs2Only) {
	my @runs = @{$runs2Only{$chr}};
	foreach my $run (@runs) {
		print "chr".$chr."\t".$run."\n";
	}
}

print "LOH communs\n";

for my $chr (sort sortChr keys %runsBoth) {
	my @runs = @{$runsBoth{$chr}};
	foreach my $run (@runs) {
		print "chr".$chr."\t".$run."\n";
	}
}



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


# for my $run1 (@runs1) {
	# for my $run2 (@runs2) {
		# if ($run1->{"chr"} ne $run2->{"chr"}) { next; }
		# if ($run1->{"span"}->intersect($run2->{"span"})->empty) {
			# push(@runs1Only, $run1);
			# print "ajout de ".$run1->{"chr"}." ".$run1->{"span"}." (no intersect).\n";
		# } else {
			# if (!$run1->{"span"}->diff($run2->{"span"})->empty) {
				# my @spans = $run1->{"span"}->diff($run2->{"span"})->sets;
				# foreach my $span (@spans) {
					# push(@runs1Only, {
						# "chr"	=>	$run1->{"chr"},
						# "span"	=>	$span
					# });		
					# print "ajout de ".$run1->{"chr"}." ".$span." (diff).\n";
				# }
			# }
			# push(@runs1Only, {
				# "chr"	=>	$run1->{"chr"},
				# "span"	=>	$run1->{"span"}->intersect($run2->{"span"})
			# });
			# print "ajout de ".$run1->{"chr"}." ".$run1->{"span"}->intersect($run2->{"span"})." (intersect).\n";
		# }
	# }
# }

# for my $run1 (@runs2) {
	# for my $run2 (@runs1) {
		# if ($run2->{"chr"} ne $run1->{"chr"}) { next; }
		# if ($run2->{"span"}->intersect($run1->{"span"})->empty) {
			# push(@runs2Only, $run1);
		# } else {
			# if (!$run2->{"span"}->diff($run1->{"span"})->empty) {
				# push(@runs2Only, {
					# "chr"	=>	$run2->{"chr"},
					# "span"	=>	$run2->{"span"}->diff($run1->{"span"})
				# });
			# }
			# push(@runs2Only, {
				# "chr"	=>	$run2->{"chr"},
				# "span"	=>	$run2->{"span"}->intersect($run1->{"span"})
			# });
		# }
	# }
# }



