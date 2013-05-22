#!/usr/bin/perl
#
# This script performs a comparison of several VCF files
# It uses the following software:
#
# * GATK 		(v2.1.11)
#
# It takes VCF files as input
#

use strict;
use warnings;
use File::Basename;

if ($#ARGV < 2) { die("Usage: perl $0 <output dir> <vcf file 1> ... <vcf file n>\n"); }

my $outputDir = shift(@ARGV);
if (!-d $outputDir) { mkdir $outputDir || die("unable to create output dir\n"); }
my @VCFFiles;

my $i = 0;

for my $filePath (@ARGV) {
	my $fileName = basename($filePath);
	$fileName =~ s/\s+/_/g;
	$fileName =~ s/\.vcf//g;
	push(@VCFFiles, {
		"path"	=>	$filePath,
		"name"	=>	++$i."-".$fileName,
		"relCompl"	=>	$outputDir."/".$i."-".$fileName."-RC.vcf"
	});
}

use Data::Dumper; print Dumper(@VCFFiles);

my $GATKExe = "/home/volatile/swe/2012-10-08/GenomeAnalysisTKLite-2.1-11-gfb37f33/GenomeAnalysisTKLite.jar" ;
my $GATKVersion = "2.1.11";
my $ref = "/home/safe/swe/exomes/hg19.fasta";

my $unionVCF = $outputDir."/union.vcf";
my $intersectionVCF = $outputDir."/intersection.vcf";

my $cmd1 = "java -Xmx4g -jar $GATKExe -T CombineVariants --filteredAreUncalled -R $ref";
for my $vcf (@VCFFiles) {
	$cmd1 .= " -V:".$vcf->{'name'}." ".$vcf->{'path'};
}
$cmd1 .= " -o $unionVCF";
 
print $cmd1;
system($cmd1);

my $cmd2 = "java -Xmx4g -jar $GATKExe -T SelectVariants -R $ref -V:variant $unionVCF -select 'set == \"Intersection\";' -o $intersectionVCF";
print "\n";
print $cmd2."\n\n";
system($cmd2);

for my $vcf (@VCFFiles) {
	my $cmd = "java -Xmx4g -jar $GATKExe -T SelectVariants -R $ref -V:variant $unionVCF -select 'set == \"".$vcf->{'name'}."\";' -o ".$vcf->{'relCompl'} ;
	print $cmd."\n";
	system($cmd);
}
