#!/usr/bin/perl -w
use strict;

my $usage = "perl $0 gap_threshold";

my $gap_threshold = shift || die $usage;

open(GAP_THRESHOLD, $gap_threshold) || die "Cannot find file $gap_threshold";

my %chrmThre;

while(my $line = <GAP_THRESHOLD>){
  chomp $line;
  my ($chrm, $thre) = split (/\t/,$line);
  $chrmThre{$chrm} = $thre;
}
close (GAP_THRESHOLD);

for my $chrm ( keys %chrmThre ) {
	my $threshold = $chrmThre{$chrm};
	system("bedtools merge -d $threshold"."{$chrm} -i $chrm".".bed -n -nms> $chrm"."_clusters.bed");
}

