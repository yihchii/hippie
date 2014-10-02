#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
RE=$2
THRE=$3
FILE="${RE}_fragment_S_reads.bed"

if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi

echo "[`date`] get filtered by threshold comparing from the nospecific read as background ${LINE}"
/usr/local/bin/R --no-save --args "${THRE}" "${RE}_fragment_S_reads.bed" "${RE}_fragment_NS_reads.bed" < "${ETSCRIPT}/cluster_fragments.R"

echo "[`date`] join the read names from specific_read_bed_file to filtered bed file"


#bedtools intersect -sorted -a ${RE}_fragment_S_reads.bed -b ${RE}_fragment_S_reads_${THRE}_simple.bed -wa -wb|cut -f 1-5,10-12 > ${RE}_fragment_S_reads_${THRE}.bed

#awk '{printf("%s:%s:%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $3, $1, $2, $3, $4, $5);}' ${RE}_fragment_S_reads.bed |sort -k1,1 -T $TMPDIR | join -1 1 -2 1 -o 1.2,1.3,1.4,1.5,1.6,2.2,2.3 -t $'\t' - ${RE}_fragment_S_reads_${THRE}_simple.bed > ${RE}_fragment_S_reads_${THRE}.bed


EXITSTATUS=$?


if [ !  -s "${RE}_fragment_S_reads_${THRE}.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS


