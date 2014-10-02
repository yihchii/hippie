#!/usr/bin/perl -w

use strict;
my $usage = "perl $0 enh_target_coordinate";
my $enh_tar_file = shift || die $usage;

open (ENH_TAR, $enh_tar_file) || die "Cannot open file $enh_tar_file";

my %enh_target;
while (my $line = <ENH_TAR> ){
	# chr10   101153224       101156816       MIR107  1
	chomp $line;
	my ($enh_chr, $enh_start, $enh_end, $tar_gene, $mergedNum) = split (/\t/, $line);
	my @target_genes = split (/,/,$tar_gene);
	my @dist;
	my ($dist1,$dist2);
	# split target gene list
	foreach my $x (@target_genes){
		if ($x =~ m/(chr[0-9|X|Y]{1,2})\:([0-9]+)\-([0-9]+)/){
			my ($chr, $tar_start, $tar_end) = ($1, $2, $3);
			if ($chr eq $enh_chr){
				# start is 0-based, end is 1-based. distance = start+1-end.
				$dist1 = abs($enh_start+1 - $tar_end);
				$dist2 = abs($tar_start+1 - $enh_end);
			} else{ # on different chromosome, skip
#				print "inter-chromosomal\n";
				next;
			}
			# for each enhancer, create the arry of distance to its target gene
			push (@dist, $dist1 > $dist2 ? $dist1:$dist2);
		}
	}
	if (@dist > 0){ # if there is intra-chromosmal interactions, print the distance
#		my $distance = &average(@dist);
		# minimum distance
		my @array = sort { $a <=> $b } @dist;
		my $distance = $array[0];
		print $distance."\n";
	}
}
close (ENH_TAR);


sub average {
	my @array = @_; # save the array passed to this function
	my $sum; # create a variable to hold the sum of the array's values
	foreach (@array) { $sum += $_; } # add each element of the array 
# to the sum
	return $sum/@array; # divide sum by the number of elements in the
# array to find the mean
}
