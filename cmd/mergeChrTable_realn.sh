#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

rm -f s_${1}_merged_nodup_uniq_realn_recal.ba?

if [ -e s_${1}_nodup_uniq_realn_recal.FULL.bam ];then exit 0;fi

#
# Picard (MergeSamFiles.jar)  INPUT Argument does not allow wildcards.
#                             here we make a long string of INPUT=
INPUT_STR=""

for f in s_${1}_nodup_uniq_realn_recal.chr*.bam
do
 INPUT_STR=$INPUT_STR"INPUT=$f "
done;

java -Xmx2g \
 -jar $GENOMICS_JAR/MergeSamFiles.jar \
 $INPUT_STR \
 OUTPUT=s_${1}_merged_nodup_uniq_realn_recal.bam \
 CREATE_INDEX=true \
 VALIDATION_STRINGENCY=SILENT \
 TMP_DIR=$TMPDIR \
 SORT_ORDER=coordinate \
 USE_THREADING=false 

EXITSTATUS=$?

if [ ! -s s_${1}_merged_nodup_uniq_realn_recal.bam ];then exit 100;fi;

# Check BAM EOF
BAM_28=$(tail -c 28 s_${1}_merged_nodup_uniq_realn_recal.bam|xxd -p)
if [ "$MAGIC28" != "$BAM_28" ]
then
  echo "Error with EOF" 
  exit 100
fi

exit $EXITSTATUS
