#!/bin/bash

source $HIPPIE_INI




if [ !  -s "${1}.bed" ]
then
 echo "Cannot find input file ${1}.bed!"
 exit 100
fi



sort -T $TMPDIR -k1,1 -k2,2n -k3,3n -k4,4 -k5,5n -k6,6n -u ${1}.bed -o ${1}_rmdup.bed


EXITSTATUS=$?

if [ !  -s "${1}_rmdup.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS
