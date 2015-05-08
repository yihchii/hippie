#!/bin/bash

RE=$1
sizeSelect=$2
readLength=$3
fastaDir=$4
chrm=$5
OUT=$6
export samPath="${OUT}/sam"

perl getMappFlanking.pl ${readLength} ${samPath}/${RE}_${chrm}_Flanking${sizeSelect}_${readLength}nt_readsAligned.out.bam ${OUT}/${RE}_${chrm}_sizeSelect${sizeSelect}_${readLength}nt_mappability.bed


