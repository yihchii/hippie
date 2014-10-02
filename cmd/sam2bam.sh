#!/bin/bash

source $HIPPIE_INI

samtools view -uS $SAM_DIR/${1}.aligned.sam.gz | samtools sort - $BAM_DIR/${1}.sorted

EXITSTATUS=$?

if [ !  -s "$BAM_DIR/${1}.sorted.bam" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS
