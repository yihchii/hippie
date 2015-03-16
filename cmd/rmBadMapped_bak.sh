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



EXITSTATUS=$?

if [ !  -s "s_${LINE}.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS
