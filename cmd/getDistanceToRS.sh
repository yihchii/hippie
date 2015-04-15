#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

BED_DIR=$1
TASK=$2
SIZE_SELECT=$3
RRSIZE=$4
RE=$5

FILE=${2}_rmdup.bed
if [ !  -s "${BED_DIR}/${FILE}" ]
then
 echo "Cannot find input file ${BED_DIR}/$FILE!"
 exit 100
fi

if [ !  -s "${GENOME_CHRM_PATH}/${RE}_site.bed" ]
then
 echo "Cannot find input file ${GENOME_CHRM_PATH}/${RE}_site.bed!"
 exit 100
fi

$PYTHON ${ETSCRIPT}/get_closest_RS_distance.py ${RRSIZE} ${GENOME_CHRM_PATH}/${RE}_site.bed ${BED_DIR}/${FILE} ${BED_DIR}/${2}_rmdup_distToRS.bed

awk -v t=${TASK} -v size=$SIZE_SELECT -v beddir=${BED_DIR} '{if ($11+$12 <= size)print > beddir"/"t"_specific.bed"; else print >beddir"/"t"_nonspecific.bed";}' ${BED_DIR}/${2}_rmdup_distToRS.bed


EXITSTATUS=$?

if [ !  -s "${BED_DIR}/${TASK}_nonspecific.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

