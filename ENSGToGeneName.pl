#!/usr/bin/perl
#
# This script parses an input file, and adds the Ensembl gene name next to
# the corresponding Ensembl gene id
#
use strict;
use warnings;
use v5.10;
use Data::Dumper;

my $ensemblGenesGTF = "/home/steph/GIGA/RNA-Seq-Sonia/Homo_sapiens.GRCh37.75_genes.gtf";
my $separator = "\t";	# can be changed to a space or whatever
my %ensemblGenes;

my $inputFile = shift;

if (!$inputFile) { die("Usage: perl $0 <input file>\n"); }



open(my $in, "<", $ensemblGenesGTF);
while (my $line = <$in>) {
	chomp($line);
#chr1	pseudogene	gene	11869	14412	.	+	.	gene_id "ENSG00000223972"; gene_name "DDX11L1"; gene_source "ensembl_havana"; gene_biotype "pseudogene";
	my (undef, undef, undef, undef, undef, undef, undef, undef, $data) = split(/\t/, $line);
	my (undef, $ensemblGeneId, undef, $geneName, undef, undef, undef, undef) = split(/ /, $data);
	$ensemblGeneId =~ s/\"//g;
	$ensemblGeneId =~ s/;//g;
	$geneName =~ s/\"//g;
	$geneName =~ s/;//g;
	$ensemblGenes{$ensemblGeneId}{'geneName'} = $geneName;
}
close($in);

open($in, "<", $inputFile);
while (my $line = <$in>) {
	chomp($line);
	my $lineRep = $line;

	while ($line =~ /(ENSG\d{11})/g) {
		if ($ensemblGenes{$1}) {
			my $replacement = $1.$separator.$ensemblGenes{$1}{'geneName'};
			$lineRep =~ s/$1/$replacement/;
		}
	}
	say $lineRep;

}
close($in);
