#!/bin/bash

source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
FILE=$2
mmq=$3

#foo=(chr[[:digit:]] chr[[:digit:]][[:digit:]] chrX chrY)
#awk -v minq=${mmq} '{if ($1 != "." && $4 != "." && $8 >= minq)print;}'  ${FILE}.bed > s_${LINE}.bed
# remove mapping score lower that mmq (= min. mapping quality), 
# also remove mapping to other chromosomes (only keeps chrm 1-22, X and Y)

awk -v minq=${mmq} '{if (($1 ~/^chr[0-9|X|Y]+$/) && ($4 ~/^chr[0-9|X|Y]+$/) && $8 >= minq)print;}'  ${FILE}.bed > s_${LINE}.bed


# $SAMTOOLS view s_${LINE}_merged.bam| awk '{if(NR%2==1) {a=0;if(($0~/NM:i:[012][[:space:]]/)&&($0~/X0:i:1[[:space:]]/)){pair1=$0;a=1}} else {if(($0~/NM:i:[012][[:space:]]/)&&($0~/X0:i:1[[:space:]]/)&&(a==1)){printf "%s\n%s\n",pair1,$0} a=0;}}' > s_${LINE}_uniq.sam
# cat header.sam s_${LINE}_uniq2.sam |$SAMTOOLS view -Sb - |${BEDTOOLS} bamtobed -bedpe -i - > ${1}_filtered.bed
# awk '{if (($1 ~/^chr[0-9|X|Y]+$/) && ($4 ~/^chr[0-9|X|Y]+$/) && $8 >= minq)print;}'  ${1}_filtered.bed > s_${LINE}_new.bed



EXITSTATUS=$?

if [ !  -s "s_${LINE}.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS
