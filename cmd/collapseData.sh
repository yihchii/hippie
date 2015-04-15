#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

BED_DIR=$1
LINE=$2

cat ${BED_DIR}/*_nonspecific.bed > ${BED_DIR}/${LINE}_nonspecific.bed
cat ${BED_DIR}/*_specific.bed > ${BED_DIR}/${LINE}_specific.bed


EXITSTATUS=$?

if [ !  -s "${BED_DIR}/${LINE}_nonspecific.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

