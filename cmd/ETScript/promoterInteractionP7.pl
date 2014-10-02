#!/usr/bin/perl -w

use strict;


my $usage = "perl $0 ehotspot output-interaction";
my $hotspot_file = shift || die $usage;
my $output = shift || die $usage;

open (IN, $hotspot_file)|| die "Cannot open file $hotspot_file";
open (OUT, ">$output")||die "Cannot open file $output";

my %readhash;
my %interhash;
while (my $line = <IN>){
	chomp $line;
	my @array = split (/\t/,$line);
# 1chr, 2start, 3end, 4readName, 5read, 6length, 7ave_read, 8pvalue, 9promoter, 10genesym
	my ($chr, $start, $end, $inter, $reads, $normReads, $pvalue, $promoter,$symbol) = @array[0..4, 6..9];
	my $hotspot = $chr.":".$start."-".$end."\t".$reads."_".$normReads."_".$pvalue."_".$promoter."_".$symbol;
	my @inter_arry = split (/;|,/,$inter); # \; for old version of bedtools merge, \, for newer version
	foreach my $int_read (@inter_arry){
		if (!exists $readhash{$int_read}){
			$readhash{$int_read} = $hotspot;
		}else { # exists readhash, means matched interaction
			my $hotspot1 = $readhash{$int_read};
			my $hotspot2 = $hotspot;
			my @temp = split (/_/,$hotspot1);

		# 2014/01/28: 
		# Edit to keep only promoter involved interations (promoter proportion > 0) 
			if (($hotspot1 ne $hotspot2) && ($temp[3] > 0 || $promoter > 0)){
        ## 20140728: remove neighbor interaction
        my ($hotspot1_chr,$hotspot1_start,$hotspot1_end,$hotspot1_read) = split (/:|-|\t/,$hotspot1);
        my $linear_dist = ($start>$hotspot1_end)?abs($start-$hotspot1_end):abs($hotspot1_start-$end);
        if ($linear_dist > 6){ # remove the neighboring interactions (ie. two RE fragments with one RE site)
					push @{$interhash{$hotspot1."\t".$hotspot2}}, $int_read;
				}
			}
			delete $readhash{$int_read}; # release the hash memory allocation
		}
	}
}
close(IN);


foreach my $interaction ( keys %interhash ) {
	my ($hotspot1,$read1,$hotspot2,$read2) = split ("\t",$interaction);
	my ($rd1,$normRd1,$pvalue1,$promoter1, $symbol1) = split (/_/,$read1);	
	my ($rd2,$normRd2,$pvalue2,$promoter2, $symbol2) = split (/_/,$read2);
	print OUT "$hotspot1\t$hotspot2\t".scalar(@{ $interhash{$interaction} })."\t$rd1\t$normRd1\t$pvalue1\t$promoter1\t$symbol1\t$rd2\t$normRd2\t$pvalue2\t$promoter2\t$symbol2\n";
#chr3:160125465-160129359        chr3:182616236-182620184        1       530     1.06    0.00700000000000001     0.000000      .=.:-1--1       645     1.29    0.00600000000000001     0.000000        .=.:-1--1 

}

close(OUT);



