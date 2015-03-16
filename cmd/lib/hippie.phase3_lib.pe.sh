function getDistancetoRSLeft {
    echo -e "\033[1mSubmitting getDistancetoRSLeft \033[0m"
    $QSUB -hold_jid *Mapped*${LINE} -N getDistancetoRSLeft${LINE} $QSUBARGS -l h_vmem=2G "$CMD_DIR/getDistancetoRSLeft.sh" "${LINE}" "${RE}"
}

function getDistancetoRSRight {
    echo -e "\033[1mSubmitting getDistancetoRSLeft \033[0m"
    $QSUB -hold_jid *Mapped*${LINE} -N getDistancetoRSRight${LINE} $QSUBARGS -l h_vmem=2G "$CMD_DIR/getDistancetoRSRight.sh" "${LINE}" "${RE}"
}

function getDistancePairBed {
    echo -e "\033[1mSubmitting getDistancePairBed \033[0m"
    $QSUB -hold_jid getDistancetoRS*${LINE} -N getDistancePairBed${LINE} $QSUBARGS -l h_vmem=2G "$CMD_DIR/getDistancePairBed.sh" "${LINE}" 
}

function consecutiveReadsS {
    echo -e "\033[1mSubmitting consecutiveReadsS \033[0m"
    $QSUB -hold_jid getDistancePairBed${LINE} -N consecutiveReadsS${LINE} $QSUBARGS -l h_vmem=2G "$CMD_DIR/consecutiveReadsS.sh" "s_${LINE}_specific.bed" "${LINE}" 
}

function consecutiveReadsNS {
    echo -e "\033[1mSubmitting consecutiveReads \033[0m"
    $QSUB -hold_jid getDistancePairBed${LINE} -N consecutiveReadsNS${LINE} $QSUBARGS -l h_vmem=2G "$CMD_DIR/consecutiveReadsNS.sh" "s_${LINE}_nonspecific.bed" "${LINE}" 
#    $QSUB -hold_jid rmBadMapped${LINE} -N consecutiveReads${LINE} $QSUBARGS -l h_vmem=2G "$CMD_DIR/consecutiveReads.sh" "s_${LINE}.bed" "${LINE}" $READLENGTH
}

function getFragmentsRead {
    echo -e "\033[1mSubmitting getFragmentsRead \033[0m"
    $QSUB -hold_jid consecutiveReads*${LINE} -N getFragmentsRead${LINE} $QSUBARGS -l h_vmem=1G "$CMD_DIR/getFragmentsRead.sh" "${LINE}"  "${RE}"
}

function getPeakFragment {
    echo -e "\033[1mSubmitting getPeakFragment \033[0m"
    $QSUB -hold_jid getFragmentsRead${LINE} -N getPeakFragment${LINE} $QSUBARGS -l h_vmem=6G "$CMD_DIR/getPeakFragment.sh" "${LINE}" "${RE}" "${THRE}"
}

function annotateFragment {
    echo -e "\033[1mSubmitting annotateFragment \033[0m"
    $QSUB -hold_jid getPeakFragment${LINE} -N annotateFragment${LINE} $QSUBARGS -l h_vmem=6G "$CMD_DIR/annotateFragment.sh" "${LINE}" "${RE}" "${THRE}"
}
