#!/bin/bash

RE=$1
sizeSelect=$2
readLength=$3
fastaDir=$4
chrm=$5
OUT=$6

outFastqGZ=${RE}_${chrm}_Flanking${sizeSelect}_${readLength}nt_reads.fastq.gz

perl ./getSeq.pl ${fastaDir}/${chrm}.fa $readLength ${OUT}/${chrm}_${RE}_fragments.bed ${sizeSelect}|gzip -9c > ${OUT}/${outFastqGZ}
