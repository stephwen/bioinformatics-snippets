#!/usr/bin/perl
#
use strict;
use warnings;
use File::Basename;
use File::Temp qw/ tempfile tempdir /;

my $dir = shift;

my $currentTime = &getTime();

my $fastq1;
my $fastq2;
my $sai1;
my $sai2;
my $prefix;
my $sam;
my $bam;
my $statsFile;
my $metricsFile;
my $coverageFile;

my %commands;

my $ref = "/home/volatile/swe/exomes/hg19.fasta";
my $trueSeqBed = "/home/volatile/swe/exomes/TruSeq-for-Picard.bed";
my $dbSNPVCF = "/home/safe/swe/exomes/dbSNP.vcf";
my $intervalsFile = "/home/volatile/swe/exomes/output.intervals";

my $bwaExe = "/home/volatile/swe/2012-10-08/bwa-0.6.2/bwa";
my $bwaVersion = "0.6.2";

my $samtoolsExe = "/home/swe/2012-09-11/samtools-0.1.18/samtools";
my $samtoolsVersion = "0.1.18";

my $picardDir = "/home/safe/swe/2012-10-03/picard-tools-1.77/";
my $picardVersion = "1.77";

my $GATKExe = "/home/volatile/swe/2012-10-08/GenomeAnalysisTKLite-2.1-11-gfb37f33/GenomeAnalysisTKLite.jar";
my $GATKVersion = "2.1.11";

my $tmpDir = File::Temp::tempdir("/home/volatile/swe/TMP/XXXXXXXX");

my $usage = <<EOUSAGE;
Usage: perl $0 <directory with fastq files>
EOUSAGE

if(!$dir || !-d $dir) { die($usage); }

print "\n****************************************\n";
print "*       Reads mapping pipeline v1      *\n";
print "****************************************\n\n";
print "START AT ".&getTime."\n\n";

my @fastq = <$dir/*.fastq>;
push(@fastq, <$dir/*.fastq.gz>);


if ($#fastq < 1) { die("Error: you need 2 fastq files to run this pipeline\n"); }
if ($#fastq > 1) { die("Error: there are more than 2 fastq files in the specified directory\n"); }

$fastq1 = $fastq[0];
$fastq2 = $fastq[1];

# create mapping sub-dir in $dir
my $mappingDir = $dir."/mapping";

if (!-d $mappingDir) { mkdir $mappingDir; }

$sai1 = $mappingDir."/".substr(basename($fastq1), 0, -5)."sai";
$sai2 = $mappingDir."/".substr(basename($fastq2), 0, -5)."sai";

$prefix = $mappingDir."/mapping";

$sam = $prefix.".sam";
$bam = $prefix.".bam";
$statsFile = $prefix.".stats";
$metricsFile = $prefix.".mets";
$coverageFile = $prefix.".cov";

push(@{$commands{1}{'cmd'}}, "$bwaExe aln -t 4 $ref $fastq1 > $sai1");
push(@{$commands{2}{'cmd'}}, "$bwaExe aln -t 4 $ref $fastq2 > $sai2");
push(@{$commands{3}{'cmd'}}, "$bwaExe sampe $ref $sai1 $sai2 $fastq1 $fastq2 > $sam");
push(@{$commands{4}{'cmd'}}, "$samtoolsExe view -bS $sam > $bam");
push(@{$commands{4}{'cmd'}}, "$samtoolsExe sort $bam $prefix"."_sorted");
push(@{$commands{4}{'cmd'}}, "$samtoolsExe index $prefix"."_sorted.bam");
push(@{$commands{5}{'cmd'}}, "rm $sam");
push(@{$commands{6}{'cmd'}}, "java -Djava.io.tmpdir=$tmpDir -Xmx2g -jar $picardDir/FixMateInformation.jar INPUT=$prefix"."_sorted.bam OUTPUT=$prefix"."_FixMate.bam VALIDATION_STRINGENCY=LENIENT");
push(@{$commands{7}{'cmd'}}, "$samtoolsExe sort $prefix"."_FixMate.bam $prefix"."_FM_sorted");
push(@{$commands{7}{'cmd'}}, "$samtoolsExe index $prefix"."_FM_sorted.bam");
push(@{$commands{8}{'cmd'}}, "java -Djava.io.tmpdir=$tmpDir -Xmx4g -jar $picardDir/AddOrReplaceReadGroups.jar OUTPUT=$prefix"."_RG.bam INPUT=$prefix"."_FM_sorted.bam VALIDATION_STRINGENCY=LENIENT RGID=1 RGLB=Lib1 RGPL=illumina RGPU=01 RGSM=Lib1");
push(@{$commands{9}{'cmd'}}, "$samtoolsExe sort $prefix"."_RG.bam $prefix"."_RG_sorted");
push(@{$commands{9}{'cmd'}}, "$samtoolsExe index $prefix"."_RG_sorted.bam");
push(@{$commands{10}{'cmd'}}, "java -Djava.io.tmpdir=$tmpDir -Xmx4g -jar $GATKExe -T IndelRealigner -I $prefix"."_RG_sorted.bam -R $ref -targetIntervals $intervalsFile -o $prefix"."_IndelRealign.bam");
push(@{$commands{11}{'cmd'}}, "java -Djava.io.tmpdir=$tmpDir -Xmx2g -jar $picardDir/FixMateInformation.jar INPUT=$prefix"."_IndelRealign.bam OUTPUT=$prefix"."_FixMate2.bam VALIDATION_STRINGENCY=LENIENT");
push(@{$commands{12}{'cmd'}}, "$samtoolsExe sort $prefix"."_FixMate2.bam $prefix"."_FM2_sorted");
push(@{$commands{12}{'cmd'}}, "$samtoolsExe index $prefix"."_FM2_sorted.bam");
push(@{$commands{13}{'cmd'}}, "java -Djava.io.tmpdir=$tmpDir -Xmx4g -jar $GATKExe -T BaseRecalibrator -R $ref -I $prefix"."_FM2_sorted.bam -o $prefix"."_Recalibr.report -knownSites $dbSNPVCF --disable_indel_quals");
push(@{$commands{13}{'cmd'}}, "java -Djava.io.tmpdir=$tmpDir -Xmx4g -jar $GATKExe -T PrintReads -R $ref -I $prefix"."_FM2_sorted.bam -o $prefix"."_Recalibr.bam -BQSR $prefix"."_Recalibr.report");
push(@{$commands{14}{'cmd'}}, "java -Djava.io.tmpdir=$tmpDir -Xmx4G -XX:ParallelGCThreads=4 -jar $picardDir/MarkDuplicates.jar INPUT=$prefix"."_Recalibr.bam OUTPUT=$prefix"."_MarkDup.bam METRICS_FILE=$prefix"."_MarkDup.metrics VALIDATION_STRINGENCY=LENIENT TMP_DIR=/home/volatile/swe/TMP");
push(@{$commands{15}{'cmd'}}, "java -Djava.io.tmpdir=$tmpDir -Xmx4g -jar $picardDir/CalculateHsMetrics.jar BAIT_INTERVALS=$trueSeqBed TARGET_INTERVALS=$trueSeqBed INPUT=$prefix"."_MarkDup.bam OUTPUT=$prefix".".stats.txt PER_TARGET_COVERAGE=$prefix".".per.target.coverage.txt VALIDATION_STRINGENCY=LENIENT REFERENCE_SEQUENCE=$ref");


$commands{1}{'descr'} = "Aligning read 1";
$commands{2}{'descr'} = "Aligning read 2";
$commands{3}{'descr'} = "Generating SAM file";
$commands{4}{'descr'} = "Generating BAM file";
$commands{5}{'descr'} = "Deleting SAM file";
$commands{6}{'descr'} = "Running Picard FixMateInfo";
$commands{7}{'descr'} = "Running samtools sort & index";
$commands{8}{'descr'} = "Running Picard AddReadGroups";
$commands{9}{'descr'} = "Running samtools sort & index";
$commands{10}{'descr'} = "Running GATK Local Realigner";
$commands{11}{'descr'} = "Running Picard FixMateInfo";
$commands{12}{'descr'} = "Running samtools sort & index";
$commands{13}{'descr'} = "Running GATK Base quality recalibration";
$commands{14}{'descr'} = "Running Picard Mark Duplicates";
$commands{15}{'descr'} = "Running Picard Calculate Hs Metrics";

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
