#!/bin/bash

source $HIPPIE_INI
source $HIPPIE_CFG

export BED_DIR=$1
export BEDFILE=$2

if [ !  -s "${BED_DIR}/${BEDFILE}.bed" ]
then
 echo "Cannot find input file ${BED_DIR}/${BEDFILE}.bed!"
 exit 100
fi

sort -T $TMPDIR -k1,1 -k2,2n -k5,5 -k6,6n -u ${BED_DIR}/${BEDFILE}.bed -o ${BED_DIR}/${BEDFILE}_rmdup.bed


EXITSTATUS=$?

if [ !  -s "${BED_DIR}/${BEDFILE}_rmdup.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS
