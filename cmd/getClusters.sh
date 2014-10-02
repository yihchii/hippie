#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
FILE="${LINE}_consecutive.bed"
BEDFILE="${LINE}_concat.bed" # the bedfile should be the original concated bed file

if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi

echo "[`date`] Getting gaps of ${LINE}"
"${ETSCRIPT}/get_gap_length.pl" "${FILE}" "${GENOME_LEN}" "${LINE}_gapLength.txt"

echo "[`date`] geometric test for gaps of ${LINE}"
R --no-save --args "${LINE}_gapLength.txt" "${LINE}_lower.gaplength.txt" "${LINE}_upper.gaplength.txt" < "${ETSCRIPT}/gap_geometric_distribution_analysis.R"

echo "[`date`] filter clusters by gap" 
# create the file of fragments by each chromosome
awk -F'\t' '{print > $1".bed"}' ${BEDFILE}
"${ETSCRIPT}/merge_reads.pl" "${LINE}_lower.gaplength.txt"
sort -T $TMPDIR -k 1,1 -k 2,2n chr*_clusters.bed > "${LINE}_clusters.bed"

EXITSTATUS=$?

if [ !  -s "${LINE}_clusters.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

#echo "geometric test for hotspot"
#R --no-save --args "${LINE}_gap_filtered_cluster.txt" "${LINE}_lower.clusterlength.txt" "${LINE}_upper.clusterlength.txt" "${LINE}_hotspot.txt" < cluster_geometric_distribution_analysis.R 
#1_cl44  1 17450 18061 612 3 9

#echo "return chromosome number as chromosome id"
#tail -n+2 "${LINE}_hotspot.txt" | awk 'BEGIN{FS= "\t"; printf("clusterID\tchrm\tcStart\tcEnd\tcLength\tregionNum\treads\n")}{if ($2 == 23) printf ("%s\tchrx\t%s\t%s\t%s\t%s\t%s\n",$1,$3,$4,$5,$6,$7);else if ($2 == 24) printf ("%s\tchry\t%s\t%s\t%s\t%s\t%s\n",$1,$3,$4,$5,$6,$7);else printf("%s\tchr%s\t%s\t%s\t%s\t%s\t%s\n",$1,$2,$3,$4,$5,$6,$7);}' > "${LINE}_hotspot_chrm.txt"


