#!/bin/bash

source $HIPPIE_INI
source $HIPPIE_CFG

rm -f ${1}_merged.ba?

# Check for core dumps (errors) from bwa
CORE_LIST=$(ls core.*)
if [ -n "$CORE_LIST" ]
  then  
   echo "Found core dumps from bwa. Exiting with error."
   exit 100
fi

#
# Picard (MergeSamFiles.jar)  INPUT Argument does not allow wildcards.
#                             here we make a long string of INPUT=
INPUT_STR=""

for f in $SAM_DIR/*.aligned.sam.gz
do
 INPUT_STR=$INPUT_STR"INPUT=$f "
done;

java -Xmx5g \
 -jar $GENOMICS_JAR/MergeSamFiles.jar \
 $INPUT_STR \
 OUTPUT=${1}_merged.bam \
 CREATE_INDEX=true \
 VALIDATION_STRINGENCY=SILENT \
 TMP_DIR=$TMPDIR  \
 SORT_ORDER=coordinate \
 USE_THREADING=false 

EXITSTATUS=$?

if [ !  -s "${1}_merged.bam" ]
then
 echo "Incorrect Output!"
 exit 100
fi

# Check BAM EOF
BAM_28=$(tail -c 28 ${1}_merged.bam|xxd -p)
if [ "$MAGIC28" != "$BAM_28" ]
then
  echo "Error with BAM EOF" 1>&2
  exit 100
fi

exit $EXITSTATUS
#
# check if file size less than 1GB

#if [ $(stat --printf="%s" "s_${1}.merged.bam") -le 1024000000 ]
#then
# echo "Error. Output BAM file is too small."
# exit 100
#fi

#
# check if file size less than half total SAM files
# S1=$(stat --printf="%s" "s_${1}.merged.bam")
# S2=$(du -b $SAM_DIR|cut -f1)
# S3=$[ $S2 / 2 ]
# if [ $S1 -le $S3 ]
# then
#  echo "Error. Output BAM file is smaller then half the total SAM files."
#  exit 100
# fi

# if [ -s "s_${1}.merged.bam" ];then
#   samtools view -b -F 4 s_${1}.merged.bam -o s_${1}.bam && \
#   samtools index s_${1}.bam s_${1}.bai
#   
# fi

