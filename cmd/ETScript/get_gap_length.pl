#!/usr/bin/perl -w
use strict;

my $usage = "perl $0 bedfile genomefile outfile";

my $bedfile = shift || die $usage;
my $genomefile = shift || die $usage;
my $outfile = shift || die $usage;

open(BED, $bedfile) || die "Cannot find file $bedfile";
open(GENOM, $genomefile) || die "Cannot find file $genomefile";
open(OUT, ">$outfile") || die "Cannot find file $outfile";

my $chrmFlag;
my $first=0;
my $pre_end = 0;
my $gaplength = 0;

my %chrmLen;

while(my $line = <GENOM>){
	chomp $line;
	my ($chrm, $size) = split (/\t/,$line);
	$chrmLen{$chrm} = $size;
}
close (GENOM);

print OUT "chrm\tgapLength\n";

while(my $line = <BED>){
	chomp $line;
	my ($chrm, $start, $end, $ilable, $read) = split(/\t/,$line);

	#chrm1 or in the same chromosome
	if (!defined($chrmFlag)||$chrm eq $chrmFlag){ 
		if ($first == 0){ # chrm1
			$chrmFlag = $chrm;
			$first = 1;
		}

		$gaplength = $start-$pre_end;
		print OUT "$chrm\t$gaplength\n";
		$pre_end = $end;
	}
	#change to another chromosome
	else{
		$gaplength = $chrmLen{$chrmFlag} - $pre_end;
		print OUT "$chrmFlag\t$gaplength\n";
		$chrmFlag = $chrm;
		$pre_end = 0;
	
		$gaplength = $start-$pre_end;
		print OUT "$chrm\t$gaplength\n";
		$pre_end = $end;

	}
}
close(BED);
close(OUT);
