#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
RE=$2
FILE=s_${LINE}.bed


if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi


## map concated paired-end reads to restriction fragments

$BEDTOOLS intersect -sorted -wa -wb -a ${GENOME_CHRM}/${RE}_fragments.bed -b ${LINE}_concat_m500.bed -loj|awk 'BEGIN{OFS="\t";} {print $1,$2,$3,$7}'|$BEDTOOLS merge -i stdin -c 4 -o collapse,count | awk 'BEGIN{OFS="\t"}{if($4~/^\.$/)print $1,$2,$3,$4,0;else print $0}'> ${RE}_fragment_S_reads.bed

$BEDTOOLS intersect -sorted -wa -wb -a ${GENOME_CHRM}/${RE}_fragments.bed -b ${LINE}_concat_NS.bed -loj|awk 'BEGIN{OFS="\t";}{print $1,$2,$3,$7}'|$BEDTOOLS merge -i - -c 4 -o collapse,count | awk 'BEGIN{OFS="\t"}{if($4~/^\.$/)print $1,$2,$3,$4,0;else print $0}'> ${RE}_fragment_NS_reads.bed


EXITSTATUS=$?

if [ !  -s "${RE}_fragment_NS_reads.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

