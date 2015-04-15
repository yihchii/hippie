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


## generate concated paired-end reads (to single end format)
## consecutive reads are generated, but not used for restriction-fragment-based analysis

echo "[`date`] Concating the file of ${BED_DIR}/${LINE}......"

cut -f1-3,9 ${BED_DIR}/$FILE > "${BED_DIR}/${LINE}_concat_S.txt"
cut -f5-7,9 ${BED_DIR}/$FILE >> "${BED_DIR}/${LINE}_concat_S.txt"

echo "[`date`] Generating sorted bed file"
sort -T $TMPDIR -k 1,1 -k 2,2n "${BED_DIR}/${LINE}_concat_S.txt" > "${BED_DIR}/${LINE}_concat_S.bed"
rm "${BED_DIR}/${LINE}_concat_S.txt"

echo "[`date`] Getting consecutive file of ${BED_DIR}/${LINE}"
$BEDTOOLS merge -i "${BED_DIR}/${LINE}_concat_S.bed" -c 4 -o collapse,count > "${BED_DIR}/${LINE}_consecutive_S.bed"

EXITSTATUS=$?

if [ !  -s "${BED_DIR}/${LINE}_consecutive_S.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

