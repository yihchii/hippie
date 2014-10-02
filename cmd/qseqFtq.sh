#!/bin/bash
#source $HIPPIE_CFG

if [ -s "$QSEQ_DIR/s_${2}_1_${1}_qseq.txt.gz" ]
then
	zcat $QSEQ_DIR/s_${2}_1_${1}_qseq.txt.gz | perl $CMD_DIR/qseq2fastq.pl > $FASTQ_DIR/s_${2}_1_${1}.fastq
	zcat $QSEQ_DIR/s_${2}_2_${1}_qseq.txt.gz | perl $CMD_DIR/qseq2fastq.pl > $FASTQ_DIR/s_${2}_2_${1}.fastq
# 	$CMD_DIR/qseq_gz2fastq.pl $QSEQ_DIR/s_${2}_1_${1}_qseq.txt.gz > $FASTQ_DIR/s_${2}_1_${1}.fastq
# 	$CMD_DIR/qseq_gz2fastq.pl $QSEQ_DIR/s_${2}_2_${1}_qseq.txt.gz > $FASTQ_DIR/s_${2}_2_${1}.fastq
else
	perl $CMD_DIR/qseq2fastq.pl $QSEQ_DIR/s_${2}_1_${1}_qseq.txt > $FASTQ_DIR/s_${2}_1_${1}.fastq
	perl $CMD_DIR/qseq2fastq.pl $QSEQ_DIR/s_${2}_2_${1}_qseq.txt > $FASTQ_DIR/s_${2}_2_${1}.fastq
fi

#force error when missing/empty fastq . Would prevent continutation of pipeline
if [ ! -s "$FASTQ_DIR/s_${2}_2_${1}.fastq" ]
then
 echo "Missing FASTQ: $FASTQ_DIR/s_${2}_2_${1}.fastq file!"
 exit 100
fi
