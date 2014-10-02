#!/usr/bin/perl -w
use strict;

open(IN, shift) || die $!;
my $readLength = shift;
my $chrmFlag;
my $posFlag = 1;
my $regstaFlag = 0;
my $first = 0;
my $read = 0;
print "ilabel\tchrm\tregStart\tregEnd\tregLength\ttype\tread\n";

while(<IN>){
	chomp;
	my ($chrm, $pos, $ilabel) = split(/\t/,$_);
	$read +=1;
	if (!defined($chrmFlag)||$chrm eq $chrmFlag){
		if ($first == 0){
			$chrmFlag = $chrm;
			$posFlag = $pos; #
			$regstaFlag = $pos;
			$first = 1;
		}
		my $length = $pos - $posFlag;
		if($length > $readLength){
			my $regionend = $posFlag +$readLength-1;
			my $regionlength = $regionend-$regstaFlag+1;
			print "$ilabel\t$chrm\t$regstaFlag\t$regionend\t$regionlength\tregion\t$read\n";
			my $gaplength = $length -$readLength;
			my $gapstart = $posFlag +$readLength;
			my $gapend = $pos-1;
			print "$ilabel\t$chrm\t$gapstart\t$gapend\t$gaplength\tgap\t0\n";
			$read = 0;
			$regstaFlag = $pos;
		}
		$posFlag = $pos;
	}
#change to another chromosome
	else{
#print out the last region in the previous chromosome
		my $regionend = $posFlag +$readLength-1;
		my $regionlength = $regionend-$regstaFlag+1;
		print "$ilabel\t$chrmFlag\t$regstaFlag\t$regionend\t$regionlength\tregion\t$read\n";
		$read = 0;
		$posFlag = 1;
		$regstaFlag = $pos;

		my $length = $pos - $posFlag;
		if ($length > $readLength){
			my $gaplength = $length -$readLength;
			my $gapstart = $posFlag +$readLength;
			my $gapend = $pos -1;
			print "$ilabel\t$chrmFlag\t$regstaFlag\t$regionend\t$regionlength\tregion\t$read\n";
			$read = 0;
		}
		$posFlag = $pos;
		$chrmFlag = $chrm;
	}
}
close(IN);
