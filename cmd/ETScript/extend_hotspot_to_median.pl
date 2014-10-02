#!/usr/bin/perl -w
# find RE sites length distribution 
use strict;
use POSIX qw(ceil floor);

my $usage = 'Usage: perl extend_hotspot_to_median.pl MEDIAN HOTSPOT-INPUT CHR-LEN Expended_HOTSPOT-OUTPUT';
my $median = shift or die $usage;
my $in_file = shift or die $usage;
my $chr_len = shift or die $usage;
my $file_out = shift or die $usage;
my $bound = ceil($median/2);

my %chr_len;
open (CHRLEN, $chr_len)|| die "Cannot open $!";
while(<CHRLEN>){
	chomp;
	my ($chr, $len) = split(/\t/,$_);
#	if ($chr =~ /^chr(\d+)$/){
#		$chr = $1;
#  }elsif ($chr =~ /^chrM$/){
#		$chr = 25;
#	}elsif ($chr =~ /^chrX$/){
#		$chr = 23;
#	}elsif($chr =~ /^chrY$/){
#		$chr = 24;
#	}
	$chr_len{$chr} = $len;
}
close(CHRLEN);

open (IN, $in_file)||die "Cannot open $!";
open (OUT, ">$file_out")|| die "Cannot open $!";
while(<IN>){
	chomp;
	my ($chrm, $start, $end, $ilabel, $read) = split(/\s/,$_);
	if ($end - $start < $median) { 
		my $start_temp = ceil(($start+$end)/2-$bound);
		my $end_temp = floor(($start+$end)/2+$bound);
		my $eStart = ($start_temp>=0)? $start_temp:0;
		my $eEnd = ($end_temp < $chr_len{$chrm})? $end_temp:$chr_len{$chrm};
		print OUT ("$chrm\t$eStart\t$eEnd\t$ilabel\t$read\n");
	}else{
		print OUT ("$chrm\t$start\t$end\t$ilabel\t$read\n");
	}
}
close(IN);
close(OUT);

