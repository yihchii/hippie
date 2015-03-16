#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

#bwa aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/s_${2}_1_${1}.sai $FASTQ_DIR/s_${2}_1_${1}.txt.gz 
#bwa aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/s_${2}_2_${1}.sai $FASTQ_DIR/s_${2}_2_${1}.txt.gz 
bwa aln -t $GATK_THREADS $REF_FASTA -f $SAI_DIR/${2}.sai $FASTQ_DIR/*.fastq 

# For reference see http://bio-bwa.sourceforge.net/bwa.shtml
#force error when missing/empty sai . Would prevent continutation of pipeline
if [ ! -s "$SAI_DIR/s_${2}_2_${1}.sai" ]
then
 echo "Missing SAI:$SAI_DIR/s_${2}_2_${1}.sai file!"
 exit 100
fi
