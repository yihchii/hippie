#!/bin/bash
#
source $HIPPIE_INI
source $HIPPIE_CFG


export fastq_file=$1
export SAM_DIR=$2
export fastq_file_base=`basename $fastq_file .fastq.gz`
export sam_file_prefix="${SAM_DIR}/${fastq_file_base}"
export ChimSegMin=$3
# export fastq_file_prefix=${fastq_file%%.*}
# export STAR_THREADS=2  # thread has to be 1 to keep the read order

$STAR \
 --runThreadN 1 \
 --genomeDir "${REF_FASTA}" \
 --readFilesCommand zcat \
 --readFilesIn "${fastq_file}" \
 --outSAMattributes All \
 --outSAMunmapped Within \
 --outSAMtype BAM Unsorted\
 --outReadsUnmapped Fastx \
 --outFileNamePrefix "${sam_file_prefix}" \
 --outFilterMultimapNmax 1   \
 --outFilterMismatchNoverLmax 0.04 \
 --scoreGapNoncan 0  --scoreGapGCAG 0  --scoreGapATAC 0 \
 --alignIntronMax 1 \
 --chimSegmentMin ${ChimSegMin} \
 --chimScoreJunctionNonGTAG 0 \
 --genomeLoad LoadAndKeep 
# segmentmin=10 for drosophila data means 12M24S and 24M12S
# segmentmin=20 actually means 22M79S and 22S79M in STAR (as they might keep 2 nt for splicesite)
# --runThreadN $STAR_THREADS \


# error checking
PROCESSED=$(tail -n 2 $SGE_STDOUT_PATH|grep -i "error"|tail -n 1)

shopt -s nocasematch
echo "checking stdout file: " $SGE_STDOUT_PATH
if [[ $PROCESSED =~ "Error" ]];
        then
                echo $PROCESSED
                exit 100
fi


