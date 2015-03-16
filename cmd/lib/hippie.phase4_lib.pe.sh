
function findPeakInteraction {
    echo -e "\033[1mSubmitting findPeakInteraction \033[0m"
    $QSUB -hold_jid getPeakFragment${LINE} -N findPeakInteraction${LINE} $QSUBARGS -l h_vmem=7.5G "$CMD_DIR/findPeakInteraction.sh" "${LINE}" "${RE}" "${THRE}"
}

function correctHiCBias {
    echo -e "\033[1mSubmitting correctHiCBias \033[0m"
    $QSUB -hold_jid findPeakInteraction${LINE} -N correctHiCBias${LINE} $QSUBARGS -l h_vmem=7.5G "$CMD_DIR/correctHiCBias.sh" "${LINE}" "${RE}" "${THRE}"
}

function  findPromoterInteraction {
    echo -e "\033[1mSubmitting  findPromoterInteraction \033[0m"
    $QSUB -hold_jid annotateFragment${LINE},correctHiCBias${LINE} -N  findPromoterInteraction${LINE} $QSUBARGS -l h_vmem=7.5G "$CMD_DIR/findPromoterInteraction.sh" "${LINE}" "${RE}" "${THRE}"
}

function findInteractionReads {
    echo -e "\033[1mSubmitting findInteractionReads \033[0m"
    $QSUB -hold_jid findInteraction${LINE} -N findInteractionReads${LINE} $QSUBARGS -l h_vmem=4G "$CMD_DIR/findInteractionReads.sh" "${LINE}"
}

function findInteractionReadsNS {
    echo -e "\033[1mSubmitting findInteractionReadsNS \033[0m"
    $QSUB -hold_jid findInteractionNS${LINE} -N findInteractionReadsNS${LINE} $QSUBARGS -l h_vmem=4G "$CMD_DIR/findInteractionReadsNS.sh" "${LINE}"
}

function getCeeTarget {
    echo -e "\033[1mSubmitting getCeeTarget \033[0m"
    $QSUB -hold_jid findPromoterInteraction${LINE} -N getCeeTarget${LINE} $QSUBARGS -l h_vmem=7.5G "$CMD_DIR/getCeeTarget.sh" "${LINE}" "${CELL}" "${THRE}"
}


