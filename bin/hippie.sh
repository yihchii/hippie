#!/bin/bash
# hippie.sh - A high-throughput identification pipeline for promoter interacting enhancer elements using Hi-C data
# Comments: yihhwang@mail.med.upenn.edu, chiaolin@mail.med.upenn.edu, OttoV@upenn.edu
#######################################################################################################

# get command line parameters
while getopts h:f:i:mbp:t: option
do
        case "$option" in
            h) HIPPIE_HOME_DIR="$OPTARG";;  # option -h path to hippie_home
            f) CONFIG="$OPTARG";;         # option -f path to config file
            i) HIPPIE_INI="$OPTARG";;               # option -i specify INI file
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
    mkdir -p "$dir/fastq"
    mkdir -p "$dir/sai"
    mkdir -p "$dir/sam"
    mkdir -p "$dir/bam"
    mkdir -p "$dir/cmd"

		flist=($(ls $dir/*.fastq* 2>/dev/null));
		if [ ${#flist[@]} -eq 0 ]; then
			echo "WARNING: No fastq found in $dir"
		fi
		ln -s  $dir/*.fastq* $dir/fastq/


		
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

    sed -i "s:FASTQ_DIR=:FASTQ_DIR=$dir/fastq:" "$NEW_LAUNCHER"
    sed -i "s:SAI_DIR=:SAI_DIR=$dir/sai:" "$NEW_LAUNCHER"
    sed -i "s:SAM_DIR=:SAM_DIR=$dir/sam:" "$NEW_LAUNCHER"
    sed -i "s:BAM_DIR=:BAM_DIR=$dir/bam:" "$NEW_LAUNCHER"    
   
  else
    echo "Error: Missing data directory $dir"
    exit
  fi

  # Perform command line run of phase based on "-pN" argument flag
  count=$[ $count + 1 ]
done # Loop Datasets



