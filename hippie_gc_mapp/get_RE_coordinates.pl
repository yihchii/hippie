#!/usr/bin/perl -w
# find RE sites length distribution 
use strict;

my $usage = 'Usage: perl get_RE_coordinates.pl REseq FASTA-INPUT(s)[.fa]';
my $chrom_out = pop or die $usage;
my $resite = shift or die $usage;
my @in_files = @ARGV;
@in_files > 0 or die $usage;

open (CHROM_LENGTH, ">$chrom_out")|| die "Cannot open file $chrom_out for writing";
foreach my $chr_file (@in_files) {
	my $chr_seq;
	open (FILE, "$chr_file")|| die "Unable to open: $!";
	<FILE>; # skip the first line
	while (<FILE>){
		chomp;
		$chr_seq .= uc($_);
	}
	my $chr = "";
	if($chr_file =~ m/chr(\d{1,}|X|Y)\.fa$/) {
		my $num = $1;
		$chr = "chr".$num;
	}
	print CHROM_LENGTH $chr."\t".length($chr_seq)."\n";
	while ($chr_seq =~ /$resite/og){
		my $pos = pos ($chr_seq);
		print $chr."\t".($pos -length($resite))."\t".$pos."\n";   # UCSC 0-based start site 
	}
}
close (FILE);
close (CHROM_LENGTH);

