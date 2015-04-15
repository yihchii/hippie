#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

RE=$1
BED_DIR=$2
FILE=$3


if [ !  -s "${BED_DIR}/${FILE}.bed" ]
then
 echo "Cannot find input file ${BED_DIR}/$FILE.bed!"
 exit 100
fi

if [ !  -s "${GENOME_CHRM}/${RE}_site.bed" ]
then
 echo "Cannot find input file ${GENOME_CHRM}/${RE}_site.bed!"
 exit 100
fi



cut -f5-8,9 ${BED_DIR}/${FILE}.bed > ${BED_DIR}/${FILE}_right.bed

$BEDTOOLS closest -d -t first -a ${BED_DIR}/${FILE}_right.bed -b \
${GENOME_CHRM}/${RE}_site.bed|cut -f9 > ${BED_DIR}/${FILE}_right_distToRE.txt



EXITSTATUS=$?

if [ !  -s "${BED_DIR}/${FILE}_right_distToRE.txt" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS


