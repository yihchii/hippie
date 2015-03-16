#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

mkdir -p $SAI_DIR


if [ -s "$FASTQ_DIR/s_${2}_${1}.txt.gz" ]
then
	bwa aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/s_${2}_${1}.sai $FASTQ_DIR/s_${2}_${1}.txt.gz 
else
	bwa aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/s_${2}_${1}.sai $FASTQ_DIR/s_${2}_${1}.txt 
fi 
# For reference see http://bio-bwa.sourceforge.net/bwa.shtml
#force error when missing/empty sai . Would prevent continutation of pipeline
if [ ! -s "$SAI_DIR/s_${2}_${1}.sai" ]
then
 echo "Missing SAI:$SAI_DIR/s_${2}_${1}.sai file!"
 exit 100
fi
