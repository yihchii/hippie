#!/bin/bash

#
# Initialization
export HIPPIE_INI=
export HIPPIE_CFG=
source $HIPPIE_INI
source $HIPPIE_CFG

# get command line parameters
while getopts dr:l:p:t: option
do
        case "$option" in
            d) DODEBUG=true;;               # option -d to print out commands
            r) RUN_DIR="$OPTARG";;
            l) LINE="$OPTARG";;
            p)                              # -p 1/2/3 to execute a particular phase, e.g.: -p1 -p2 -p3
              case "$OPTARG" in
                1) DOPHASE1=true;;
                2) DOPHASE2=true;;
                3) DOPHASE3=true;;
                4) DOPHASE4=true;;
                5) DOPHASE5=true;;
                7) DOPHASE7=true;;
                8) DOPHASE8=true;;
              esac;;
            t) TEST_FUNCTION="$OPTARG";;    # execute function e.g.,   -t "stat _merged_nodup_uniq_recal"
        esac
done

#
# Globals
USER=$LOGNAME
export CMD_DIR=$CMD_HIPPIE
export REF_FASTA=$GENOME_REF

export QSEQ_DIR=
export FASTQ_DIR=
export SAI_DIR=
export SAM_DIR=
export BAM_DIR=
export STAT_DIR=stat
export VCF_DIR=vcf
#
# User Configuration

###DATA_TYPE=(TILESQSEQ | TILESFASTQ | TILESELAND | ONEFASTQ | ONEFASTQSE) Single-End
###TARGET_COVERAGE=(AGILENT | NIMBLEGEN)

DATA_TYPE=
TARGET_COVERAGE=
USESEG=0	# USESEG=0: Enhancers specified by covering H3K4me1 or K27ac and DNase, but not H3K27me3 or H3K4me3
					# USESEG=1: Enhancers specified by enhancers and weak enhancers from ENCODE Combined Segmentations tracks



#Template variables below
export RG_STR=
export RG_STR_PICARD=

export RGID=
export LINE=

export READLENGTH=
export REMEDIAN=
export CELL=
export RE=

export mbq=
export mmq=

if [ $DATA_TYPE == "TILESQSEQ" ]; then
 tiles=($(ls $QSEQ_DIR/*.txt*|sed -n 's/.*s_[0-9]\+_1_\([0-9]\+\).*/\1/p')) # this extracts 0001, 0002 .. XXXX from s_N_1_XXXX

elif [ $DATA_TYPE == "TILESFASTQ" ]; then
 tiles=($(ls $FASTQ_DIR/*.fastq*|sed -n 's/.*s_[0-9]\+_1_\([0-9]\+\).*/\1/p')) # this extracts 0001, 0002 .. XXXX from s_N_1_XXXX
 tilesR=($(ls $FASTQ_DIR/*.fastq*|grep -Po '[^/]+R1_[^\.]+')) # this extracts a different format
 tilesSRR=($(ls $FASTQ_DIR/*.fastq*|sed -n 's/.*\(SRR[0-9]\+_1\).*/\1/p')) # this extracts a different format
fi

#
# QSUB
QSUB="qsub"
[[ $DODEBUG ]] && QSUB="echo qsub"

NUMJOBS=`qstat -u $USER|grep -c $USER`
export QSUBARGS="-S /bin/bash -q $GRID_QUEUE -cwd -v HIPPIE_INI,HIPPIE_CFG,REF_FASTA,SNPDB -j y -o $STDOUT -hard -l h_stack=256m,h_vmem=1G"

#
# function libraries
source $CMD_DIR/lib/hippie.phase1_lib.pe.sh 
source $CMD_DIR/lib/hippie.phase2_lib.pe.sh 
source $CMD_DIR/lib/hippie.phase3_lib.pe.sh 
source $CMD_DIR/lib/hippie.phase4_lib.pe.sh 
source $CMD_DIR/lib/hippie.phase5_lib.pe.sh 
source $CMD_DIR/lib/hippie.phase7_lib.pe.sh 
source $CMD_DIR/lib/hippie.phase8_lib.pe.sh 


if [ ! -z "$TEST_FUNCTION" ] 
then
 eval $TEST_FUNCTION
 exit
fi

#############################################################
# PHASE 1 - Create BAM alignments                           #

if [[ $DOPHASE1 ]]; then
  echo "Phase 1"
  
  if [ $DATA_TYPE == "BAM" ]; then
		echo "Merging the following bam files"
		ls $BAM_DIR
		samtoolsMergeBam
  	
  elif [[ $DATA_TYPE == "ONEFASTQ" || $DATA_TYPE == "ONEFASTQSE" ]]; then
  	bwaAlnOneFastq
  	bwaSampOneFastq 
		addReadGroup $SAM_DIR/s_${LINE}_sequence.aligned.sam.gz $BAM_DIR/s_${LINE} Samp${RGID}
		mgBamSoftLink $BAM_DIR/s_${LINE}_rg.bam s_${LINE}_merged.bam 
		
  else
		if [ $DATA_TYPE == "TILESQSEQ" ]; then
			[ $(checkIncompleteFASTQ) == 1 ] && qseqToFastq
		fi
	
		[ $(checkIncompleteSAI) == 1 ]   && bwaAln      
		[ $(checkIncompleteSAM) == 1 ]   && bwaSamp      
	
		[ $(checkIncompleteBAM) == 1 ]   && addReadGroupTasks
		samtoolsMergeBam

		
	fi
		
fi

###################### EOF PHASE 1 #########################




############################################################
#                                                          #
# PHASE 2 - Quality Control                                #
if [ $DATA_TYPE != "ONEFASTQ" ] && [[ $DOPHASE2 ]]; then
  echo "Phase 2"

 doFlagStat "s_${LINE}_merged" 
# sortBamQueryName "s_${LINE}_merged"
 bam2Bed 
 rmdupBed 
 rmBadMapped
fi

###################### EOF PHASE 2 #########################

############################################################
#                                                          #
# PHASE 3 - find peak RE fragments                         #
if [[ $DOPHASE3 ]]; then
 echo "Phase 3 - Find Peak RE fragments"
 getDistancetoRSLeft # comment out so that it wouldn't re-run and ruin the data
 getDistancetoRSRight
 getDistancePairBed # comment out so that it wouldn't re-run and ruin the data
 consecutiveReadsS
 consecutiveReadsNS
 getFragmentsRead
 getPeakFragment		 # get peak fragment by the threshold set # default 95
 annotateFragment
fi

###################### EOF PHASE 3 #########################

############################################################
#                                                          #
# PHASE 4 - find RE fragment interaction and get CEE  		 #
if [[ $DOPHASE4 ]]; then
 echo "Phase 4 - Find Peak RE fragments interaction"
 findPeakInteraction  # find significant interaction between significant peaks
 correctHiCBias
 findPromoterInteraction # find promoter interaction for the peak fragment
 getCeeTarget
fi

###################### EOF PHASE 4 #########################


############################################################
#                                                          #
# PHASE 5 - enhancer and target analyses						  		 #
if [[ $DOPHASE5 ]]; then
 echo "Phase 5 - Characteristics of e-t interactions"
 ETdistance # distance between enhancers and their targets/closest genes
 histoneEnrichment # histone enrichment between strong/non-strong and others
 plotHisEnrichment
 GWASEnrichment
 getTargetList
fi

###################### EOF PHASE 5 #########################


############################################################
#                                                          #
# PHASE 7 - Old Hotspot Analysis                           #
if [[ $DOPHASE7 ]]; then
 echo "Phase 7 - Hotspots analysis"
 consecutiveReads
 getClusters
 getHotspots
 extendHotspots
 annotateHotspots
fi

###################### EOF PHASE 7 #########################


############################################################
#                                                          #
# PHASE 8 - Find Interactions and Get CEEs                 #
if [[ $DOPHASE8 ]]; then
 echo "Phase 8 - find interaction and get enhancer and target"
 findHSInteraction
 findHSPromoterInteraction
 findHSInteractionReads
 getHSCeeTarget
fi

###################### EOF PHASE 8 #########################


