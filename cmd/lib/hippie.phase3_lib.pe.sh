
function getDistanceToRS {
	echo -e "\033[1mSubmitting getDistanceToRS \033[0m"
	tilesSRR=($(ls $FASTQ_DIR/*.fastq.gz| tr '\n' '\0' | xargs -0 -n 1 basename|grep "_R1_"|cut -d. -f 1) $(ls $FASTQ_DIR/*.fastq.gz| tr '\n' '\0' | xargs -0 -n 1 basename|grep "_1.fastq.gz"|cut -d. -f 1 ))
	for task in "${tilesSRR[@]}"; do
		$QSUB -hold_jid "${LINE}_${task}_rmdupBed" -N "${LINE}_${task}_getDistanceToRS" $QSUBARGS -l h_vmem=1G "$CMD_DIR/getDistanceToRS.sh" "${BED_DIR}" "${task}" "${SIZE_SELECT}" "${RESIZE}" "${RE}"
	done
}


function collapseData {
	echo -e "\033[1mSubmitting collapseData \033[0m"
	$QSUB -hold_jid "${LINE}_loadGenome","${LINE}_*_getDistanceToRS" -N "${LINE}_collapseData" $QSUBARGS -l h_vmem=1G "$CMD_DIR/collapseData.sh" "${BED_DIR}" "${LINE}"
}

function consecutiveReadsS {
    echo -e "\033[1mSubmitting consecutiveReadsS \033[0m"
    $QSUB -hold_jid "${LINE}_collapseData" -N consecutiveReadsS${LINE} $QSUBARGS -l h_vmem=2G "$CMD_DIR/consecutiveReadsS.sh" "${BED_DIR}" "${LINE}_specific.bed" "${LINE}" 
}

function consecutiveReadsNS {
    echo -e "\033[1mSubmitting consecutiveReads \033[0m"
    $QSUB -hold_jid "${LINE}_collapseData" -N consecutiveReadsNS${LINE} $QSUBARGS -l h_vmem=2G "$CMD_DIR/consecutiveReadsNS.sh" "${BED_DIR}" "${LINE}_nonspecific.bed" "${LINE}" 
		
}

function getFragmentsRead {
    echo -e "\033[1mSubmitting getFragmentsRead \033[0m"
    $QSUB -hold_jid consecutiveReads*${LINE} -N getFragmentsRead${LINE} $QSUBARGS -l h_vmem=1G "$CMD_DIR/getFragmentsRead.sh" "${BED_DIR}" "${LINE}"  "${RE}"
}

function getPeakFragment {
    echo -e "\033[1mSubmitting getPeakFragment \033[0m"
    $QSUB -hold_jid getFragmentsRead${LINE} -N getPeakFragment${LINE} $QSUBARGS -l h_vmem=6G "$CMD_DIR/getPeakFragment.sh" "${BED_DIR}" "${LINE}" "${RE}" "${THRE}" "${SIZE_SELECT}"
}


function annotateFragment {
    echo -e "\033[1mSubmitting annotateFragment \033[0m"
    $QSUB -hold_jid getPeakFragment${LINE} -N annotateFragment${LINE} $QSUBARGS -l h_vmem=6G "$CMD_DIR/annotateFragment.sh" "${BED_DIR}" "${LINE}" "${RE}" "${THRE}"
}
