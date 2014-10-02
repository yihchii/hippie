#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

java -Xmx4g -jar $PICARD_JAR/AddOrReplaceReadGroups.jar \
VALIDATION_STRINGENCY=SILENT \
INPUT=${1} \
OUTPUT=${1}_rg.bam \
TMP_DIR=$TMPDIR  \
SORT_ORDER=queryname \
MAX_RECORDS_IN_RAM=5000000 \
CREATE_INDEX=true \
$RG_STR_PICARD
EXITSTATUS=$?
#MAX_RECORDS_IN_RAM=1000000 \
if [ ! -e "${1}_rg.bam" ]
then
 echo "Missing output: ${1}_rg.bam"
 exit 100
fi


# Check BAM EOF
BAM_28=$(tail -c 28 ${1}_rg.bam|xxd -p)
if [ "$MAGIC28" != "$BAM_28" ]
then
  echo "Error with BAM EOF" 1>&2
  exit 100
fi

if [ $EXITSTATUS -ne 0 ];then exit $EXITSTATUS;fi

exit $EXITSTATUS

