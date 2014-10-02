#!/bin/bash
source $HIPPIE_INI

samtools view -b -F 4 $1.bam -o $2.bam
samtools index $2.bam $2.bai

