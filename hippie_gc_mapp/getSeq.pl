#!/usr/bin/perl -w

use strict;
use IO::File;
use File::Basename;

if (@ARGV < 4){   
    die "need more arguments
    arg 0 = fasta file
    arg 1 = read length
		arg 2 = read spanned interval (bed format)
		arg 3 = Hi-C size slection range (eg. 500 or 800)";
}

my $seq = "";
my $inFh = IO::File->new( $ARGV[0] );
while( my $line = $inFh->getline ){
    chomp($line);
    $seq = $seq . uc $line unless $line =~ /\>/;    
}

my $readSize = $ARGV[1];

my $readInterval = $ARGV[2];
open (INT, $readInterval)||die "cannot open file $readInterval";

my $sizeSelect = $ARGV[3];

my $qual = "";
for(my $j=0;$j<$readSize;$j++) { $qual = $qual . "~";}

while(my $line = <INT>){
	chomp $line;
	my ($chr, $start, $end) = split (/\t/, $line);

	my $count = 0;

	if ($end - $start <= $sizeSelect){
		if ($end - $readSize >= $start){ # it is possible to have at least one read on this fragment
			for (my $i=$start; $i <= $end-$readSize; $i++) {
					$count+=1;
					my $read = substr($seq,$i,$readSize);
					my $readE=$i+$readSize;
					print "@"."$chr:$start-$end:$i-$readE.$count\n";
	      	print "$read\n+\n$qual\n";
			}
		}
	} else {# $end - $start > $sizeSelect 
		for (my $i=$start; $i <= $start+($sizeSelect/2)-$readSize; $i++) {
				$count+=1;
				my $read = substr($seq,$i,$readSize);
				my $readE=$i+$readSize;
				print "@"."$chr:$start-$end:$i-$readE.$count\n";
	      print "$read\n+\n$qual\n";
		}
		for (my $i=$end-($sizeSelect/2); $i <= $end-$readSize; $i++) {
				$count+=1;
				my $read = substr($seq,$i,$readSize);
				my $readE=$i+$readSize;
				print "@"."$chr:$start-$end:$i-$readE.$count\n";
	      print "$read\n+\n$qual\n";
		}
	}

}
close (INT);

