#!/usr/bin/perl -w

use strict;

my $usage = "perl $0 GENOME_GENETIC_LENGTH HOTSPOT_ANNO_LENGTH OUTPUT";
my $genetic_length = shift || die $usage;
my $input = shift || die $usage;
my $output = shift || die $usage;
my @all_class= ("RefSeq-promoter", "RefSeq-gene",
"RefSeq-exon", "RefSeq-intron",
"miRNA", "pseudogene", "RNA-repeats", "TE", "TR","intergenic");


open (GENETIC_LEN, $genetic_length)||die "Cannot open file: $genetic_length";
open (IN, $input)|| die "Cannot open file: $input";
open (OUT, ">$output")||die "Cannot open file: $output";


my %class_total_len;
while (my $line = <GENETIC_LEN>){
	chomp $line;
	my ($class, $len) = split (/\t/, $line);
	$class_total_len{$class} = $len;
}
close (GENETIC_LEN);

my %class;
while (my $line = <IN>){
	chomp $line;
	my ($type, $len) = split (/\t/, $line);
	$class{$type}=$len;
}
close(IN);

for my $key (@all_class)
{ 
	if (!exists $class{$key}){
		$class{$key}=0;
	}
	my $percent = $class{$key}/$class_total_len{$key};
	print OUT "$key\t$class{$key}\t$percent\n";
}
close(OUT);
