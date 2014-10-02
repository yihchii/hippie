#!/usr/bin/perl -w
use strict;

my $usage = "perl $0 cluster_threshold";

my $cluster_threshold = shift || die $usage;

open(CLUSTER_THRESHOLD, $cluster_threshold) || die "Cannot find file $cluster_threshold";

my %chrmThre;

while(my $line = <CLUSTER_THRESHOLD>){
  chomp $line;
  my ($chrm, $thre) = split (/\t/,$line);
  $chrmThre{$chrm} = $thre;
}
close (CLUSTER_THRESHOLD);

for my $chrm ( keys %chrmThre ) {
	my $threshold = $chrmThre{$chrm};
	system("awk 'BEGIN{OFS=\"\t\"}{if ((\$3-\$2)>$threshold) print}' $chrm\"_clusters.bed\" > $chrm\"_hotspots.bed\"");
}

