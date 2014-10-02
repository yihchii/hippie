#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

java -Xmx4g -verbose:sizes -jar $PICARD_JAR/AddOrReplaceReadGroups.jar \
VALIDATION_STRINGENCY=SILENT \
INPUT=$1 \
OUTPUT=${2}_rg.bam \
TMP_DIR=$TMPDIR  \
SORT_ORDER=queryname \
CREATE_INDEX=true \
$RG_STR_PICARD


EXITSTATUS=$?

if [ ! -e "${2}_rg.bam" ]
then
 echo "Missing output: ${2}_rg.bam"
 exit 100
fi


# Check BAM EOF
BAM_28=$(tail -c 28 ${2}_rg.bam|xxd -p)
if [ "$MAGIC28" != "$BAM_28" ]
then
  echo "Error with BAM EOF" 1>&2
  exit 100
fi

if [ $EXITSTATUS -ne 0 ];then exit $EXITSTATUS;fi

exit $EXITSTATUS

