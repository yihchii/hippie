#!/usr/bin/perl -w
use strict;
use POSIX; 
my $usage = "Usage: perl $0 perlMath_path frag_i interaction_i gc_binned_o len_binned_o frag_inter_o";

use Math::CDF qw(:all);

my $frag_i = shift||die $usage;
my $inter_i = shift|| die $usage;

my $gc_binned_o = shift || die $usage;
my $len_binned_o = shift || die $usage;
my $frag_inter_o = shift || die $usage;

open (LEN_BINNED_O, ">$gc_binned_o")||die "Cannot open file $gc_binned_o";
open (GC_BINNED_O, ">$len_binned_o")||die "Cannot open file $len_binned_o";
open (FRAG_INTER_O, ">$frag_inter_o")||die "Cannot open file $frag_inter_o";

open (FRAG_I, $frag_i)||die "Cannot open file $frag_i";
open (INTER_I, $inter_i)||die "Cannot open file $inter_i";

## Read fragment characteristic file
my %gc_h;
my %mapp_h;
my %len_h;
while (my $line = <FRAG_I>){
	chomp $line;
	my ($chr, $start, $end, $gc, $mapp, $len) = split (/\t/,$line);
	my $frag = "$chr:$start-$end";
	$gc_h{$frag} = $gc;
	$mapp_h{$frag} = $mapp; # test mappability
	$len_h{$frag} = $len;
}
close(FRAG_I);

## Read interaction file
## and start generating the binning
my %gcbin_sum;
my %gcbin_count;
my %lenbin_sum;
my %lenbin_count;
my $gc_all_sum;
my $gc_all_count;
#my %inter_h;
print "Reading $inter_i and updating estimations of L_{i,j} and F^{gc}_{ij}... \n";
while (my $line = <INTER_I>){
	chomp $line;
	my ($frag1, $frag2, $read,$rf1,$rf2) = split (/\t/, $line);

	if (exists ($mapp_h{$frag1})&& exists ($mapp_h{$frag2})&& $mapp_h{$frag1}>0.2&& $mapp_h{$frag2}>0.2){

	## GC content binning
	my $cat_gc_1 = ceil($gc_h{$frag1}/0.05);
	my $cat_gc_2 = ceil($gc_h{$frag2}/0.05);
	my ($cat_gc_s,$cat_gc_b) = sort{$a <=> $b}($cat_gc_1,$cat_gc_2);

	$gcbin_sum{"$cat_gc_s,$cat_gc_b"}+=$read/($mapp_h{$frag1}*$mapp_h{$frag2});
	$gcbin_count{"$cat_gc_s,$cat_gc_b"}+=1;
	$gc_all_sum += $read/($mapp_h{$frag1}*$mapp_h{$frag2});
	$gc_all_count += 1;

	# fragnemt length binning
	my $cat_len_1 = ceil($len_h{$frag1}/2);
	my $cat_len_2 = ceil($len_h{$frag2}/2);
	my ($cat_len_s,$cat_len_L) = sort{$a <=> $b}($cat_len_1,$cat_len_2);

	$lenbin_sum{"$cat_len_s,$cat_len_L"}+=$read/($mapp_h{$frag1}*$mapp_h{$frag2});
	$lenbin_count{"$cat_len_s,$cat_len_L"}+=1;

#	$inter_h{$frag1."\t".$frag2} = "$cat_gc_s,$cat_gc_b"."\t"."$cat_len_s,$cat_len_L"."\t".join ("\t", $read,$gc_h{$frag1},$gc_h{$frag2},$mapp_h{$frag1},$mapp_h{$frag2},$rf1,$rf2) ;
	} # if mapp > 0.2
}
close(INTER_I);

my %f_value;
foreach my $gc_key (keys %gcbin_sum) {
	my ($cat_gc_s, $cat_gc_b) = split (/,/, $gc_key);
	$f_value{$gc_key} = ($gcbin_sum{$gc_key}/$gcbin_count{$gc_key})/($gc_all_sum/$gc_all_count);
	print GC_BINNED_O join("\t",$gc_key,$f_value{$gc_key},$gcbin_sum{$gc_key},$gcbin_count{$gc_key},$gc_all_sum,$gc_all_count)."\n";
	delete $gcbin_sum{$gc_key};
  delete $gcbin_count{$gc_key};	
}
undef %gcbin_sum; undef %gcbin_count;  
close(GC_BINNED_O);

my %L_value;
foreach my $len_key (keys %lenbin_sum) {
	$L_value{$len_key} = $lenbin_sum{$len_key}/$lenbin_count{$len_key};
	print LEN_BINNED_O join("\t",$len_key,$L_value{$len_key},$lenbin_sum{$len_key},$lenbin_count{$len_key})."\n";	
	delete $lenbin_sum{$len_key};
	delete $lenbin_count{$len_key};
}
undef %lenbin_sum;
undef %lenbin_count;
close(LEN_BINNED_O);

my $prob = 1 - 1/2.057;
print "Writing out statistical value for interactions for interchromosomal interactions...\n";
open (INTER_I, $inter_i)||die "Cannot open file $inter_i";
## Read fragment characteristic file
while (my $line = <INTER_I>){
  chomp $line;
  my ($frag1, $frag2, $read, $rf1, $rf2) = split (/\t/, $line);
  if (exists ($mapp_h{$frag1})&& exists ($mapp_h{$frag2})&& $mapp_h{$frag1}>0.2&& $mapp_h{$frag2}>0.2){

	  ## GC content binning
	  my $cat_gc_1 = ceil($gc_h{$frag1}/0.05);
	  my $cat_gc_2 = ceil($gc_h{$frag2}/0.05);
	  my ($cat_gc_s,$cat_gc_b) = sort{$a <=> $b}($cat_gc_1,$cat_gc_2);
		my $gc_key = "$cat_gc_s,$cat_gc_b";

	  # fragnemt length binning
	  my $cat_len_1 = ceil($len_h{$frag1}/2);
	  my $cat_len_2 = ceil($len_h{$frag2}/2);
	  my ($cat_len_s,$cat_len_L) = sort{$a <=> $b}($cat_len_1,$cat_len_2);
		my $len_key = "$cat_len_s,$cat_len_L";

		my $u = $f_value{$gc_key} * $mapp_h{$frag1} * $mapp_h{$frag2} * $L_value{$len_key};
		my $p = 1 - pnbinom($read,$u,$prob);
 	  print FRAG_INTER_O join ("\t", ($frag1,$frag2, $p, $read, $rf1,$rf2))."\n";
	}
}
close(INTER_I);
close(FRAG_INTER_O);
