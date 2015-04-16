

function ETdistance {
    echo -e "\033[1mSubmitting ETdistance \033[0m"
    $QSUB -hold_jid ${LINE}_getCeeTarget -N ${LINE}_ETdistance $QSUBARGS -l h_vmem=2G "$CMD_DIR/ETdistance.sh" "${LINE}" "${THRE}" "${OUT_DIR}"
}

function getTargetList {
    echo -e "\033[1mSubmitting getTargetList \033[0m"
    $QSUB -hold_jid ${LINE}_getCeeTarget -N ${LINE}_getTargetList $QSUBARGS -l h_vmem=1G "$CMD_DIR/getTargetList.sh" "${LINE}" "${THRE}" "${OUT_DIR}"
}

function histoneEnrichment {
    echo -e "\033[1mSubmitting histoneEnrichment \033[0m"
    $QSUB -hold_jid ${LINE}_getCeeTarget -N ${LINE}_histoneEnrichment $QSUBARGS -l h_vmem=2G "$CMD_DIR/histoneEnrichment.sh" "${LINE}" "${CELL}" "${THRE}" "${BED_DIR}" "${OUT_DIR}"
}


function plotHisEnrichment {
    echo -e "\033[1mSubmitting plotHisEnrichment \033[0m"
    $QSUB -hold_jid ${LINE}_histoneEnrichment -N ${LINE}_plotHisEnrichment $QSUBARGS -l h_vmem=1G "$CMD_DIR/plotHisEnrichment.sh" "${LINE}" "${OUT_DIR}"
}
function GWASEnrichment {
    echo -e "\033[1mSubmitting GWASEnrichment \033[0m"
    $QSUB -hold_jid ${LINE}_plotHisEnrichment -N ${LINE}_GWASEnrichment $QSUBARGS -l h_vmem=1G "$CMD_DIR/GWASEnrichment.sh" "${LINE}" "${THRE}" "${OUT_DIR}"
}

