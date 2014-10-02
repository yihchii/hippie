#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

FILE=$1
LINE=$2

if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi


## generate concated paired-end reads (to single end format)
## consecutive reads are generated, but not used for restriction-fragment-based analysis

echo "[`date`] Concating the file of ${LINE}......"

cut -f1-3,7 $FILE > "${LINE}_concat_m500.txt"
cut -f4-7 $FILE >> "${LINE}_concat_m500.txt"

echo "[`date`] Generating sorted bed file"
sort -T $TMPDIR -k 1,1 -k 2,2n "${LINE}_concat_m500.txt" > "${LINE}_concat_m500.bed"
rm "${LINE}_concat_m500.txt"

echo "[`date`] Getting consecutive file of ${LINE}"
$BEDTOOLS merge -i "${LINE}_concat_m500.bed" -c 4 -o collapse,count > "${LINE}_consecutive_m500.bed"

EXITSTATUS=$?

if [ !  -s "${LINE}_consecutive_m500.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

