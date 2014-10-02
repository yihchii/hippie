#!/bin/bash

source $HIPPIE_INI

rm -f ${1}_merged.ba?

# Check for core dumps (errors) from bwa
CORE_LIST=$(ls core.*)
if [ -n "$CORE_LIST" ]
  then  
   echo "Found core dumps from bwa. Exiting with error."
   exit 100
fi

arr=($(ls $BAM_DIR/*.bam))
#bamct=$(ls ../$BAM_DIR/*.bam|wc -l)
if [ ${#arr[@]} -eq 0 ]
  then
   echo "Error: No BAM files found in BAM_DIR($BAM_DIR)"
   exit 100
elif [ ${#arr[@]} -eq 1 ]
	then
#	bam1=$(ls $BAM_DIR/*.bam | head -1)
	cp ${arr[0]} ${1}_merged.bam
else
	# create sam header for merged bam
#	bam1=$(ls $BAM_DIR/*.bam | head -1)
	$SAMTOOLS view -H ${arr[0]} | grep -v RG > header.sam
	
	for i in `ls $BAM_DIR/*.bam`;do samtools view -H $i | grep RG;done | sort | uniq >> header.sam
	
	$SAMTOOLS merge -n -h header.sam ${1}_merged.bam $BAM_DIR/*.bam
fi




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

$SAMTOOLS index ${1}_merged.bam ${1}_merged.bai

exit $EXITSTATUS
