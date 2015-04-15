
function loadGenome {
  echo -e "\033[1mSubmitting loadGenome \033[0m"

	export JOBNAME="${LINE}_loadGenome";
	NODES=($(qconf -sel))
	for node in "${NODES[@]}"; do
		echo $node
		$QSUB -N ${JOBNAME}	$QSUBARGS -l h_vmem=${refGenomeMem} -l h=$node "${CMD_DIR}/loadGenome.sh" ${FASTQ_DIR} ${SAMPLE_DIR} $node
	done
}

function starMapping {
	echo -e "\033[1mSubmitting starMapping \033[0m"
	# extract all fastq.gz files (in format of *_1.fastq.gz or casava output format NA10831_ATCACG_L002_R1_001.fastq.gz)
	tilesSRR=($(ls $FASTQ_DIR/*.fastq.gz| tr '\n' '\0' | xargs -0 -n 1 basename|grep "_R1_") $(ls $FASTQ_DIR/*.fastq.gz| tr '\n' '\0' | xargs -0 -n 1 basename|grep "_1.fastq.gz" ))
	for task in "${tilesSRR[@]}"; do
 		export fastq_file=${task};
		export fastq_file_prefix=${fastq_file%%.*};
		export JOBNAME="${LINE}_${fastq_file_prefix}_mapping" ;
		$QSUB -hold_jid "${LINE}_loadGenome" -N ${JOBNAME} $QSUBARGS -pe DJ 1 -l h_vmem=${refGenomeMem} ${CMD_DIR}/starMappingToBam.sh ${FASTQ_DIR}/${fastq_file} ${SAM_DIR} ${ChimSegMin};
		sec_fastq_file=$(echo $fastq_file|sed 's/_1/_2/');
		sec_fastq_file=$(echo $sec_fastq_file|sed 's/_R1_/_R2_/');
		export sec_fastq_file_prefix=${sec_fastq_file%%.*};
		export sec_JOBNAME="${sec_fastq_file_prefix}_mapping" ;
		$QSUB -hold_jid "${LINE}_loadGenome" -N ${LINE}_${sec_JOBNAME} $QSUBARGS -pe DJ 1 -l h_vmem=${refGenomeMem} ${CMD_DIR}/starMappingToBam.sh ${FASTQ_DIR}/${sec_fastq_file} ${SAM_DIR} ${ChimSegMin};
	done
}

function rmGenome {
  echo -e "\033[1mSubmitting rmGenome \033[0m"
	export JOBNAME="${LINE}_rmGenome";
	NODES=($(qconf -sel))
	for node in "${NODES[@]}"; do
		echo $node
		$QSUB -hold_jid "*_mapping" -N ${JOBNAME}	$QSUBARGS -l h_vmem=${refGenomeMem} -l h=$node "${CMD_DIR}/rmGenome.sh" ${SAMPLE_DIR} $node
	done
}

