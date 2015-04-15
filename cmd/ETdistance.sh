#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
THRE=$2
OUT_DIR=$3
FILE="${OUT_DIR}/${LINE}_${THRE}_CEE_gene_sig.bed"

if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi

# 2014/09/21 update: using threshould of p-value estimated by NB distribution

# extract CEE and find the closest gene distance distribution
cut -f 1-3 "${FILE}"|sort -u > "${OUT_DIR}/${LINE}_${THRE}_CEE_sig.bed"
$BEDTOOLS closest -a "${OUT_DIR}/${LINE}_${THRE}_CEE_sig.bed" -b \
"${GENOME_PATH}/refGene_promoter_merged.bed" -d > "${OUT_DIR}/${LINE}_${THRE}_CEE_sig_closestGene.bed"
# 1:CEE_chr 2:CEE_start 3:CEE_end 4:gene_chr 5:gene_start 6:gene_end 7:gene_symbol 8:num_symbol 9:distance


OUT="${OUT_DIR}/${LINE}_${THRE}_ET_distance.txt"


# get distance to the closeset gene
# a. generate distance file for enhancer and closeset gene
cut -f9 "${OUT_DIR}/${LINE}_${THRE}_CEE_sig_closestGene.bed" > "${OUT_DIR}/${LINE}_${THRE}_CEE_sig_closestGene_dist.txt"
CLOSEST_DIST=`awk 'BEGIN {sum=0}{sum+=$1}END{print sum/NR}' "${OUT_DIR}/${LINE}_${THRE}_CEE_sig_closestGene_dist.txt"`
CLOSEST_DIST_MED=`cat "${OUT_DIR}/${LINE}_${THRE}_CEE_sig_closestGene_dist.txt"|sort -n| awk '{arr[NR]=$1}
   END { if (NR%2==1) print arr[(NR+1)/2]; else print (arr[NR/2]+arr[NR/2+1])/2}'` 

echo "cloeset_dist_ave=${CLOSEST_DIST}" > "${OUT}"
echo "cloeset_dist_med=${CLOSEST_DIST_MED}" >> "${OUT}"

# get distance to the target gene
# a. generate distance file for enhancer and target
"${ETSCRIPT}/get_enh_gene_distance.pl" "${OUT_DIR}/${LINE}_${THRE}_CEE_gene_sig.bed" > "${OUT_DIR}/${LINE}_${THRE}_CEE_gene_sig_dist.txt"
ET_DIST=`awk 'BEGIN{sum=0}{sum+=$1}END{print sum/NR}' "${OUT_DIR}/${LINE}_${THRE}_CEE_gene_sig_dist.txt"`
ET_DIST_MED=`cat "${OUT_DIR}/${LINE}_${THRE}_CEE_gene_sig_dist.txt"|sort -n|awk '{arr[NR]=$1}
   END { if (NR%2==1) print arr[(NR+1)/2]; else print (arr[NR/2]+arr[NR/2+1])/2}'`
echo "ET_dist_ave=${ET_DIST}" >> "${OUT}"
echo "ET_dist_med=${ET_DIST_MED}" >> "${OUT}"

$RPATH/R --no-save --args "${LINE}" "${THRE}" "${OUT_DIR}/${LINE}_${THRE}_CEE_sig_closestGene_dist.txt" "${OUT_DIR}/${LINE}_${THRE}_CEE_gene_sig_dist.txt" "${OUT_DIR}" < "${ETSCRIPT}/distance_box_plot.R"




EXITSTATUS=$?

if [ ! -s $OUT ]
then
 echo "Incomplete output file $OUT"
 exit 100
fi

exit $EXITSTATUS

