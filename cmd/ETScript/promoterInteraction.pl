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
	my ($chr, $start, $end, $inter, $reads, $promoter) = @array[0..5];
	my $hotspot = $chr.":".$start."-".$end."\t".$reads."_".$promoter;
	my @inter_arry = split (/;/,$inter);
	foreach my $int_read (@inter_arry){
		if (!exists $readhash{$int_read}){
			$readhash{$int_read} = $hotspot;
		}else { # exists readhash, means matched interaction
			my $hotspot1 = $readhash{$int_read};
			my $hotspot2 = $hotspot;
			if ($hotspot1 ne $hotspot2){
				push @{$interhash{$hotspot1."\t".$hotspot2}}, $int_read;
			}
			delete $readhash{$int_read}; # release the hash memory allocation
		}
	}
}
close(IN);



foreach my $interaction ( keys %interhash ) {
	my ($hotspot1,$read1,$hotspot2,$read2) = split ("\t",$interaction);
	my ($rd1,$promoter1) = split (/_/,$read1);	
	my ($rd2,$promoter2) = split (/_/,$read2);	
	print OUT "$hotspot1\t$hotspot2\t".scalar(@{ $interhash{$interaction} })."\t$rd1\t$rd2\t$promoter1\t$promoter2\n";
}


close(OUT);






