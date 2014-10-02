#!/bin/bash

source $HIPPIE_INI
source $HIPPIE_CFG

${BEDTOOLS} bamtobed -bedpe -i ${1}.bam > ${1}.bed

EXITSTATUS=$?

if [ !  -s "${1}.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS
