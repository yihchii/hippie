#!/bin/bash

source $HIPPIE_INI
source $HIPPIE_CFG

rm -f ${1}.ba?

#
# Picard (MergeSamFiles.jar)  INPUT Argument does not allow wildcards.
#                             here we make a long string of INPUT=
INPUT_STR=""

for f in $BAM_DIR/*.bam
do
 INPUT_STR=$INPUT_STR"INPUT=$f "
done;

java -Xmx5g \
 -jar $GENOMICS_JAR/MergeSamFiles.jar \
 $INPUT_STR \
 OUTPUT=$1.bam \
 CREATE_INDEX=true \
 VALIDATION_STRINGENCY=SILENT \
 TMP_DIR=$TMPDIR  \
 SORT_ORDER=coordinate \
 USE_THREADING=false 

EXITSTATUS=$?

if [ !  -s "$1.bam" ]
then
 echo "Incorrect Output!"
 exit 100
fi

# Check BAM EOF
BAM_28=$(tail -c 28 $1.bam|xxd -p)
if [ "$MAGIC28" != "$BAM_28" ]
then
  echo "Error with BAM EOF" 1>&2
  exit 100
fi

exit $EXITSTATUS
