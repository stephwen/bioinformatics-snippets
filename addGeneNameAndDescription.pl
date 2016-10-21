#!/usr/bin/perl
#
# This script parses a DESeq output file, and adds the Ensembl gene name to
# the corresponding Ensembl gene id
#
use strict;
use warnings;
use Bio::EnsEMBL::Registry;
use v5.10;
use Data::Dumper;

my $ensemblGenesGTF = "/home/steph/GIGA/RNA-Seq-Sonia/Homo_sapiens.GRCh37.75_genes.gtf";
my %ensemblGenes;

my $deseqFile = shift;

if (!$deseqFile) { die("Usage: perl $0 <DESeq output file>\n"); }

my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
    -user => 'anonymous'
);

my $gene_adaptor  = $registry->get_adaptor( 'Human', 'Core', 'Gene' );

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


#say '"Ensembl id","gene name","description", "baseMean","baseMeanA","baseMeanB","foldChange","log2FoldChange","pval","padj"';

open($in, "<", $deseqFile);
while (my $line = <$in>) {
#	next if 1..1;
	chomp($line);
#	my (undef, $ensemblGeneId, $baseMean, $baseMeanA, $baseMeanB, $foldChange, $log2FoldChange, $pval, $padj) = split(/,/, $line);
#	$ensemblGeneId =~ s/\"//g;
	my $ensemblGeneId = $line;

	next if (!$ensemblGenes{$ensemblGeneId});

	my $gene;
	my $description = "N/A";

	print "\"$ensemblGeneId\",";
	print "\"".$ensemblGenes{$ensemblGeneId}{'geneName'}."\",";

	$gene = $gene_adaptor->fetch_by_stable_id($ensemblGeneId);
	if ($gene) { $description = $gene->description(); }

	if ($description) { $description =~ s/ \[.*?\]//gs; } else { $description = "N/A"; }

	say "\"$description\",";

#	say "$baseMean,$baseMeanA,$baseMeanB,$foldChange,$log2FoldChange,$pval,$padj";
}
close($in);
