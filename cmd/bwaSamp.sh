#!/bin/bash

source $HIPPIE_INI
source $HIPPIE_CFG

mkdir -p $SAM_DIR

if [ -s "$FASTQ_DIR/s_${2}_1_${1}.fastq.gz" ]
then

 bwa sampe -a 1000000 -r "$3" $REF_FASTA \
  $SAI_DIR/s_${2}_1_${1}.sai \
  $SAI_DIR/s_${2}_2_${1}.sai \
  $FASTQ_DIR/s_${2}_1_${1}.fastq.gz \
  $FASTQ_DIR/s_${2}_2_${1}.fastq.gz | gzip > $SAM_DIR/s_${2}_${1}.aligned.sam.gz

else

 bwa sampe -a 1000000 -r "$3" $REF_FASTA \
  $SAI_DIR/s_${2}_1_${1}.sai \
  $SAI_DIR/s_${2}_2_${1}.sai \
  $FASTQ_DIR/s_${2}_1_${1}.fastq \
  $FASTQ_DIR/s_${2}_2_${1}.fastq | gzip > $SAM_DIR/s_${2}_${1}.aligned.sam.gz


fi

#
# check if file size less than 1MB

if [ $(stat --printf="%s" "$SAM_DIR/s_${2}_${1}.aligned.sam.gz") -le 1024000 ]
then
 echo "Error with output."
 exit 100
fi


: <<'END'
#
# check STDOUT has correct termination string
HASENDING=$(tail -1 $SGE_STDOUT_PATH | grep " sequences have been processed.")

if [ -n "$HASENDING" ]
 then 
  OK=1
 else 
  #echo " empty variable"
  echo "Improper stdout termination"
  exit 100
fi 
END


#
#check for correct number of sequences processed, based on fastq records

# PROCESSED=$(tail -1 $SGE_STDOUT_PATH | grep -o -P " \d+ ")
 PROCESSED=$(grep " sequences have been processed." $SGE_STDOUT_PATH |tail -1| grep -o -P " \d+ ")

echo "checking stdout file: " $SGE_STDOUT_PATH

echo "bwa processed" $PROCESSED


if [ -s "$FASTQ_DIR/s_${2}_1_${1}.fastq.gz" ]
then

  LINESFASTQ1=$(zcat "$FASTQ_DIR/s_${2}_1_${1}.fastq.gz" | wc -l)
  LINESFASTQ2=$(zcat "$FASTQ_DIR/s_${2}_2_${1}.fastq.gz" | wc -l)

else
# non gz files

  LINESFASTQ1=$(wc -l "$FASTQ_DIR/s_${2}_1_${1}.fastq" | cut -d" " -f1 )
  LINESFASTQ2=$(wc -l "$FASTQ_DIR/s_${2}_2_${1}.fastq" | cut -d" " -f1 )
 
fi

  echo "Fastq1 number lines:= " $LINESFASTQ1
  echo "Fastq2 number lines:= " $LINESFASTQ2

  if (( "$LINESFASTQ1" >= "$LINESFASTQ2" ))
  then
    SEQLINES=$[ $LINESFASTQ2 / 4 ]
  else
    SEQLINES=$[ $LINESFASTQ1 / 4 ]
  fi

  echo "Estimated Minimum Sequences:= " $SEQLINES

  if (( "$PROCESSED" >= "$SEQLINES" ))
   then 
    echo "Complete."
   else
    echo "Error, incorrect number of processed sequences"
    exit 100
  fi
 
