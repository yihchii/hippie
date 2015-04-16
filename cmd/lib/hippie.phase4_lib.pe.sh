

function findPeakInteraction {
    echo -e "\033[1mSubmitting findPeakInteraction \033[0m"
    $QSUB -hold_jid ${LINE}_getPeakFragment -N ${LINE}_findPeakInteraction $QSUBARGS -l h_vmem=7.5G "$CMD_DIR/findPeakInteraction.sh" "${BED_DIR}" "${LINE}" "${RE}" "${THRE}"
}

function correctHiCBias {
    echo -e "\033[1mSubmitting correctHiCBias \033[0m"
    $QSUB -hold_jid ${LINE}_findPeakInteraction -N ${LINE}_correctHiCBias $QSUBARGS -l h_vmem=7.5G "$CMD_DIR/correctHiCBias.sh" "${BED_DIR}" "${LINE}" "${RE}" "${THRE}"
}

function  findPromoterInteraction {
    echo -e "\033[1mSubmitting  findPromoterInteraction \033[0m"
    $QSUB -hold_jid "${LINE}_annotateFragment","${LINE}_correctHiCBias" -N  ${LINE}_findPromoterInteraction $QSUBARGS -l h_vmem=7.5G "$CMD_DIR/findPromoterInteraction.sh" "${BED_DIR}" "${LINE}" "${RE}" "${THRE}"
}


function getCeeTarget {
    echo -e "\033[1mSubmitting getCeeTarget \033[0m"
    $QSUB -hold_jid ${LINE}_findPromoterInteraction -N ${LINE}_getCeeTarget $QSUBARGS -l h_vmem=7.5G "$CMD_DIR/getCeeTarget.sh" "${BED_DIR}" "${OUT_DIR}" "${LINE}" "${CELL}" "${THRE}"
}


