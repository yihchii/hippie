#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

java -Xmx4g -verbose:sizes -jar $GENOMICS_JAR/SortSam.jar \
VALIDATION_STRINGENCY=SILENT \
INPUT=$1.bam \
OUTPUT=${1}_sortQname.bam \
SORT_ORDER=queryname \
TMP_DIR=$TMPDIR \

EXITSTATUS=$?

if [ ! -e "${1}_sortQname.bam" ]
then
 echo "Missing output: ${1}_sortQname.bam"
 exit 100
fi


# Check BAM EOF
BAM_28=$(tail -c 28 ${1}_sortQname.bam|xxd -p)
if [ "$MAGIC28" != "$BAM_28" ]
then
  echo "Error with BAM EOF" 1>&2
  exit 100
fi

if [ $EXITSTATUS -ne 0 ];then exit $EXITSTATUS;fi

exit $EXITSTATUS
