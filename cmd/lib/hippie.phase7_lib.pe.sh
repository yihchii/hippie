
function consecutiveReads {
    echo -e "\033[1mSubmitting consecutiveReads \033[0m"
    $QSUB -hold_jid *Mapped*${LINE} -N consecutiveReads${LINE} $QSUBARGS -l h_vmem=2G "$CMD_DIR/consecutiveReads.sh" "s_${LINE}.bed" "${LINE}" 
#    $QSUB -hold_jid rmBadMapped${LINE} -N consecutiveReads${LINE} $QSUBARGS -l h_vmem=2G "$CMD_DIR/consecutiveReads.sh" "s_${LINE}.bed" "${LINE}" $READLENGTH
}

function getClusters {
    echo -e "\033[1mSubmitting getClusters \033[0m"
    $QSUB -hold_jid consecutiveReads${LINE} -N getClusters${LINE} $QSUBARGS -l h_vmem=6G "$CMD_DIR/getClusters.sh" "${LINE}" 
}

function getHotspots {
    echo -e "\033[1mSubmitting getClusters \033[0m"
    $QSUB -hold_jid getClusters${LINE} -N getHotspots${LINE} $QSUBARGS -l h_vmem=6G "$CMD_DIR/getHotspots.sh" "${LINE}" 
}

function extendHotspots {
    echo -e "\033[1mSubmitting extendHotspots \033[0m"
    $QSUB -hold_jid getHotspots${LINE} -N extendHotspots${LINE} $QSUBARGS -l h_vmem=4G "$CMD_DIR/extendHotspots.sh" "${LINE}" "${REMEDIAN}"
}

function annotateHotspots {
    echo -e "\033[1mSubmitting annotateHotspots \033[0m"
    $QSUB -hold_jid extendHotspots${LINE} -N annotateHotspots${LINE} $QSUBARGS -l h_vmem=6G "$CMD_DIR/annotateHotspots.sh" "${LINE}" 
}

