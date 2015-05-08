#!/bin/bash
#

source "./setup.ini"

export REF_FASTA=$1
export fastq_file=$2
export OUT=$3
mkdir -p ${OUT}/sam
export SAM_DIR=${OUT}/sam
export sam_file_prefix="${SAM_DIR}/$(basename ${fastq_file%%.*})"

$STAR \
 --runThreadN 1 \
 --genomeDir "${REF_FASTA}/" \
 --readFilesCommand zcat \
 --readFilesIn "${fastq_file}" \
 --outSAMattributes All \
 --outSAMunmapped Within \
 --outSAMtype BAM Unsorted \
 --outReadsUnmapped Fastx \
 --outFileNamePrefix "${sam_file_prefix}" \
 --outFilterMultimapNmax 1   \
 --outFilterMismatchNoverLmax 0.04 \
 --scoreGapNoncan 0  --scoreGapGCAG 0  --scoreGapATAC 0 \
 --alignIntronMax 1 \
 --chimSegmentMin 20 \
 --chimScoreJunctionNonGTAG 0 \
 --genomeLoad LoadAndKeep 

# limitBAMsortRAM 53687091200 \
# limitBAMsortRAM=0 (default) cannot be used with --genomeLoad=LoadAndKeep, or any other shared memory options
# specify --limitBAMsortRAM the amount of RAM (bytes) that can be allocated for BAM sorting in addition to shared memory allocated for the genome.
#        --limitBAMsortRAM typically has to be > 10000000000 (i.e 10GB).
# segmentmin=20 actually means 22M79S and 22S79M in STAR (as they might keep 2 nt for splicesite)
# --runThreadN $STAR_THREADS \

