#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

OUT="${1}_nameSorted"

samtools sort -n ${1}.bam $OUT


if [ ! -s $OUT ]
then
 echo "Incomplete output file $OUT"
 exit 100
fi
