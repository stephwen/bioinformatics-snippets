#/usr/bin/perl
#
# This script is used to identify wich runs of homozygozity are present only in a specific sample
# out of a group of related samples 
#
use strict;
use warnings;

my $plinkHomFile = shift || die("Usage: perl $0 <plink .hom file> <sample id>\n");
my $patientId = shift || die("Usage: perl $0 <plink .hom file> <sample id>\n");

my @runs; # AoH;
my @runsPatient; #AoH;

open(IN, "<", $plinkHomFile);
while(my $line = <IN>) {
	next if 1 .. 1;
	chomp($line);
	my (undef, $FID, $IID, undef, $CHR, undef, undef, $POS1, $POS2, undef, undef, undef, undef, undef) = split(/\s+/, $line);
	if ($IID == $patientId) {
                push(@runsPatient, {
                        "chr"   =>      $CHR,
                        "pos1"  =>      $POS1,
                        "pos2"  =>      $POS2,
                        "line"  =>      $line,
                        "id"    =>      $IID
                });
	
	} else {
		push(@runs, {
			"chr"	=>	$CHR,
			"pos1"	=>	$POS1,
			"pos2"	=>	$POS2,
			"line"	=>	$line,
			"id"	=>	$IID
		});
	}
}
close(IN);

foreach my $runP (@runsPatient) {
	my $toPrint = 1;
	foreach my $runO (@runs) {
		if ($runP->{"chr"} ne $runO->{"chr"}) { next; }
		if ($runP->{"pos1"} >= $runO->{"pos1"} && $runP->{"pos2"} <= $runO->{"pos2"}) {
			$toPrint = 0;
		}
	}
	if ($toPrint) {
		print $runP->{"line"}."\n";
	}
}


