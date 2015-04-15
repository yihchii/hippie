function pairingBam {
	echo -e "\033[1mSubmitting pairingBam \033[0m"
	tilesSRR=($(ls $FASTQ_DIR/*.fastq.gz| tr '\n' '\0' | xargs -0 -n 1 basename|grep "_R1_"|cut -d. -f 1) $(ls $FASTQ_DIR/*.fastq.gz| tr '\n' '\0' | xargs -0 -n 1 basename|grep "_1.fastq.gz"|cut -d. -f 1 ))
	for task in "${tilesSRR[@]}"; do
		echo $task;
		bam_file=${task}"Aligned.out.bam";
		chim_file=${task}"Chimeric.out.sam"
		sec_bam_file=$(echo $bam_file|sed 's/_1/_2/');
		sec_bam_file=$(echo $sec_bam_file|sed 's/_R1_/_R2_/');

		sec_chim_file=$(echo $chim_file|sed 's/_1/_2/');
		sec_chim_file=$(echo $sec_chim_file|sed 's/_R1_/_R2_/');
		JOBNAME="${LINE}_${task}_pairing" ;
		sec_task=$(echo $task|sed 's/_1/_2/');
		$QSUB -N ${JOBNAME} $QSUBARGS -pe DJ 1 -hold_jid "${LINE}_${sec_task}_mapping","${LINE}_${task}_mapping" -l h_vmem=5G ${CMD_DIR}/pairingBam.sh ${SAM_DIR}/${bam_file} ${SAM_DIR}/${sec_bam_file} ${SAM_DIR}/${chim_file} ${SAM_DIR}/${sec_chim_file} ${ChimSegMin} ${SIZE_SELECT} ${RE} ${BED_DIR}/${task}.bed;
  done
}

function rmdupBed {
  echo -e "\033[1mSubmitting rmdupBed \033[0m"
	tilesSRR=($(ls $FASTQ_DIR/*.fastq.gz| tr '\n' '\0' | xargs -0 -n 1 basename|grep "_R1_"|cut -d. -f 1) $(ls $FASTQ_DIR/*.fastq.gz| tr '\n' '\0' | xargs -0 -n 1 basename|grep "_1.fastq.gz"|cut -d. -f 1 ))
	for task in "${tilesSRR[@]}"; do
		$QSUB -hold_jid "${LINE}_${task}_pairing" -N "${LINE}_${task}_rmdupBed" $QSUBARGS -l h_vmem=4G "$CMD_DIR/rmdupBed.sh" "${BED_DIR}" "${task}"
	done
}


