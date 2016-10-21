#!/usr/bin/perl
#
# This script parses an htseq-count output files, reads the read counts for all transcripts
# and computes the RPKM value for each transcript
#
use strict;
use warnings;

my $ensemblTranscriptsFile = "/home/steph/GIGA/Ensembl_genes_transcripts_lengths.txt";
# format: Ensembl Gene ID,Ensembl Transcript ID,Associated Gene Name,Transcript Start (bp),Transcript End (bp)
my $htseqCountFile = shift;

if (!$htseqCountFile) { die("Usage: perl $0 <htseq count file>\n"); }

my %ensemblTranscripts;
my %allReads;
my $threshold = 0;
my $sampleTotalReads = 0;

open(IN, "<", $ensemblTranscriptsFile);
while (my $line = <IN>) {
	next if 1..1;
	chomp($line);
	my ($ensemblGeneId, $ensemblTranscriptId, $geneName, $transcriptStart, $transcriptEnd) = split(/,/, $line);
	my $transcriptLength = $transcriptEnd - $transcriptStart;
	$ensemblTranscripts{$ensemblTranscriptId}{'ensemblGeneId'} = $ensemblGeneId;
	$ensemblTranscripts{$ensemblTranscriptId}{'ensemblGeneName'} = $geneName;
	$ensemblTranscripts{$ensemblTranscriptId}{'length'} = $transcriptLength;
}
close(IN);

open(IN, "<", $htseqCountFile);
while (my $line = <IN>) {
	chomp($line);
	my ($ensemblTranscriptId, $count) = split(/\t/, $line);
	$sampleTotalReads += $count;
}
close(IN);

open(IN, "<", $htseqCountFile);
while (my $line = <IN>) {
	chomp($line);
	my ($ensemblTranscriptId, $count) = split(/\t/, $line);
	if ($ensemblTranscripts{$ensemblTranscriptId}) {
		my $RPKM = (10**9 * $count) / ($sampleTotalReads * $ensemblTranscripts{$ensemblTranscriptId}{'length'});
		print $ensemblTranscripts{$ensemblTranscriptId}{'ensemblGeneName'}."\t".$ensemblTranscriptId."\t".$RPKM."\n";
	}
}
close(IN);

