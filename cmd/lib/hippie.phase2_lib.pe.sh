function sortSamOneFastq {
    echo -e "\033[1mSubmitting sortSamOneFastq \033[0m"
    $QSUB -hold_jid Samp${RGID} -N sortSamOneFastq${RGID} $QSUBARGS -v SAM_DIR -l h_vmem=3G "$CMD_DIR/sortSamOneFastq.sh" ${LINE}
    doFlagStat sortSamOneFastq ""
}

function rmNotMapped {
    echo -e "\033[1mSubmitting rmNotMapped \033[0m"
    $QSUB -N rmNotMapped${1} $QSUBARGS -l h_vmem=4G "$CMD_DIR/rmNotMapped.sh" $1 $2
}

function rmdupBed {
  echo -e "\033[1mSubmitting rmdupBed \033[0m"
	$QSUB -hold_jid bam2Bed${LINE} -N rmdupBed${LINE} $QSUBARGS -l h_vmem=8G "$CMD_DIR/rmdupBed.sh" "s_${LINE}_merged"
}

function rmBadMapped {
    echo -e "\033[1mSubmitting rmBadMapped \033[0m"
    $QSUB -hold_jid rmdupBed${LINE} -N rmBadMapped${LINE} $QSUBARGS -l h_vmem=2G "$CMD_DIR/rmBadMapped.sh" "${LINE}" "s_${LINE}_merged_rmdup" "${mmq}"
}

function markdup {
  echo -e "\033[1mSubmitting markdup \033[0m"
	$QSUB -hold_jid mgBam${LINE} -N markdup${LINE} $QSUBARGS -l h_vmem=5.1G "$CMD_DIR/markdup.sh" "s_${LINE}_merged"
}


function rmdup {
  echo -e "\033[1mSubmitting rmdup \033[0m"
  $QSUB -hold_jid mgBam${LINE} -N rmdup${LINE} $QSUBARGS -l h_vmem=5.1G "$CMD_DIR/rmdup.sh" $1
}



function doFlagStat {
    echo -ne "\033[1mSubmitting doFlagStat for " 
    echo -n "$1"
    echo -e " suffix \033[0m"

    $QSUB -hold_jid mgBam$LINE -N doFlagStat$LINE \
          $QSUBARGS -v STAT_DIR -l h_vmem=500M \
          "$CMD_DIR/doFlagStat.sh" $1
}

function sortBamByName {
    echo -ne "\033[1mSubmitting sortBamByName for " 
    echo -n "$1"
    echo -e " suffix \033[0m"

    $QSUB -hold_jid mgBam$LINE -N sortBamByName$LINE \
          $QSUBARGS -v STAT_DIR -l h_vmem=5.1G \
          "$CMD_DIR/sortBamByName.sh" $1
}

function sortBamQueryName {
    echo -ne "\033[1mSubmitting sortBamQueryName for " 
    echo -n "$1"
    echo -e " suffix \033[0m"

    $QSUB -hold_jid mgBam$LINE -N sortBamQueryName$LINE \
          $QSUBARGS -v STAT_DIR -l h_vmem=5G \
          "$CMD_DIR/sortBamQueryName.sh" $1
}

function bam2Bed {
  	echo -e "\033[1mSubmitting bam2Bed \033[0m"

    $QSUB -hold_jid mgBam${LINE} -N bam2Bed$LINE \
          $QSUBARGS -l h_vmem=3G \
          "$CMD_DIR/bam2Bed.sh" "s_${LINE}_merged"
}

