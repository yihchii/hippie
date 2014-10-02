#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

java -Xmx2g -verbose:sizes -jar $GENOMICS_JAR/MarkDuplicates.jar \
VALIDATION_STRINGENCY=SILENT \
INPUT=$1.bam \
OUTPUT=${1}_markdup.bam \
TMP_DIR=$TMPDIR  \
REMOVE_DUPLICATES=false \
CREATE_INDEX=true \
METRICS_FILE=metrics \
MAX_RECORDS_IN_RAM=1000000 \
OPTICAL_DUPLICATE_PIXEL_DISTANCE=10

EXITSTATUS=$?

if [ ! -e "${1}_markdup.bam" ]
then
 echo "Missing output: ${1}_markdup.bam"
 exit 100
fi


# Check BAM EOF
BAM_28=$(tail -c 28 ${1}_markdup.bam|xxd -p)
if [ "$MAGIC28" != "$BAM_28" ]
then
  echo "Error with BAM EOF" 1>&2
  exit 100
fi

if [ $EXITSTATUS -ne 0 ];then exit $EXITSTATUS;fi

exit $EXITSTATUS
