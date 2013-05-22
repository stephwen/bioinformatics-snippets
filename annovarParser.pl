#!/usr/bin/perl
#
# This script parses the output of summarize_annovar.pl
# and discards synonymous SNVs
#

use strict;
use warnings;

my $file = shift;

if (!$file || !-f $file) {	die("usage: perl $0 <annovar output>\n"); }

open(IN, "<", $file);
while (my $line = <IN>) {
	 if (1..1) { print $line; next; }
	my @fields = split(/,/, $line);
	if ($fields[2] ne "\"synonymous SNV\"") { print $line; }	
}
close(IN);