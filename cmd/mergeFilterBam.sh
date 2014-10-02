#!/bin/bash

#source $HIPPIE_INI
#source $HIPPIE_CFG

java -Xmx4g -jar /mnt/genomics/NGS/jar/GATK_dir-latest/GenomeAnalysisTK.jar \
   -T PrintReads \
   -R /mnt/genomics/REF/hg19/hg19.fasta \
   --filter_mismatching_base_and_quals \
   --read_filter UnmappedRead \
   -I ${1}.bam \
   -o no_unmapped.bam

#java -Xmx4g -jar $GATK \
#    --read_filter BadMate \
#    --read_filter MappingQualityZero \
