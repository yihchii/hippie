#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

export STAR_THREADS=2
export DATA_DIR=$1
export NODE=$2

${STAR} \
	--runThreadN ${STAR_THREADS} \
	--genomeDir "${REF_FASTA}" \
	--outFileNamePrefix "${DATA_DIR}/${NODE}_rmGenome"  \
	--genomeLoad Remove

rm "${DATA_DIR}/${NODE}_rmGenomeLog.progress.out"
rm "${DATA_DIR}/${NODE}_rmGenomeAligned.out.sam"
rm -rf "${DATA_DIR}/${NODE}_rmGenome_STARtmp"


# Error Checking
echo -e "\nchecking stdout file: ${SGE_STDOUT_PATH}"

GENOME_NOT_EXISTS=$(grep "Did not find the genome in memory" $SGE_STDOUT_PATH)
if [[ $GENOME_NOT_EXISTS =~ "Did not find the genome in memory" ]];
	then 
		echo "HIPPIE Log: Genome directory to be removed: ${REF_FASTA}" 
		echo "HIPPIE Log: Genome s likely removed from shared memory by other jobs or has never been loaded to shared memory" 
		echo "STAR Log: ${GENOME_NOT_EXISTS}"
		exit 1
fi

PROCESSED=$(grep "FATAL ERROR" $SGE_STDOUT_PATH |tail -n 1)

if [[ $PROCESSED =~ "FATAL ERROR" ]];
	then 
		echo $PROCESSED
		exit 100
fi
