

function ETdistance {
    echo -e "\033[1mSubmitting ETdistance \033[0m"
    $QSUB -hold_jid getCeeTarget${LINE} -N ETdistance${LINE} $QSUBARGS -l h_vmem=2G "$CMD_DIR/ETdistance.sh" "${LINE}" "${THRE}"
}

function getTargetList {
    echo -e "\033[1mSubmitting getTargetList \033[0m"
    $QSUB -hold_jid getCeeTarget${LINE} -N getTargetList${LINE} $QSUBARGS -l h_vmem=1G "$CMD_DIR/getTargetList.sh" "${LINE}" "${THRE}"
}

function histoneEnrichment {
    echo -e "\033[1mSubmitting histoneEnrichment \033[0m"
    $QSUB -hold_jid getCeeTarget${LINE} -N histoneEnrichment${LINE} $QSUBARGS -l h_vmem=2G "$CMD_DIR/histoneEnrichment.sh" "${LINE}" "${CELL}" "${THRE}"
}


function plotHisEnrichment {
    echo -e "\033[1mSubmitting plotHisEnrichment \033[0m"
    $QSUB -hold_jid histoneEnrichment${LINE} -N plotHisEnrichment${LINE} $QSUBARGS -l h_vmem=1G "$CMD_DIR/plotHisEnrichment.sh" "${LINE}"
}
function GWASEnrichment {
    echo -e "\033[1mSubmitting GWASEnrichment \033[0m"
    $QSUB -hold_jid plotHisEnrichment${LINE} -N GWASEnrichment${LINE} $QSUBARGS -l h_vmem=1G "$CMD_DIR/GWASEnrichment.sh" "${LINE}" "${THRE}"
}

