#!/usr/bin/perl -w
# find RE sites length distribution 
use strict;
use DBI;

my $usage = "Usage: perl $0 hotspot-table read-raw output";
my $hotspot_name = shift or die $usage;
my $raw_name = shift or die $usage;
my $outfile = shift or die $usage;

open(IN, "<$hotspot_name") || die "Unable to open $hotspot_name: $!";
open(OUT, ">$outfile") || die "Unable to write to $outfile: $!";

my $dbh = DBI->connect('DBI:mysql:database=Human_Hi_C;host=localhost', 'gregorylab-pub', 'pub', {RaiseError=>1});
my $sth_l = $dbh->prepare_cached(
"SELECT readID, Start1
FROM $raw_name
WHERE chrm1 = ? AND Start1 BETWEEN ? AND ?;");
my $sth_r = $dbh->prepare_cached(
"SELECT readID, Start2
FROM $raw_name
WHERE chrm2 = ? AND Start2 BETWEEN ? AND ?;");

my %readL;
my %readR;
# Scan interaction by looking it up from raw table database
<IN>;
while(my $line = <IN>){
	my ($ehotspotID, $chrm, $hStart, $hEnd, $hLength, $regionNum, $read, $clusterNum, $class) = split (/\t/,$line);
	$chrm =~ s/chr//;
  $sth_l->execute($chrm, $hStart, $hEnd);
  while(my ($readID, $Start1) = $sth_l->fetchrow_array()) {
		$readL{$readID} = $ehotspotID;
	} # while
  $sth_r->execute($chrm, $hStart, $hEnd);
  while(my ($readID, $Start2) = $sth_r->fetchrow_array()) {
		$readR{$readID} = $ehotspotID;
	} # while
}
close (IN);

# organize interaction by hotspot id
my %interaction;
foreach my $readkey (keys %readL) {
	if(exists $readR{$readkey}){
		# if the interaction is not self-interaction, read count on both ways
		if ($readL{$readkey} ne $readR{$readkey}){
			$interaction{$readL{$readkey}}{$readR{$readkey}}+=1;
			$interaction{$readR{$readkey}}{$readL{$readkey}}+=1;
		}
		else # if $readL{$readkey} eq $readR{$readkey}, read count for one-way
		{
      $interaction{$readL{$readkey}}{$readR{$readkey}}+=1;
    }
	} 
}

# print out hotspot interaction and number of reads
print OUT "HOTSPOTA\tHOTSPOTB\tREADS\n";
foreach my $HSkey_a (keys %interaction) {
	foreach my $HSkey_b (keys %{$interaction{$HSkey_a}}){
  	print OUT "$HSkey_a\t$HSkey_b\t$interaction{$HSkey_a}{$HSkey_b}\n";
	}
}
close (OUT);

