#!/usr/bin/perl -w
use strict;

my $usage = "perl $0 motif-motif-list motif-motif-matrix";

my $motif_motif_list = shift ||die $usage;
my $motif_motif_matrix = shift || die $usage;


open (LIST,$motif_motif_list)||die "Cannot open $motif_motif_list";
open (MATRIX, ">$motif_motif_matrix")||die "Cannot open $motif_motif_matrix";

open (NUM_CEE_MOTIF, "cat $motif_motif_list|cut -f1|sort -u|wc -l|");
open (NUM_TAR_MOTIF, "cat $motif_motif_list|cut -f2|sort -u|wc -l|");

my $num_cee_motif = <NUM_CEE_MOTIF>;
chomp $num_cee_motif;
my $num_tar_motif = <NUM_TAR_MOTIF>;
chomp $num_tar_motif;

my @matrix;
for my $x (0 .. $num_cee_motif-1) {                       # For each row...
	for my $y (0 .. $num_tar_motif-1) {                   # For each column...
		$matrix[$x][$y] = 0;    # ...set that cell
		}
}

my %ceeMotifIndex;
my %tarMotifIndex;
my $cee_i=0;
my $tar_i=0;
while (my $line = <LIST>){
	chomp $line;
	my ($cee_motif, $tar_motif, $num) = split (/\t/, $line);
	if (!exists $ceeMotifIndex{$cee_motif}){
		$ceeMotifIndex{$cee_motif}=$cee_i++;
	}
	if (!exists $tarMotifIndex{$tar_motif}){
		$tarMotifIndex{$tar_motif}=$tar_i++;
	}
	$matrix[$ceeMotifIndex{$cee_motif}][$tarMotifIndex{$tar_motif}]=$num;
}
close(LIST);

print MATRIX "root";
foreach my $key (sort keys %tarMotifIndex){
	print MATRIX "\t".$key;
}
print MATRIX "\n";

my @ceeMotif;
foreach my $key (sort keys %ceeMotifIndex){
	push @ceeMotif, $key;
}

my $i=0;
for my $cee_motif ( @matrix ) {
    print MATRIX $ceeMotif[$i++]."\t".join ("\t", @$cee_motif)."\n";
}
close(MATRIX);

