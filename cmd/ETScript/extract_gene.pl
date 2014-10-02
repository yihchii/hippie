#!/usr/bin/perl -w
use strict;

# target column format:
# NFKB2;NFKB2=chr10:104153366-104154336,NFKB2;NFKB2=chr10:104154926-104155431

my $usage = "perl $0 cee_target_file genelist";
my $infile = shift || die $usage;
my $outfile = shift || die $usage;

open (INFILE, $infile)|| die "Cannot open $infile";
open (OUTFILE, ">$outfile")||die "Cannot open $outfile";

my %genelist;

while (my $line = <INFILE>){
	chomp $line;
	my ($chr,$start,$end,$target) = split(/\t/,$line);
	my @targetList = split (/\,/, $target);
	foreach my $x (@targetList){
		my ($geneset, $coordinate) = split (/\=/, $x);
		my @gene = split (/\;/,$geneset);
		foreach my $y (@gene){
			$genelist{$y} = $y;
		}
	}
}
close (INFILE);

while (my ($key, $value) = each(%genelist)){
     print OUTFILE "$key\n";
}
close (OUTFILE);
