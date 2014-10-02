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


function excludeUnAligned {
  echo -e "\033[1mSubmitting excludeUnAligned \033[0m"
  $QSUB -hold_jid rmdup${LINE} -N excludeUnAligned${LINE} $QSUBARGS -l h_vmem=4G "$CMD_DIR/excludeUnAligned.sh" $1
}


function localRealignIndel {
   echo -e "\033[1mSubmitting localRealignIndel \033[0m"
   export GATK_THREADS=4

   local JOB_MEM1=$(adjustWorkingMem 256M $GATK_THREADS)
   local JOB_MEM2=$(adjustWorkingMem 10G $GATK_THREADS)

   $QSUB -hold_jid markdup$LINE -N realignIndelS1_$LINE \
         $QSUBARGS -v GATK_THREADS -pe $PE 4 \
         -l h_stack=$JOB_MEM1,h_vmem=$JOB_MEM2 \
         "$CMD_DIR/realign_known_indels_step1.sh" "s_${LINE}_merged_markdup"

   $QSUB -hold_jid realignIndelS1_$LINE -N realignIndelS2_$LINE \
          $QSUBARGS -l h_vmem=8G "$CMD_DIR/realign_known_indels_step2.sh" \
   	  "s_${LINE}_merged_markdup"

}

function dedupBamOneFastq {
    echo -e "\033[1mSubmitting dedupBamOneFastq \033[0m"
    $QSUB -hold_jid sortSamOneFastq${RGID} -N dedupNIndexBam${RGID} $QSUBARGS -l h_vmem=4G "$CMD_DIR/dedupBamOneFastq.sh" ${LINE}
    doFlagStat dedupNIndexBam _nodup
    doFlagStat dedupNIndexBam _nodup_uniq
}

function dedupNIndexBam {
    echo -e "\033[1mSubmitting dedupNIndexBam \033[0m"

    local holdJID=${1}$LINE

    $QSUB -hold_jid $holdJID -N dedupNIndexBam${LINE} $QSUBARGS -l h_vmem=8G "$CMD_DIR/dedupNIndexBam.sh" ${LINE}
    doFlagStat dedupNIndexBam _nodup
    doFlagStat dedupNIndexBam _nodup_uniq
}

## this is likely to be run manually; therefore no hold_jid
function uniqNIndexBam {
    echo -e "\033[1mSubmitting uniqNIndexBam \033[0m"
    $QSUB -N uniqNIndexBam${LINE} $QSUBARGS -l h_vmem=8G "$CMD_DIR/uniqNIndexBam.sh" ${LINE}
    doFlagStat uniqNIndexBam _uniq
    doFlagStat uniqNIndexBam _nodup_uniq
}

function index {
	if [ -z "$1" ]
		then
			prefix=$LINE
		else
			prefix="${LINE}${1}"
	fi
	checkOutputExist s_${prefix}.bam.bai
	$QSUB -hold_jid dedup$LINE -N idx${RGID}${1} $QSUBARGS "$CMD_DIR/index.sh" $prefix
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


function countRead {
    echo -ne "\033[1mSubmitting countRead for " 
    echo -n "$1 $2"
    echo -e " \033[0m"

# if $2 ($Target) does not exist -> whole genome
	if [ -z "$2" ]
		then
			suffix="${LINE}G"
		else
			suffix="${LINE}T"
	fi

    $QSUB -hold_jid markdup$LINE -N countRead$suffix \
          $QSUBARGS -v STAT_DIR -l h_vmem=5G \
          "$CMD_DIR/countRead.sh" $1 $2
}


function recal4realn {
    echo -e "\033[1mSubmitting recal for realn \033[0m"
#	checkOutputExist s_${LINE}${1}_recal.bam.bai
    export GATK_THREADS=4
    local JOB_MEM=$(adjustWorkingMem 7G $GATK_THREADS)

    if [ ! -s "../csv/s_${LINE}${1}.recal_data.csv" ]
      then
	    $QSUB -hold_jid realn${RGID}${1} -N recal_covar${RGID} \
	          $QSUBARGS \
	          -pe $PE $GATK_THREADS \
	          -v GATK_THREADS -l h_vmem=$JOB_MEM \
	          "$CMD_DIR/recal_countCovariates.sh" ${LINE} _nodup_uniq_realn
    fi

    $QSUB -hold_jid recal_covar${RGID} -N recalTableByChr${RGID} \
           $QSUBARGS \
           -l h_vmem=4G -t 1-24 \
	   "$CMD_DIR/recal_tableRecalibrationByChr.sh" ${LINE} _nodup_uniq_realn
}

function recal {
    echo -e "\033[1mSubmitting recal \033[0m"
#	checkOutputExist s_${LINE}${1}_recal.bam.bai
    export GATK_THREADS=4
    local HOLD_JOB=$3
    if [ -z $HOLD_JOB ];then HOLD_JOB="realignIndelS2_$LINE";fi
    if [ -z $1 ];then echo "Missing BAM prefix";exit 1;fi
    if [ -z $2 ];then echo "Missing BAM prefix";exit 1;fi

    local JOB_MEM=$(adjustWorkingMem 7G $GATK_THREADS)


    if [ ! -s "../csv/${1}.recal_data.csv" ]
      then
	    $QSUB -hold_jid $HOLD_JOB -N recal_covar${LINE} \
	          $QSUBARGS \
	          -pe $PE $GATK_THREADS \
	          -v GATK_THREADS -l h_vmem=$JOB_MEM \
	          "$CMD_DIR/recal_countCovariates.sh" $1
    fi

      $QSUB -hold_jid recal_covar${LINE} -N recalTableFULL${LINE} \
	      $QSUBARGS \
	      -l h_vmem=6G \
	      "$CMD_DIR/recal_tableRecalibration.sh" $1 $2

}


function picard_qc_metrics {
    echo -e "\033[1mSubmitting picard_qc_metrics Jobs \033[0m"
    mkdir -p $STAT_DIR
    HOLDJID="recalTableFULL${LINE}"
    INFILE="s_${LINE}_recal.FULL.bam"

    $QSUB -hold_jid $HOLDJID -N meanQbycycle${LINE} \
	      $QSUBARGS -l h_vmem=5G \
	      "$CMD_DIR/meanQbycycle.sh" "$INFILE" "qualityByCycle_${LINE}.pdf"

    $QSUB -hold_jid $HOLDJID -N meanQScDis${LINE} \
	      $QSUBARGS -l h_vmem=5G \
	      "$CMD_DIR/meanQScDis.sh" "$INFILE" "quality_filter_score_${LINE}.pdf"

    $QSUB -hold_jid $HOLDJID -N hsMetrics${LINE} \
	      $QSUBARGS -l h_vmem=5G \
	      "$CMD_DIR/hsMetrics.sh" "$INFILE" "Gc_bias_${LINE}.pdf"

    $QSUB -hold_jid $HOLDJID -N insertSize${LINE} \
	      $QSUBARGS -l h_vmem=5G \
	      "$CMD_DIR/collectInsertSizeMetrics.sh" "$INFILE" "hst_Insert_${LINE}.pdf"
}

function merge_chr_table {
    echo -e "\033[1mSubmitting merge_chr_table \033[0m"
    $QSUB -hold_jid recalTableByChr${LINE} -N "mergeChrTable${LINE}" \
          $QSUBARGS -l h_vmem=4G \
          "$CMD_DIR/mergeChrTable.sh" "${LINE}"
    doFlagStat mergeChrTable _merged_nodup_uniq_recal
}

function merge_chr_table_realn {
    echo -e "\033[1mSubmitting merge_chr_table_realn \033[0m"
    $QSUB -hold_jid recalTableByChr${LINE} -N "mergeChrTable_realn${LINE}" \
          $QSUBARGS -l h_vmem=4G \
          "$CMD_DIR/mergeChrTable_realn.sh" "${LINE}"
    doFlagStat mergeChrTable_realn _merged_nodup_uniq_realn_recal
}

function recalNmerge_chr_table {
  recal
  merge_chr_table
}

function recal_celegans {
    echo -e "\033[1mSubmitting recal_celegans \033[0m"
#	checkOutputExist s_${LINE}${1}_recal.bam.bai
    export GATK_THREADS=4
    if [ ! -s "../csv/s_${LINE}${1}.recal_data.csv" ]
      then
	    $QSUB -hold_jid dedupNIndexBam${LINE}${1} -N recal_covar${LINE} \
	          $QSUBARGS \
	          -pe $PE $GATK_THREADS \
	          -v GATK_THREADS -l h_vmem=6.5G \
	          "$CMD_DIR/recal_countCovariates_celegans.sh" ${LINE} _nodup_uniq 
    fi

	$QSUB -hold_jid recal_covar${LINE} -N recalTableByChr${LINE} \
	      $QSUBARGS \
	      -l h_vmem=5G -t 1-7 \
	      "$CMD_DIR/recal_tableRecalibrationByChr_celegans.sh" ${LINE} _nodup_uniq
}
