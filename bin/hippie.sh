#!/bin/bash
# hippie.sh - A high-throughput identification pipeline for promoter interacting enhancer elements using Hi-C data
# Comments: yihhwang@mail.med.upenn.edu, chiaolin@mail.med.upenn.edu, OttoV@upenn.edu
#######################################################################################################

#
# get command line parameters
while getopts h:f:i:mbp:t: option
do
        case "$option" in
            h) HIPPIE_HOME_DIR="$OPTARG";;  # option -h path to hippie_home
            f) CONFIG="$OPTARG";;         # option -f path to config file
            i) HIPPIE_INI="$OPTARG";;               # option -i specify INI file
            b) BATCHONLY=true;;           # option -b if run in batch mode only
            p)                            # -p 1/2/3 to execute a particular phase, e.g.: -p1 -p2 -p3
              case "$OPTARG" in
                1) DOPHASE1=true;;
                2) DOPHASE2=true;;
                3) DOPHASE3=true;;
              esac;;
        esac
done

if [ -z "$HIPPIE_HOME" ];then
  echo "Missing HIPPIE_HOME:$HIPPIE_HOME"
  if [ ! -z "$HIPPIE_HOME_DIR" ];then
    echo "Loading HIPPIE_HOME_DIR:$HIPPIE_HOME_DIR"
    export HIPPIE_HOME=$HIPPIE_HOME_DIR
  fi
fi
#
# Initialization
export PWD=`pwd`

if [ -z "$HIPPIE_INI" ];then
  export HIPPIE_INI=$HIPPIE_HOME/hippie.ini
else
  export HIPPIE_INI
fi

if [ ! -s "$HIPPIE_INI" ];then
  echo "Error: HIPPIE_INI not found ($HIPPIE_INI)"
  exit
else
 echo "USING INI File $HIPPIE_INI"
 source $HIPPIE_INI
fi

#Load Dataset config
if [ -e "$CONFIG" ];then
 if [ $(basename "$CONFIG") == "$CONFIG" ]
  then 
   export HIPPIE_CFG="$PWD/$CONFIG"
  else 
   export HIPPIE_CFG="$CONFIG"
 fi

else
 echo "Missing Config file, USAGE: hippie.sh [-i hippie.ini] [-h hippie_source] -f my_config.cfg"
 exit
fi

echo "Using CONFIG $HIPPIE_CFG"

source $HIPPIE_CFG

REFGENOME=$(basename $GENOME_REF .fasta)
FLOWCELLNAME=$(basename $FLOWCELLPATH)
echo "PROJECTNAME: $PROJECTNAME"
echo "FLOWCELLNAME: $FLOWCELLNAME"
echo "REFGENOME: $REFGENOME"
echo "DBSNP_VERSION: $DBSNP_VERSION"
echo "TARGET_COVERAGE: $TARGET_COVERAGE"


###### generate launch script for a flowcell/batch
if [[ $BATCHONLY ]];then
  mkdir -p "cmd/vcf"
  mkdir -p "cmd/stat"
  mkdir -p "bam"

  FC_LAUNCHER="cmd/$FLOWCELLNAME.sh"
  cp "$CMD_HIPPIE/hippie_flowcell_template.sh" "$FC_LAUNCHER"

    sed -i "s:HIPPIE_INI=:HIPPIE_INI=\"$HIPPIE_INI\":" "$FC_LAUNCHER"
    sed -i "s:HIPPIE_CFG=:HIPPIE_CFG=\"$HIPPIE_CFG\":" "$FC_LAUNCHER"
    sed -i "s:^DATA_TYPE=:DATA_TYPE=\"$DATA_TYPE\":" "$FC_LAUNCHER"
    sed -i "s:^TARGET_COVERAGE=:TARGET_COVERAGE=\"$TARGET_COVERAGE\":" "$FC_LAUNCHER"

    sed -i "s/mbq=/mbq=$MBQ/" "$FC_LAUNCHER"
    sed -i "s/mmq=/mmq=$MMQ/" "$FC_LAUNCHER"
    sed -i "s/THRE=/THRE=$THRE/" "$FC_LAUNCHER"

    if [ -z "$GRID_QUEUE" ];then
       GRID_QUEUE="all.q"
    fi
    sed -i "s:^GRID_QUEUE=:GRID_QUEUE=\"$GRID_QUEUE\":" "$FC_LAUNCHER"
      
    sed -i "s/FC=/FC=$FLOWCELLNAME/" "$FC_LAUNCHER"

    exit
fi

###### generate launch script for each sample

count=1
for dir in  ${DATASET[@]};do 
  echo $dir
  if [[ $MYSQL ]];then
		SAMPLENAME=${sample[ $count ]}
		perl $MYSQL_HIPPIE/InsertTable/insertSubject.pl --subject_name $SAMPLENAME  --project_name $PROJECTNAME
		perl $MYSQL_HIPPIE/InsertTable/insertSample.pl --subject_name $SAMPLENAME  --sample_name ${rgid[$count]} --capture_lib $LB --barcode ${pu[$count]}
		perl $MYSQL_HIPPIE/InsertTable/insertReadGroup.pl --subject_name $SAMPLENAME --flowcell_name $FLOWCELLNAME
  fi

  if [ -e "$dir" ];then
    mkdir -p "$dir/qseq"
    mkdir -p "$dir/fastq"
    mkdir -p "$dir/cmd/vcf"
    mkdir -p "$dir/cmd/stat"
    mkdir -p "$dir/sai"
    mkdir -p "$dir/sam"
    mkdir -p "$dir/bam"

    for f in $(ls "$dir"/*_sequence.txt* 2>/dev/null) $(ls "$dir"/*_qseq.txt* 2>/dev/null); do
      ln -s "$f" "$dir/qseq/" 2>/dev/null
    done;  

		flist=($(ls $dir/*.fastq* 2>/dev/null));
		if [ ${#flist[@]} -eq 0 ]; then
			echo "WARNING: No fastq found in $dir"
#			exit
		fi


		
		if [[ $DATA_TYPE == "ONEFASTQ" || $DATA_TYPE == "ONEFASTQSE" ]]; then
			if [ ${#flist[@]} -gt 1 ]; then
				echo "DATA_TYPE == $DATA_TYPE but more than one fastq found. Only the first would be processed."
				echo ${flist[@]}
			fi
			SAMPLENAME=${sample[ $count ]}
			if [[ ${flist[0]} =~ '.gz' ]]; then
				link_name="s_${SAMPLENAME}_sequence.txt.gz"
			else
				link_name="s_${SAMPLENAME}_sequence.txt"
			fi
			
			ln -s "${flist[0]}" "$dir/fastq/s_${SAMPLENAME}_sequence.txt.gz" 2>/dev/null
		else
		
			for f in ${flist[@]}; do
				ln -s "$f" "$dir/fastq/" 2>/dev/null
			done;  
		fi
    #
    # Copy templates to data directories, fill-in required values
 
    DATASET_NAME=$(basename $dir)
    DATASET_NAME=${sample[ $count ]}
    NEW_LAUNCHER="$dir/cmd/$DATASET_NAME.sh"

    cp "$CMD_HIPPIE/hippie_sample_template.sh" "$NEW_LAUNCHER"

    sed -i "s:HIPPIE_INI=:HIPPIE_INI=\"$HIPPIE_INI\":" "$NEW_LAUNCHER"
    sed -i "s:HIPPIE_CFG=:HIPPIE_CFG=\"$HIPPIE_CFG\":" "$NEW_LAUNCHER"
    sed -i "s:^DATA_TYPE=:DATA_TYPE=\"$DATA_TYPE\":" "$NEW_LAUNCHER"
    sed -i "s:^TARGET_COVERAGE=:TARGET_COVERAGE=\"$TARGET_COVERAGE\":" "$NEW_LAUNCHER"

    if [ -z "$GRID_QUEUE" ];then
       GRID_QUEUE="all.q"
    fi
    sed -i "s:^GRID_QUEUE=:GRID_QUEUE=\"$GRID_QUEUE\":" "$NEW_LAUNCHER"
      
    # Fill-in Read Group (for bwa)
    sed -i \
      "s/RG_STR=/RG_STR=\'@RG\\\tID:${rgid[$count]}\\\tSM:${sample[$count]}\\\tPL:Illumina\\\tPU:${pu[$count]}\\\tLB:$LB\\\tDS:$DS\\\tCN:$CN\\\tDT:$DT\'/" \
      "$NEW_LAUNCHER"

    # Fill-in Read Group (for picard)
    if [ -z "${pu[$count]}" ];then
       pu[$count]="NA"
    fi
    
    sed -i \
      "s/RG_STR_PICARD=/RG_STR_PICARD=\'ID=${rgid[$count]} SM=${sample[$count]} PL=Illumina PU=${pu[$count]} LB=$LB DS=$DS CN=$CN\'/" \
      "$NEW_LAUNCHER"
   
    sed -i "s/LINE=/LINE=$DATASET_NAME/" "$NEW_LAUNCHER"
    sed -i "s/RGID=/RGID=${rgid[$count]}/" "$NEW_LAUNCHER"
    sed -i "s/READLENGTH=/READLENGTH=${readlength[$count]}/" "$NEW_LAUNCHER"
    sed -i "s/CELL=/CELL=${cell[$count]}/" "$NEW_LAUNCHER"
    sed -i "s/REMEDIAN=/REMEDIAN=${remedian[$count]}/" "$NEW_LAUNCHER"
    sed -i "s/RE=/RE=${re[$count]}/" "$NEW_LAUNCHER"
		if [ $USESEG == 1 ]; then
    sed -i "s/USESEG=0/USESEG=1/" "$NEW_LAUNCHER"
		fi
    sed -i "s/mbq=/mbq=$MBQ/" "$NEW_LAUNCHER"

    sed -i "s/mmq=/mmq=$MMQ/" "$NEW_LAUNCHER"
    sed -i "s/THRE=/THRE=$THRE/" "$NEW_LAUNCHER"

    sed -i "s:QSEQ_DIR=:QSEQ_DIR=$dir/qseq:" "$NEW_LAUNCHER"
    sed -i "s:FASTQ_DIR=:FASTQ_DIR=$dir/fastq:" "$NEW_LAUNCHER"
    sed -i "s:SAI_DIR=:SAI_DIR=$dir/sai:" "$NEW_LAUNCHER"
    sed -i "s:SAM_DIR=:SAM_DIR=$dir/sam:" "$NEW_LAUNCHER"
    sed -i "s:BAM_DIR=:BAM_DIR=$dir/bam:" "$NEW_LAUNCHER"    
   
  else
    echo "Error: Missing data directory $dir"
    exit
  fi

  # Perform command line run of phase based on "-pN" argument flag
  if [[ $DOPHASE1 ]]; then
    echo "Running Phase 1"
    echo "sh $NEW_LAUNCHER -p1"
    sh $NEW_LAUNCHER -p1
  fi

  if [[ $DOPHASE2 ]]; then
    echo "Running Phase 2"
    echo "sh $NEW_LAUNCHER -p2"
    sh $NEW_LAUNCHER -p2
  fi

  if [[ $DOPHASE3 ]]; then
    echo "Running Phase 3"
    echo "sh $NEW_LAUNCHER -p3"
    sh $NEW_LAUNCHER -p3
  fi

  count=$[ $count + 1 ]
done # Loop Datasets



