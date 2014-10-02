
function findHSInteraction {
    echo -e "\033[1mSubmitting findHSInteraction \033[0m"
    $QSUB -hold_jid annotateHotspots${LINE} -N findHSInteraction${LINE} $QSUBARGS -l h_vmem=7.5G "$CMD_DIR/findHSInteraction.sh" "${LINE}_eHotspots.bed" "${LINE}" 
}

function findHSPromoterInteraction {
    echo -e "\033[1mSubmitting findHSPromoterInteraction \033[0m"
    $QSUB -hold_jid annotateHotspots${LINE} -N findHSPromoterInteraction${LINE} $QSUBARGS -l h_vmem=7.5G "$CMD_DIR/findHSPromoterInteraction.sh" "${LINE}_eHotspots_annotated.bed" "${LINE}"
}

function findHSInteractionReads {
    echo -e "\033[1mSubmitting findHSInteractionReads \033[0m"
    $QSUB -hold_jid findHSInteraction${LINE} -N findHSInteractionReads${LINE} $QSUBARGS -l h_vmem=4G "$CMD_DIR/findHSInteractionReads.sh" "${LINE}"
}

function getHSCeeTarget {
    echo -e "\033[1mSubmitting getHSCeeTarget \033[0m"
    $QSUB -hold_jid findHSPromoterInteraction${LINE} -N getHSCeeTarget${LINE} $QSUBARGS -l h_vmem=4G "$CMD_DIR/getHSCeeTarget.sh" "${LINE}" "${CELL}"
}

