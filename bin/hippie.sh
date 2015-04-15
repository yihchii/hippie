#!/bin/bash
# hippie.sh - A high-throughput identification pipeline for promoter interacting enhancer elements using Hi-C data
# Comments: Yih-Chii Hwang<yihhwang@mail.med.upenn.edu>
#######################################################################################################

#
# get command line parameters
while getopts h:f:i:mb: option
do
        case "$option" in
            h) HIPPIE_HOME_DIR="$OPTARG";;  # option -h path to hippie_home
            f) CONFIG="$OPTARG";;         # option -f path to config file
            i) HIPPIE_INI="$OPTARG";;     # option -i specify INI file
        esac
done

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


if [ -z "$HIPPIE_HOME" ];then
  echo "Missing HIPPIE_HOME:$HIPPIE_HOME"
  if [ ! -z "$HIPPIE_HOME_DIR" ];then
    echo "Loading HIPPIE_HOME_DIR:$HIPPIE_HOME_DIR"
    export HIPPIE_HOME=$HIPPIE_HOME_DIR
  fi
fi

mkdir -p ${STDOUT}

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
echo "FLOWCELLNAME: $FLOWCELLNAME"
echo "REFGENOME: $REFGENOME"


# estimate memory requirement for mapping (STAR2.4h)
if [ !  -s "${GENOME_REF}/SA" ]
then
 echo "Cannot find Genome Index ${GENOME_REF}/SA!"
 echo "Please check if the path of GENOME_REF setting is correct or generate the genome index following STAR user manual"
 exit 100
fi

SA=${GENOME_REF}"/SA"
SAindex=${GENOME_REF}"/SAindex"
Genome=${GENOME_REF}"/Genome"

saSize=$(wc -c $SA|cut -d" " -f1)
saindexSize=$(wc -c $SAindex|cut -d" " -f1)
genomeSize=$(wc -c $Genome|cut -d" " -f1)

# add additional 0.5G: 536870912 = 1024**3*0.5 = 0.5G 
refGenomeSize=$(($saSize + $saindexSize + $genomeSize+536870912))

refGenomeMem=`awk -v query=${refGenomeSize} 'BEGIN{hum[1024**3]="G";hum[1024**2]="M";hum[1024]="K";hum[1]="B"; \
for (x=1024**3; x>=1; x/=1024){ \
  if (query>=x) { printf "%.1f%s\n",query/x,hum[x];break } }}'`


batchLaunchScript=${FLOWCELLPATH}/${FLOWCELLNAME}_hippie_batch_launch.sh
"" > ${batchLaunchScript} # clear batch script

###### generate launch script for each sample
count=1
for dir in  ${DATASET[@]};do 
  echo $dir

  if [ -e "$dir" ];then
    mkdir -p "$dir/sam"
    mkdir -p "$dir/bed"
    mkdir -p "$dir/out"

		flist=($(ls $dir/fastq/*.fastq.gz 2>/dev/null));
		if [ ${#flist[@]} -eq 0 ]; then
			echo "WARNING: No fastq.gz found in $dir/fastq"
		fi

    DATASET_NAME=$(basename $dir)
    DATASET_NAME=${sample[ $count ]}
    NEW_LAUNCHER="$dir/$DATASET_NAME.sh"

    cp "$CMD_HIPPIE/hippie_sample_template.sh" "$NEW_LAUNCHER"

    sed -i "s:HIPPIE_INI=:HIPPIE_INI=\"$HIPPIE_INI\":" "$NEW_LAUNCHER"
    sed -i "s:HIPPIE_CFG=:HIPPIE_CFG=\"$HIPPIE_CFG\":" "$NEW_LAUNCHER"

		sed -i "s:refGenomeMem=:refGenomeMem=\"$refGenomeMem\":" "$NEW_LAUNCHER"

    sed -i "s/LINE=/LINE=$DATASET_NAME/" "$NEW_LAUNCHER"
    sed -i "s/READLENGTH=/READLENGTH=${readlength[$count]}/" "$NEW_LAUNCHER"
    sed -i "s/CELL=/CELL=${cell[$count]}/" "$NEW_LAUNCHER"
    sed -i "s/RE=/RE=${re[$count]}/" "$NEW_LAUNCHER"
    sed -i "s/RESIZE=/RESIZE=${resize[$count]}/" "$NEW_LAUNCHER"
		if [ $USESEG == 1 ]; then
    sed -i "s/USESEG=0/USESEG=1/" "$NEW_LAUNCHER"
		fi

    sed -i "s:SAMPLE_DIR=:SAMPLE_DIR=$dir:" "$NEW_LAUNCHER"
    sed -i "s:FASTQ_DIR=:FASTQ_DIR=$dir/fastq:" "$NEW_LAUNCHER"
    sed -i "s:SAM_DIR=:SAM_DIR=$dir/sam:" "$NEW_LAUNCHER"
    sed -i "s:BED_DIR=:BED_DIR=$dir/bed:" "$NEW_LAUNCHER"
    sed -i "s:OUT_DIR=:OUT_DIR=$dir/out:" "$NEW_LAUNCHER"

  else
    echo "Error: Missing data directory $dir"
    exit
  fi

  # Perform command line run of phase based on "-pN" argument flag

  count=$[ $count + 1 ]
  echo "Launcher created for dataset ${dir##*/}: ${NEW_LAUNCHER}"
  echo -e "To run:\n${NEW_LAUNCHER} -p1 -p2 -p3 -p4 -p5"
	echo "${NEW_LAUNCHER} -p1 -p2 -p3 -p4 -p5" >> ${batchLaunchScript}


done # Loop Datasets

echo -e "Batch launch script created:\n${batchLaunchScript}"


