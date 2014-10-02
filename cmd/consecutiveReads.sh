#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG
# test
#./README_HOTSPOT.sh ./original_data/GSM455133_30E0LAAXX.1.maq.hic.summary.binned.txt PBALL
FILE=$1
LINE=$2


if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi


echo "[`date`] Concating the file of ${LINE}......"

cut -f1-3,7 $FILE > "${LINE}_concat_temp.txt"
cut -f4-7 $FILE >> "${LINE}_concat_temp.txt"

echo "[`date`] Generating sorted bed file"
sort -T $TMPDIR -k 1,1 -k 2,2n "${LINE}_concat_temp.txt" > "${LINE}_concat.bed"
rm "${LINE}_concat_temp.txt"

echo "[`date`] Getting consecutive file of ${LINE}"
$BEDTOOLS merge -i "${LINE}_concat.bed" -c 4 -o collapse,count > "${LINE}_consecutive.bed"

EXITSTATUS=$?

if [ !  -s "${LINE}_consecutive.bed" ]
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


