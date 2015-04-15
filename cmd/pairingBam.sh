#!/bin/bash
#

source $HIPPIE_INI
source $HIPPIE_CFG
 
export bam_file=$1
export sec_bam_file=$2
export chim_file=$3
export sec_chim_file=$4
export ChimSegMin=$5
export size_select=$6
export RE=$7
export out=$8


if [ !  -s "${GENOME_CHRM_PATH}/${RE}_site.bed" ]
then
 echo "Cannot find input file ${GENOME_CHRM_PATH}/${RE}_site.bed!"
 exit 100
fi

export re_file="${GENOME_CHRM_PATH}/${RE}_site.bed"

$PYTHON ${ETSCRIPT}/parse_starBam_to_paired.py $bam_file $sec_bam_file $chim_file $sec_chim_file $ChimSegMin $size_select $re_file $out


#Error checking

PROCESSED=$(tail -n 2 $SGE_STDOUT_PATH|grep -i "error"|tail -n 1)

shopt -s nocasematch
echo "checking stdout file: " $SGE_STDOUT_PATH
if [[ $PROCESSED =~ "error" ]];
        then
                echo $PROCESSED
                exit 100
fi

