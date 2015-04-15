#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

BED_DIR=$1
LINE=$2
RE=$3
FILE_S=${LINE}_concat_S.bed
FILE_NS=${LINE}_concat_NS.bed


if [ !  -s "${BED_DIR}/${FILE_S}" ]
then
 echo "Cannot find input file ${BED_DIR}/$FILE_S!"
 exit 100
fi

if [ !  -s "${BED_DIR}/${FILE_NS}" ]
then
 echo "Cannot find input file ${BED_DIR}/$FILE_NS!"
 exit 100
fi

if [ !  -s "${GENOME_CHRM_PATH}/${RE}_fragments.bed" ]
then
 echo "Cannot find restriction fragment file ${GENOME_CHRM_PATH}/${RE}_fragments.bed!"
 exit 100
fi



## map concated paired-end reads to restriction fragments

$BEDTOOLS intersect -sorted -wa -wb -a ${GENOME_CHRM_PATH}/${RE}_fragments.bed -b ${BED_DIR}/${FILE_S} -loj|awk 'BEGIN{OFS="\t";} {print $1,$2,$3,$7}'|$BEDTOOLS merge -i stdin -c 4 -o collapse,count | awk 'BEGIN{OFS="\t"}{if($4~/^\.$/)print $1,$2,$3,$4,0;else print $0}'> ${BED_DIR}/${RE}_fragment_S_reads.bed

$BEDTOOLS intersect -sorted -wa -wb -a ${GENOME_CHRM_PATH}/${RE}_fragments.bed -b ${BED_DIR}/${FILE_NS} -loj|awk 'BEGIN{OFS="\t";}{print $1,$2,$3,$7}'|$BEDTOOLS merge -i - -c 4 -o collapse,count | awk 'BEGIN{OFS="\t"}{if($4~/^\.$/)print $1,$2,$3,$4,0;else print $0}'> ${BED_DIR}/${RE}_fragment_NS_reads.bed


EXITSTATUS=$?

if [ !  -s "${BED_DIR}/${RE}_fragment_NS_reads.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

if [ !  -s "${BED_DIR}/${RE}_fragment_S_reads.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

