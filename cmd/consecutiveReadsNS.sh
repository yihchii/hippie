#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

BED_DIR=$1
FILE=$2
LINE=$3

if [ !  -s "${BED_DIR}/${FILE}" ]
then
 echo "Cannot find input file ${BED_DIR}/$FILE!"
 exit 100
fi


echo "[`date`] Concating the file of ${LINE}......"

cut -f1-3,9 ${BED_DIR}/$FILE > "${BED_DIR}/${LINE}_concat_NS.txt"
cut -f5-7,9 ${BED_DIR}/$FILE >> "${BED_DIR}/${LINE}_concat_NS.txt"

echo "[`date`] Generating sorted bed file"
sort -T $TMPDIR -k 1,1 -k 2,2n "${BED_DIR}/${LINE}_concat_NS.txt" > "${BED_DIR}/${LINE}_concat_NS.bed"
rm "${BED_DIR}/${LINE}_concat_NS.txt"

echo "[`date`] Getting consecutive file of ${LINE}"
$BEDTOOLS merge -i "${BED_DIR}/${LINE}_concat_NS.bed" -c 4 -o collapse,count > "${BED_DIR}/${LINE}_consecutive_NS.bed"

EXITSTATUS=$?

if [ !  -s "${BED_DIR}/${LINE}_consecutive_NS.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

