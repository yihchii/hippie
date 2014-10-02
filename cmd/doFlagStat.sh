#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

if [ -z $STAT_DIR ];then
  OUT="${1}.flagstat"
else
	mkdir -p $STAT_DIR
  OUT="$STAT_DIR/${1}.flagstat"
fi


samtools flagstat ${1}.bam > $OUT

if [ ! -s $OUT ]
then
 echo "Incomplete output file $OUT"
 exit 100
fi
