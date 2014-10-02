#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

#./README_HOTSPOT.sh ./original_data/GSM455133_30E0LAAXX.1.maq.hic.summary.binned.txt PBALL
LINE=$1
FILE=s_${LINE}.bed


if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi


paste ${FILE} s_${LINE}_left_distToRE.txt s_${LINE}_right_distToRE.txt| awk -v l=${LINE} '{if ($11+$12 <= 500)print > "s_"l"_specific.bed"; else print >"s_"l"_nonspecific.bed";}'


EXITSTATUS=$?

if [ !  -s "s_${LINE}_nonspecific.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

