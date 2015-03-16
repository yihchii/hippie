
function checkOutputExist {
    if [ -e $1 ]
    then
        echo "$1 exists. Exiting."
        exit
    fi
}


function bwaAln {
    echo -e "\033[1mSubmitting bwaAln\033[0m"

    export GATK_THREADS=2
    #local JOB_MEM=$(adjustWorkingMem 4G $GATK_THREADS)

    for task in "${tiles[@]}"; do
        $QSUB -hold_jid Ftq${RGID}_${task} -N Aln${RGID}_${task} \
              $QSUBARGS -v FASTQ_DIR,SAI_DIR,GATK_THREADS \
              -pe $PE $GATK_THREADS -l h_vmem=5G \
              "$CMD_DIR/bwaAln.sh" $task $LINE
    done

    for task in "${tilesR[@]}"; do
        $QSUB -hold_jid Ftq${task} -N Aln${task} \
              $QSUBARGS -v FASTQ_DIR,SAI_DIR,GATK_THREADS \
              -pe $PE $GATK_THREADS -l h_vmem=5G \
              "$CMD_DIR/bwaAlnR.sh" $task $LINE

    done

    for task in "${tilesSRR[@]}"; do
        $QSUB -hold_jid Ftq${task} -N Aln${LINE}${task} \
              $QSUBARGS -v FASTQ_DIR,SAI_DIR,GATK_THREADS \
              -pe $PE $GATK_THREADS -l h_vmem=5G \
              "$CMD_DIR/bwaAlnSRR.sh" $task $LINE

    done
}

function bwaSamp {
    echo -e "\033[1mSubmitting bwaSamp RG_STR\033[0m:=\e[00;31m $RG_STR \e[00m"

    for task in "${tiles[@]}"; do
        $QSUB -hold_jid Aln${RGID}_${task} -N Samp${RGID}_${task} \
              $QSUBARGS -v SAI_DIR,FASTQ_DIR,SAM_DIR -l h_vmem=6G \
              "$CMD_DIR/bwaSamp.sh" $task $LINE "$RG_STR"
    done

    for task in "${tilesR[@]}"; do
        $QSUB -hold_jid Aln${task} -N Samp${task} \
              $QSUBARGS -v SAI_DIR,FASTQ_DIR,SAM_DIR -l h_vmem=6G \
              "$CMD_DIR/bwaSampR.sh" $task $LINE "$RG_STR"
    done

    for task in "${tilesSRR[@]}"; do
        $QSUB -hold_jid Aln${LINE}${task} -N Samp${LINE}${task} \
              $QSUBARGS -v SAI_DIR,FASTQ_DIR,SAM_DIR -l h_vmem=6G \
              "$CMD_DIR/bwaSampSRR.sh" $task $LINE "$RG_STR"
    done

}


function addReadGroupTasks {
    echo -e "\033[1mSubmitting addReadGroupTasks \033[0m"
    for task in "${tiles[@]}"; do
        $QSUB -hold_jid Samp${RGID}_${task} -N addrg${RGID}_${task} \
              $QSUBARGS -v SAM_DIR,BAM_DIR,RG_STR_PICARD -l h_vmem=7.5G \
              "$CMD_DIR/addReadGroupSmallSam.sh" $SAM_DIR/${task}.aligned.sam.gz $BAM_DIR/${task}
    done

    for task in "${tilesR[@]}"; do
        $QSUB -hold_jid Samp${task} -N addrg${task} \
              $QSUBARGS -v SAM_DIR,BAM_DIR,RG_STR_PICARD -l h_vmem=7.5G \
              "$CMD_DIR/addReadGroupSmallSam.sh" $SAM_DIR/${task}.aligned.sam.gz $BAM_DIR/${task}
    done

    for task in "${tilesSRR[@]}"; do
        $QSUB -hold_jid Samp${LINE}${task} -N addrg${LINE}${task} \
              $QSUBARGS -v SAM_DIR,BAM_DIR,RG_STR_PICARD -l h_vmem=7.5G \
              "$CMD_DIR/addReadGroupSmallSam.sh" $SAM_DIR/${task}.aligned.sam.gz $BAM_DIR/${task}
    done
}

function sam2bam {
    echo -e "\033[1mSubmitting sam2bam \033[0m"
    for task in "${tiles[@]}"; do
        $QSUB -hold_jid Samp${RGID}_${task} -N Bam${RGID}_${task} \
              $QSUBARGS -v SAM_DIR,BAM_DIR -l h_vmem=4G \
              "$CMD_DIR/sam2bam.sh" $task
    done

    for task in "${tilesR[@]}"; do
        NUM=$(echo $task| grep -Po 'R[12]_\d+')
        $QSUB -hold_jid Samp${RGID}_${NUM} -N Bam${RGID}_${NUM} \
              $QSUBARGS -v SAM_DIR,BAM_DIR -l h_vmem=4G \
              "$CMD_DIR/sam2bam.sh" $task
    done
}

function mergeBam {
    echo -e "\033[1mSubmitting mergeBam \033[0m"
	$QSUB -N mergeBam${LINE} \
	$QSUBARGS -v SAM_DIR,BAM_DIR -l h_vmem=7G \
	      "$CMD_DIR/mergeBam.sh"  $1
}

function samtoolsMergeBam {
    echo -e "\033[1mSubmitting samtoolsMergeBam \033[0m"
	#checkOutputExist s_${LINE}.bam
	$QSUB -N mgBam${LINE} -hold_jid "addrg*${LINE}*" \
	      $QSUBARGS -v SAM_DIR,BAM_DIR \
	      -l h_vmem=1G \
	      "$CMD_DIR/samtoolsMergeBam.sh" "s_$LINE"
}


function mergeSamToBam {
    echo -e "\033[1mSubmitting mergeSamToBam \033[0m"
	#checkOutputExist s_${LINE}.bam
	$QSUB -N mergeSamToBam${LINE} -hold_jid "Samp${LINE}*" \
	      $QSUBARGS -v SAM_DIR,BAM_DIR \
	      -l h_vmem=15G \
	      "$CMD_DIR/mergeSamToBam.sh" "s_$LINE"
}

function addReadGroup {
  echo -e "\033[1mSubmitting addReadGroup $1 \033[0m"
	$QSUB -hold_jid $3 -N addRG${RGID} $QSUBARGS -v RG_STR_PICARD -l h_vmem=50G "$CMD_DIR/addReadGroup.sh" $1 $2
}


#
####
function hippie_test_variables {

# execFiles[0]=BWA
# execFiles[1]=GATK
# execFiles[2]=SAMTOOLS

 local execFiles=(BWA GATK SAMTOOLS)
 local dataFiles=(REF_FASTA SNPDB SNPDB_INDELS_ONLY TARGET FLANK)
 local fileDirs=(GENOMICS_JAR GENOMICS_BIN CMD_HIPPIE STDOUT CMD_DIR BUNDLE_HAPMAP BUNDLE_OMNI BUNDLE_MILLS)

 local MISSING_SOMETING=0
 local DO_CONTINUE=1 # 1= all clear, 0=fatal error, 2=warning

 if [ ! -z "$1" ];then
  echo "Testing your variable"
 else

    # Testing directories exists
    for VAR in ${fileDirs[@]};do

        if [ -z $(eval echo $`echo $VAR`) ];then
          echo "Variable $VAR is not set" 
        fi

        if [ ! -d $(eval echo $`echo $VAR`) ];then
            echo "$""$VAR can not be found, missing" $(eval echo $`echo $VAR`)
            MISSING_SOMETING=1
            DO_CONTINUE=2
        fi
    done

    # Testing programs can be found
    for VAR in ${execFiles[@]};do

        if [ -z $(eval echo $`echo $VAR`) ];then
          echo "Variable $VAR is not set" 
        fi

        if [ ! -e $(eval echo $`echo $VAR`) ];then
            echo "$""$VAR program can not be found, missing" $(eval echo $`echo $VAR`)
            MISSING_SOMETING=1
            DO_CONTINUE=0
        fi
    done

    # Testing data files exists
    for VAR in ${dataFiles[@]};do

        if [ -z $(eval echo $`echo $VAR`) ];then
          echo "Variable $VAR is not set" 
        fi

        if [ ! -s $(eval echo $`echo $VAR`) ];then
            echo "$""$VAR data file can not be found, missing" $(eval echo $`echo $VAR`)
            MISSING_SOMETING=1
            DO_CONTINUE=0
        fi
    done

 fi

 if [ $MISSING_SOMETING -eq 1 ];then
    echo "Please correct your configuration files:" $HIPPIE_INI $HIPPIE_CFG
 fi

 eval "hippie_test_variables=$DO_CONTINUE"

}
