#!/usr/bin/perl -w
use strict;

my $usage = "perl $0 target-list promoter-coridinate";
my $target_file = shift||die $usage;
my $promoter_file = shift||die $usage;

open (TARGET, $target_file)||die "Cannot open $target_file";
open (PROMOTER, $promoter_file)||die "Cannot open $promoter_file";

my %target;
while (my $line = <TARGET>){
	chomp $line;
	$target{$line} = $line;
}
close (TARGET);

while (my $line = <PROMOTER>){
	chomp $line;
	my ($ID_symbol, $chr, $start, $end, $strand) = split (/\t/,$line );
	my $symbol = $ID_symbol;
	$symbol =~ s/^\d+\_//;
	if (exists $target{$symbol}){
		my $print_list = join ("\t", $ID_symbol, $chr, $start, $end, $strand)."\n";
		print $print_list;
	}
}
close(PROMOTER);
