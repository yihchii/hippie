#!/bin/bash
# For bwa reference see http://bio-bwa.sourceforge.net/bwa.shtml

source $HIPPIE_INI
source $HIPPIE_CFG

mkdir -p $SAI_DIR
TWOFILE=$(echo $1|sed 's/_1/_2/')

#run and check pair _1 and then pair _2 

if [ -s "$FASTQ_DIR/${1}.fastq.gz" ]
then
echo $BWA aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/${1}.sai $FASTQ_DIR/${1}.fastq.gz 
     $BWA aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/${1}.sai $FASTQ_DIR/${1}.fastq.gz 
else
echo $BWA aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/${1}.sai $FASTQ_DIR/${1}.fastq 
     $BWA aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/${1}.sai $FASTQ_DIR/${1}.fastq 
fi

#force error when missing/empty sai . Would prevent continutation of pipeline
if [ ! -s "$SAI_DIR/${1}.sai" ]
then
 echo "Missing SAI:$SAI_DIR/${1}.sai file!"
 exit 100
fi

#
# check STDOUT has correct termination string
: <<'END'
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


if [ -s "$FASTQ_DIR/${1}.fastq.gz" ]
then

  LINESFASTQ1=$(zcat "$FASTQ_DIR/${1}.fastq.gz" | wc -l)

else
# non gz files

  LINESFASTQ1=$(wc -l "$FASTQ_DIR/${1}.fastq" | cut -d" " -f1 )
 
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

if [ -s "$FASTQ_DIR/$TWOFILE.fastq.gz" ]
then
  echo $BWA aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/$TWOFILE.sai $FASTQ_DIR/$TWOFILE.fastq.gz
       $BWA aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/$TWOFILE.sai $FASTQ_DIR/$TWOFILE.fastq.gz
else
  echo $BWA aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/$TWOFILE.sai $FASTQ_DIR/$TWOFILE.fastq 
       $BWA aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/$TWOFILE.sai $FASTQ_DIR/$TWOFILE.fastq 
fi


#force error when missing/empty sai . Would prevent continutation of pipeline
if [ ! -s "$SAI_DIR/$TWOFILE.sai" ]
then
 echo "Missing SAI:$SAI_DIR/$TWOFILE.sai file!"
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


if [ -s "$FASTQ_DIR/$TWOFILE.fastq.gz" ]
then

  LINESFASTQ2=$(zcat "$FASTQ_DIR/$TWOFILE.fastq.gz" | wc -l)

else
# non gz files

  LINESFASTQ2=$(wc -l "$FASTQ_DIR/$TWOFILE.fastq" | cut -d" " -f1 )
 
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
