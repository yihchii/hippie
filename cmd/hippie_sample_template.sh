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
              esac;;
            t) TEST_FUNCTION="$OPTARG";;    # execute function e.g.,   -t "stat _merged_nodup_uniq_recal"
        esac
done

#
# Globals
USER=$LOGNAME
export CMD_DIR=$CMD_HIPPIE
export REF_FASTA=$GENOME_REF
export SAMPLE_DIR=
export FASTQ_DIR=
export SAM_DIR=
export BED_DIR=
export OUT_DIR=

#
# User Configuration
USESEG=0  # USESEG=0: Enhancers specified by covering H3K4me1 or K27ac and DNase, but not H3K27me3 or H3K4me3
          # USESEG=1: Enhancers specified by enhancers and weak enhancers from ENCODE Combined Segmentations tracks


#Template variables below
export LINE=
export CELL=
export RE=
export RESIZE=
export refGenomeMem=
#
# QSUB
QSUB="qsub"
[[ $DODEBUG ]] && QSUB="echo qsub"

NUMJOBS=`qstat -u $USER|grep -c $USER`
export QSUBARGS="-S /bin/bash -q $GRID_QUEUE -cwd -v HIPPIE_INI,HIPPIE_CFG,REF_FASTA -j y -o $STDOUT -hard -l h_stack=256m,h_vmem=1G"

#
# function libraries
source $CMD_DIR/lib/hippie.phase1_lib.pe.sh 
source $CMD_DIR/lib/hippie.phase2_lib.pe.sh 
source $CMD_DIR/lib/hippie.phase3_lib.pe.sh 
source $CMD_DIR/lib/hippie.phase4_lib.pe.sh 
source $CMD_DIR/lib/hippie.phase5_lib.pe.sh 


if [ ! -z "$TEST_FUNCTION" ] 
then
 eval $TEST_FUNCTION
 exit
fi

#############################################################
# PHASE 1 - Create BAM alignments                           #
if [[ $DOPHASE1 ]]; then
	echo "Phase 1"
	loadGenome
	starMapping
	rmGenome
fi
###################### EOF PHASE 1 #########################


############################################################
#                                                          #
# PHASE 2 - Quality Control                                #
if [[ $DOPHASE2 ]]; then
	echo "Phase 2"
	pairingBam
	rmdupBed 
fi

###################### EOF PHASE 2 #########################

############################################################
#                                                          #
# PHASE 3 - find peak RE fragments                         #
if [[ $DOPHASE3 ]]; then
	echo "Phase 3 - Find Peak RE fragments"
	getDistanceToRS
	collapseData
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



