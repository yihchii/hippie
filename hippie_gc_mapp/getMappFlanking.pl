#!/usr/bin/perl -w
use strict;

my $usage = "USAGE: perl $0 chr_mapped.bam outfile readlength";

my $readlength = shift || die $usage;
my $infile = shift || die $usage;
my $outfile = shift || die $usage;

open (IN, "samtools view $infile |cut -f 1,5,12 |")||die "Cannot open $infile";
open (OUT, ">$outfile")||die "Cannot open $outfile";

my ($chr,$start,$end);
my $count = 0;
my $first = 1;
my $keys = "";
while (my $line = <IN>){
	chomp $line;
	my ($id,$mapq, $uniq) = split (/\t/,$line);
	if (!defined ($mapq)){ $mapq = 0;}
	if (!defined ($uniq)){ $uniq = 0;}
	if (!defined ($id)){ next;}
	my ($chr, $start, $end, $pos) = split (/\.|\:|\-/,$id);

	if ($first == 1){
		$first = 0;
		$keys =  "$chr\t$start\t$end";
		if ($uniq eq "NH:i:1"&& $mapq >= 30){ $count +=1; }
		next;
	}

	if ("$chr\t$start\t$end" ne $keys){
		my ($chrk,$startk,$endk) = split (/\t/,$keys);
		my $mapp = $count / ($endk - $startk - $readlength+1);
		my ($prechr,$prestart,$preend) = split (/\t/,$keys);
		print OUT "$prechr\t$prestart\t$preend\t$mapp\t$keys\n";
		$count = 0;
		$keys =  "$chr\t$start\t$end";
	}
	if ( $uniq eq "NH:i:1" && $mapq >=30){	$count +=1;	}

}
my ($chrk,$startk,$endk) = split (/\t/,$keys);
my $mapp = $count / ($endk - $startk - $readlength+1);
my ($prechr,$prestart,$preend) = split (/\t/,$keys);
print OUT "$prechr\t$prestart\t$preend\t$mapp\t$keys\n";
close (IN);

close (OUT);
