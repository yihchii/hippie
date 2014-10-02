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


cut -f4-7,8,10 s_${LINE}.bed > s_${LINE}_right.bed

$BEDTOOLS closest -d -t first -a s_${LINE}_right.bed -b \
${GENOME_CHRM}/${RE}_site.bed|cut -f10 >s_${LINE}_right_distToRE.txt



EXITSTATUS=$?

if [ !  -s "s_${LINE}_right_distToRE.txt" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

