#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

export STAR_THREADS=2
export FASTQ_DIR=$1
export DATA_DIR=$2
export NODE=$3

# check if there is fastq files in the directory
flist=($(ls ${FASTQ_DIR}/*.fastq.gz 2>/dev/null));
if [ ${#flist[@]} -eq 0 ]; then
	echo "Error: No fastq.gz found in ${FASTQ_DIR}/. No mapping and no genome loading"
	echo "Please check your fastq file directory: ${FASTQ_DIR}/"
	exit 100
fi



${STAR} \
	--runThreadN ${STAR_THREADS} \
	--genomeDir "${REF_FASTA}" \
	--outFileNamePrefix "${DATA_DIR}/${NODE}_loadGenome"  \
	--genomeLoad LoadAndExit

rm "${DATA_DIR}/${NODE}_loadGenomeLog.progress.out"
rm "${DATA_DIR}/${NODE}_loadGenomeAligned.out.sam"
rm -rf "${DATA_DIR}/${NODE}_loadGenome_STARtmp"


# Error Checking

PROCESSED=$(tail -n 2 $SGE_STDOUT_PATH|grep -i "error"|tail -n 1)

echo "checking stdout file: " $SGE_STDOUT_PATH
if [[ $PROCESSED =~ "FATAL ERROR" ]];
	then 
		echo $PROCESSED
		exit 100
fi
