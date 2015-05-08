#!/bin/bash

source "./setup.ini"

export RESITE=$1
export RE=$2
export fastaDir=$3
export OUT=$4

# skipping chromosome M
fastaFiles=$(ls -d1 -v $fastaDir/*|grep "chr[A-LN-Z0-9]\{1,2\}.fa$")

# get 6 basepair RE site coordinages sorted
perl get_RE_coordinates.pl $RESITE ${fastaFiles[*]} chrom_length.txt |sort -k1,1 -k2,2n > ${RE}_site.bed

# get the restriction fragment
$BEDTOOLS complement -i ${RE}_site.bed -g chrom_length.txt |sort -k1,1 -k2,2n > ${RE}_fragments.bed

# split the fragment files by chromosomes
awk -v re=${RE} -v out=${OUT} 'BEGIN{OFS="\t"}{print $0 > out"/"$1"_"re"_fragments.bed"}' ${RE}_fragments.bed


