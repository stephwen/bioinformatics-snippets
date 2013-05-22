#!/usr/bin/perl
#
# This script performs a SNP calling pipeline
# It uses the following software:
#
# * GATK 		(v2.1.11)
#
# It takes only one input: a bam file representing an alignment
#

use strict;
use warnings;
use File::Basename;

my %commands;

my $bam = shift;

if (!$bam || !-f $bam) { die("Usage: perl $0 <bam file>\n"); }

my $samtoolsExe = "/home/swe/2012-09-11/samtools-0.1.18/samtools";
my $samtoolsVersion = "0.1.18";

my $GATKExe = "/home/volatile/swe/2012-10-08/GenomeAnalysisTKLite-2.1-11-gfb37f33/GenomeAnalysisTKLite.jar" ;
my $GATKVersion = "2.1.11";

my $ref = "/home/safe/swe/exomes/hg19.fasta";
my $dbSNPVCF = "/home/safe/swe/exomes/dbSNP.vcf";
my $dbSNPReorderedVCF = "/home/safe/swe/exomes/dbsnp_137.hg19_reOrdered.vcf";
my $thousandsGenomeVCF = "/home/safe/swe/exomes/1000G_omni2.5.hg19.vcf";
my $hapmapVCF = "/home/safe/swe/exomes/hapmap_3.3.hg19_reOrdered.vcf";

my $prefix = dirname($bam)."/SNPCall";
my $rawVCF = $prefix."_raw.vcf";
my $recalFile = $prefix.".recal";
my $tranchesFile = $prefix.".tranches";
my $recalFilteredVCF = $prefix."_recalibrated_filtered.vcf";


print "\n****************************************\n";
print "*        SNP calling pipeline v1       *\n";
print "****************************************\n\n";
print "START AT ".&getTime."\n\n";

push(@{$commands{1}{'cmd'}}, "$samtoolsExe index $bam");
push(@{$commands{2}{'cmd'}}, "java -Xmx4g -jar $GATKExe -R $ref -T UnifiedGenotyper -I $bam --dbsnp $dbSNPVCF -o $rawVCF -dcov 200");
push(@{$commands{3}{'cmd'}}, "java -Xmx4g -jar $GATKExe -T VariantRecalibrator -R $ref -input $rawVCF -resource:hapmap,known=false,training=true,truth=true,prior=15.0 $hapmapVCF -resource:omni,known=false,training=true,truth=false,prior=12.0 $thousandsGenomeVCF -resource:dbsnp,known=true,training=false,truth=false,prior=6.0 $dbSNPReorderedVCF -an QD -an HaplotypeScore -an MQRankSum -an ReadPosRankSum -an FS -an MQ -mode BOTH -recalFile $recalFile -tranchesFile $tranchesFile");
push(@{$commands{4}{'cmd'}}, "java -Xmx4g -jar $GATKExe -T ApplyRecalibration -R $ref -input $rawVCF --ts_filter_level 99.0 -mode BOTH -recalFile $recalFile -tranchesFile $tranchesFile -o $recalFilteredVCF");

$commands{1}{'descr'} = "Indexing BAM file";
$commands{2}{'descr'} = "Calling the GATK UnifiedGenotyper";
$commands{3}{'descr'} = "Calling the GATK VariantRecalibrator";
$commands{4}{'descr'} = "Calling the GATK ApplyRecalibration";

for my $i (sort {$a <=> $b} keys %commands) {
	print " ***   ".$commands{$i}{'descr'}." - ".&getTime;
	print "\n";
	for my $cmd (@{$commands{$i}{'cmd'}}) {
		$cmd =~ s/\/\//\//g;	# transform // into /
		print "CMD:   ".$cmd."\n";
		system($cmd);
	}
	print "\n";
}

print "\n\nEND AT ".&getTime."\n\n";

#####################
#      methods      #
#####################

sub getTime {
	my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
	my @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
	my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
	my $year = 1900 + $yearOffset;
	my $theTime = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year - $hour:$minute:$second";
	return $theTime;
}