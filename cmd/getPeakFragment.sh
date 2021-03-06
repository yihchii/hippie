#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

BED_DIR=$1
LINE=$2
RE=$3
THRE=$4
FILE="${RE}_fragment_S_reads.bed"
SIZE_SELECT=$5

if [ !  -s "${BED_DIR}/${FILE}" ]
then
 echo "Cannot find input file ${BED_DIR}/$FILE!"
 exit 100
fi

# generate peak files:
# ${RE}_fragment_S_reads_${THRE}_simple.bed
# 1chr 2start 3end 4read 5length 6readPerNt 7p-value

echo "[`date`] get filtered by threshold comparing from the nospecific read as background ${LINE}"
$RPATH/R --no-save --args "${THRE}" "${BED_DIR}/${RE}_fragment_S_reads.bed" "${BED_DIR}/${RE}_fragment_NS_reads.bed" ${BED_DIR} "${RE}_fragment_S_reads" ${SIZE_SELECT} < "${ETSCRIPT}/get_peak_fragment.R"


echo "[`date`] join the read names from specific_read_bed_file to filtered bed file"

# put back the read information to simple file
# ${RE}_fragment_S_reads.bed: 1chr 2start 3end 4readName 5numberOfRead
# ${LINE}_${RE}fragment_S_reads_${THRE}.bed: 1chr 2start 3end 4readName 5numberOfRead 6length 7readPerNt_8p-value
$BEDTOOLS intersect -sorted -a ${BED_DIR}/${RE}_fragment_S_reads.bed -b ${BED_DIR}/${RE}_fragment_S_reads_${THRE}_simple.bed -wa -wb|cut -f 1-5,10-12 > ${BED_DIR}/${LINE}_${RE}fragment_S_reads_${THRE}.bed


EXITSTATUS=$?


if [ !  -s "${BED_DIR}/${LINE}_${RE}fragment_S_reads_${THRE}.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS


