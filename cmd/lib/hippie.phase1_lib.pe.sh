
function checkst {
    while [ $NUMJOBS -gt 499 ];do
        sleep 10m
        echo "sleeping... Number of jobs: " `qstat | wc -l`
    done
}

function checkOutputExist {
    if [ -e $1 ]
    then
        echo "$1 exists. Exiting."
        exit
    fi
}

function qseqToFastq {
    echo -e "\033[1mSubmitting qseqToFastq \033[0m"
    for task in "${tiles[@]}"; do
        #NUM=$(printf "%04d" $task)
        $QSUB -N Ftq${RGID}_${task} $QSUBARGS -v QSEQ_DIR,FASTQ_DIR,CMD_DIR "$CMD_DIR/qseqFtq.sh" $task $LINE
    done
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

function bwaAlnGzFastq {
    echo -e "\033[1mSubmitting bwaAlnGzFastq\033[0m"
    export GATK_THREADS=3 # #cpus *3.5 / Total_memory
    for task in "${tiles[@]}"; do
        $QSUB -N Aln${RGID}_${task} \
              $QSUBARGS -v FASTQ_DIR,SAI_DIR,GATK_THREADS \
              -pe $PE $GATK_THREADS -l h_vmem=3.4G \
              "$CMD_DIR/bwaAlnGzFastq.sh" $task $LINE
    done
}

function bwaAlnTilesMssm {
    echo -e "\033[1mSubmitting bwaAlnTilesMssm\033[0m"
    #export GATK_THREADS=4 # #cpus *3.5 / Total_memory
    MYCOUNT=1
    cd $FASTQ_DIR
    for i in *_1_sequence.txt.gz; do
        $QSUB -N Aln${RGID}_$MYCOUNT \
              $QSUBARGS -v FASTQ_DIR,SAI_DIR,GATK_THREADS \
              -pe $PE $GATK_THREADS -l h_vmem=3.4G \
              "$CMD_DIR/bwaAlnTilesMssm.sh" $i
        MYCOUNT=$[ $MYCOUNT + 1 ]
    done
    cd -
}

function bwaAlnOneFastq {
    echo -e "\033[1mSubmitting bwaAlnOneFastq\033[0m"
    if [ $DATA_TYPE == "ONEFASTQ" ]
    then
        SH="bwaAlnOneFastq"
    else
        SH="bwaAlnOneFastqSE"
    fi
    export GATK_THREADS=2 # #cpus *3.5 / Total_memory
        $QSUB -N Aln${RGID} \
              $QSUBARGS -v FASTQ_DIR,SAI_DIR,GATK_THREADS \
              -pe $PE $GATK_THREADS -l h_vmem=3.4G \
              "$CMD_DIR/$SH.sh" "sequence" $LINE
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

function bwaSampOneFastq {
    echo -e "\033[1mSubmitting bwaSampOneFastq RG_STR\033[0m:=\e[00;31m $RG_STR \e[00m"
    if [ $DATA_TYPE == "ONEFASTQ" ]
    then
        SH="bwaSampOneFastq"
    else
        SH="bwaSamSeOneFastq"
    fi
        $QSUB -hold_jid Aln${RGID} -N Samp${RGID} \
              $QSUBARGS -v SAI_DIR,FASTQ_DIR,SAM_DIR -pe $PE 2 -l h_vmem=5G \
              "$CMD_DIR/$SH.sh" "sequence" $LINE "$RG_STR"
}

function bwaSampTilesMssm {
    echo -e "\033[1mSubmitting bwaSampTilesMssm\033[0m"
    MYCOUNT=1

    cd $FASTQ_DIR
    for i in *_1_sequence.txt.gz; do
        PREFIX=$(echo $i|sed 's/.txt.gz//')
        $QSUB -hold_jid Aln${RGID}_$MYCOUNT -N Samp${RGID}_$MYCOUNT \
              $QSUBARGS -v SAI_DIR,FASTQ_DIR,SAM_DIR -l h_vmem=5G \
              "$CMD_DIR/bwaSampTilesMssm.sh" "$RG_STR" $PREFIX
        MYCOUNT=$[ $MYCOUNT + 1 ]
    done
    cd -
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

# mergeBamFilter.sh = mergeBam.sh + samtools view -b -F 4
# function mergeBamFilter {
#     echo -e "\033[1mSubmitting mergeBamFilter \033[0m"
# 	$QSUB -N mergeBamFilter${LINE}$1  \
# 				$QSUBARGS -v SAM_DIR,BAM_DIR -l h_vmem=7G \
# 	      "$CMD_DIR/mergeBamFilter.sh" $LINE $1
# }

function mergeIndelRealnBam {
    echo -e "\033[1mSubmitting mergeIndelRealnBam \033[0m"
	$QSUB -N mergeIndelRealnBam${LINE}  \
				$QSUBARGS -v SAM_DIR,BAM_DIR -l h_vmem=7G \
	      "$CMD_DIR/mergeIndelRealnBam.sh" $LINE
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

function mgBamSoftLink {
  echo -e "\033[1mSubmitting mgBamSoftLink $1 \033[0m"
	$QSUB -hold_jid addRG${RGID} -N mgBam${LINE} $QSUBARGS "$CMD_DIR/mgBamSoftLink.sh" $1 $2
}

function checkCompleteMerge {
 local __is_too_small=0

 if [ -s "s_${LINE}_merged.bam" ] # -s file exists and has fsize > 0
 then
   FSIZE=$(du -b $BAM_DIR|cut -f1)
   REDUCTION=90/100
   MIN_SIZE=$[ $FSIZE * $REDUCTION ]
   MERGESIZE=$(stat -c%s "s_${LINE}_merged.bam")

   if [ $MERGESIZE -lt $MIN_SIZE ]
   then 
     __is_too_small=1
   fi

   echo $__is_too_small
 else
   echo 1;#returns true meaning , no data in file
 fi
}

function checkIncompleteFASTQ {
 local __is_incomplete=0

 for task in "${tiles[@]}"; do
     if [ ! -s "$FASTQ_DIR/s_${LINE}_2_${task}.fastq*" ] # -s file exists and has fsize > 0
     then
       __is_incomplete=1
     fi
 done
 if [ ! -s "$FASTQ_DIR/s_${LINE}_2_sequence.txt*" ] # -s file exists and has fsize > 0
 then
   __is_incomplete=1
 fi

 echo $__is_incomplete
}

function checkIncompleteSAI {
 local __is_incomplete=0

 for task in "${tiles[@]}"; do
     if [ ! -s "$SAI_DIR/s_${LINE}_2_${task}.sai" ] # -s file exists and has fsize > 0
     then
       __is_incomplete=1
     fi
 done

 for task in "${tilesR[@]}"; do
 		TWOFILE=$(echo $task|sed 's/_R1_/_R2_/')
     if [ ! -s "$SAI_DIR/${task}.sai" ] || [ ! -s "$SAI_DIR/${TWOFILE}.sai" ] # -s file exists and has fsize > 0
     then
       __is_incomplete=1
     fi
 done

 for task in "${tilesSRR[@]}"; do
 		TWOFILE=$(echo $task|sed 's/_1/_2/')
     if [ ! -s "$SAI_DIR/${task}.sai" ] || [ ! -s "$SAI_DIR/${TWOFILE}.sai" ] # -s file exists and has fsize > 0
     then
       __is_incomplete=1
     fi
 done


 echo $__is_incomplete
}

function checkIncompleteSAM {
 local __is_incomplete=0

 for task in "${tiles[@]}"; do
     if [ ! -s "$SAM_DIR/s_${LINE}_${task}.aligned.sam.gz" ] # -s file exists and has fsize > 0
     then
       __is_incomplete=1
     fi
 done

 for task in "${tilesR[@]}"; do
     if [ ! -s "$SAM_DIR/${task}.aligned.sam.gz" ] # -s file exists and has fsize > 0
     then
       __is_incomplete=1
     fi
 done

 for task in "${tilesSRR[@]}"; do
     if [ ! -s "$SAM_DIR/${task}.aligned.sam.gz" ] # -s file exists and has fsize > 0
     then
       __is_incomplete=1
     fi
 done

 echo $__is_incomplete
}
function checkIncompleteBAM {
 local __is_incomplete=0

 for task in "${tiles[@]}"; do
     if [ ! -s "$BAM_DIR/s_${LINE}_${task}_rg.bam" ] # -s file exists and has fsize > 0
     then
       __is_incomplete=1
     fi
 done

 for task in "${tilesR[@]}"; do
     if [ ! -s "$BAM_DIR/${task}_rg.bam" ] # -s file exists and has fsize > 0
     then
       __is_incomplete=1
     fi
 done

 for task in "${tilesSRR[@]}"; do
     if [ ! -s "$BAM_DIR/${task}_rg.bam" ] # -s file exists and has fsize > 0
     then
       __is_incomplete=1
     fi
 done
 echo $__is_incomplete
}

function checkSamp {
    echo -e "\033[1mSubmitting checkSamp\033[0m"
    for task in "${tiles[@]}"; do
        $QSUB -N checkSamp${RGID}_${task} \
              $QSUBARGS -v SAI_DIR,FASTQ_DIR,SAM_DIR -l h_vmem=1G \
              "$CMD_DIR/checkSamp.sh" $task $LINE
    done
}

###############
# adjustWorkingMem - calculate the per-thread memory for a parallel qsub job
# inputs: TARGET - The total memory required by the job
#         THREADS - Number of slots used by the job
function adjustWorkingMem {

local TARGET=$1
local THREADS=$2
local MEM_REQ=1M

# test empty result
if [ ! -z $(echo $TARGET|grep -o G) ]
 then
   # contains G (Gigabytes)
   MBTARGET=$(echo $TARGET|grep -Po "\d+")

   # Convert to MB
   MBTARGET=$[ $MBTARGET * 1024 ]
   #echo "New target:= $MBTARGET"

   MEM_REQ=$[ $MBTARGET / $THREADS ]

   if [ $MEM_REQ -eq 0 ];then
     MEM_REQ=1M
   else
     MEM_REQ=${MEM_REQ}M
   fi

   echo "$MEM_REQ"

elif [ ! -z $(echo $TARGET|grep -o M) ]
 then
   # contains M (Megabytes)
   MBTARGET=$(echo $TARGET|grep -Po "\d+")

   MEM_REQ=$[ $MBTARGET / $GATK_THREADS ]

   if [ $MEM_REQ -eq 0 ];then
     MEM_REQ=1M
   else
     MEM_REQ=${MEM_REQ}M
   fi

   echo "$MEM_REQ"

fi
}
#####
#
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
