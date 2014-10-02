#!/usr/bin/perl -w

use strict;


my $usage = "perl $0 ehotspot1 ehotspot2 output-interaction";
my $hotspot_file1 = shift || die $usage;
my $hotspot_file2 = shift || die $usage;
my $output = shift || die $usage;

open (IN1, $hotspot_file1)|| die "Cannot open file $hotspot_file1";
open (IN2, $hotspot_file2)|| die "Cannot open file $hotspot_file2";
open (OUT, ">>$output")||die "Cannot open file $output";

my %readhash;
while (my $line = <IN1>){
	chomp $line;
	my ($chr, $start, $end, $inter, $reads) = split (/\t/,$line);
	my $hotspot = $chr.":".$start."-".$end."\t".$reads;
	my @inter_arry = split (/;|,/,$inter);# \; for old version of bedtools merge, \, for newer version
	foreach my $int_read (@inter_arry){
		if (!exists $readhash{$int_read}){
			$readhash{$int_read} = $hotspot;
		}else { # exists interachs, means matched interaction on the same chromosome, no need to record
			delete $readhash{$int_read};
		}
	}
}
close(IN1);

my %interhash;
while (my $line = <IN2>){
			chomp $line;
			my ($chr, $start, $end, $inter, $reads) = split (/\t/,$line);
			my $hotspot = $chr.":".$start."-".$end."\t".$reads;
			my @inter_arry = split (/;|,/,$inter);# \; for old version of bedtools merge, \, for newer version
			foreach my $int_read (@inter_arry){
				if(exists $readhash{$int_read}){
					my $hotspot1 = $readhash{$int_read};
					my $hotspot2 = $hotspot;
					push @{$interhash{$hotspot1."\t".$hotspot2}}, $int_read;
				}
			}
}
close(IN2);

foreach my $interaction ( keys %interhash ) {
	my ($hotspot1,$read1,$hotspot2,$read2) = split ("\t",$interaction);
	print OUT "$hotspot1\t$hotspot2\t".scalar(@{ $interhash{$interaction} })."\t$read1\t$read2\n";
}

close(OUT);
