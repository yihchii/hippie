#!/bin/bash
# For bwa reference see http://bio-bwa.sourceforge.net/bwa.shtml

source $HIPPIE_INI
source $HIPPIE_CFG

mkdir -p $SAI_DIR

#run and check pair _1_ and then pair _2_ 

if [ -s "$FASTQ_DIR/s_${2}_1_${1}.fastq.gz" ]
then
     echo bwa aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/s_${2}_1_${1}.sai $FASTQ_DIR/s_${2}_1_${1}.fastq.gz 

     bwa aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/s_${2}_1_${1}.sai $FASTQ_DIR/s_${2}_1_${1}.fastq.gz 
else
    echo bwa aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/s_${2}_1_${1}.sai $FASTQ_DIR/s_${2}_1_${1}.fastq 

    bwa aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/s_${2}_1_${1}.sai $FASTQ_DIR/s_${2}_1_${1}.fastq  

fi

#force error when missing/empty sai . Would prevent continutation of pipeline
if [ ! -s "$SAI_DIR/s_${2}_1_${1}.sai" ]
then
 echo "Missing SAI:$SAI_DIR/s_${2}_1_${1}.sai file!"
 exit 100
fi


: << 'END'
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

else
# non gz files

  LINESFASTQ1=$(wc -l "$FASTQ_DIR/s_${2}_1_${1}.fastq" | cut -d" " -f1 )
 
fi

  echo "Fastq1 number lines:= " $LINESFASTQ1

  SEQLINES=$[ $LINESFASTQ1 / 4 ]

  echo "Estimated Minimum Sequences:= " $SEQLINES

  if (( "$PROCESSED" >= "$SEQLINES" ))
   then 
    echo "Complete."
   else
    echo "Error, incorrect number of processed sequences"
    exit 100
  fi


#####################################################################################################
# PAIR _2_
# run and check pair _2_
#
#
#####################################################################################################

if [ -s "$FASTQ_DIR/s_${2}_2_${1}.fastq.gz" ]
then
     bwa aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/s_${2}_2_${1}.sai $FASTQ_DIR/s_${2}_2_${1}.fastq.gz
else
     bwa aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/s_${2}_2_${1}.sai $FASTQ_DIR/s_${2}_2_${1}.fastq 
fi


#force error when missing/empty sai . Would prevent continutation of pipeline
if [ ! -s "$SAI_DIR/s_${2}_2_${1}.sai" ]
then
 echo "Missing SAI:$SAI_DIR/s_${2}_2_${1}.sai file!"
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


if [ -s "$FASTQ_DIR/s_${2}_2_${1}.fastq.gz" ]
then

  LINESFASTQ2=$(zcat "$FASTQ_DIR/s_${2}_2_${1}.fastq.gz" | wc -l)

else
# non gz files

  LINESFASTQ2=$(wc -l "$FASTQ_DIR/s_${2}_2_${1}.fastq" | cut -d" " -f1 )
 
fi

  echo "Fastq2 number lines:= " $LINESFASTQ2

  SEQLINES=$[ $LINESFASTQ2 / 4 ]

  echo "Estimated Minimum Sequences:= " $SEQLINES

  if (( "$PROCESSED" >= "$SEQLINES" ))
   then 
    echo "Complete."
   else
    echo "Error, incorrect number of processed sequences"
    exit 100
  fi
