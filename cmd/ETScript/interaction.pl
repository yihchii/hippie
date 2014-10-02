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
	my ($chr, $start, $end, $inter, $reads) = split (/\t/,$line);
	if ($inter eq "."){
		next;
	}
	my $hotspot = $chr.":".$start."-".$end."\t".$reads;
	my @inter_arry = split (/;|,/,$inter); # \; for old version of bedtools merge, \, for newer version
	foreach my $int_read (@inter_arry){
		if (!exists $readhash{$int_read}){
			$readhash{$int_read} = $hotspot;
		}else { # exists readhash, means matched interaction
			my $hotspot1 = $readhash{$int_read};
			my $hotspot2 = $hotspot;

			if ($hotspot1 ne $hotspot2){
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
	print OUT "$hotspot1\t$hotspot2\t".scalar(@{ $interhash{$interaction} })."\t$read1\t$read2\n";
}


close(OUT);






