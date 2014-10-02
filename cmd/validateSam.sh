#!/bin/bash

source $HIPPIE_INI
source $HIPPIE_CFG

java -Xmx5g \
 -jar $GENOMICS_JAR/ValidateSamFile.jar \
 INPUT=$1.bam \
 OUTPUT=$1.samval \
 IGNORE=MATE_NOT_FOUND \
 MAX_OUTPUT=1000 \
 VALIDATE_INDEX=true

exit $EXITSTATUS
