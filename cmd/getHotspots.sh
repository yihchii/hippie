#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
FILE="${LINE}_clusters.bed"

if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi


echo "[`date`] get cluster lengths"
awk 'BEGIN{OFS="\t"}{print $1,$3-$2}' "${FILE}" > "${LINE}_cluster_lengths.txt"


echo "[`date`] geometric test for hotspot"
R --no-save --args "${LINE}_cluster_lengths.txt" "${LINE}_lower.clusterlength.txt" "${LINE}_upper.clusterlength.txt" < "${ETSCRIPT}/cluster_geometric_distribution_analysis.R"
#chr1 222

echo "[`date`] filter hotspots by cluster lengths"
# create the file of fragments by each chromosome
"${ETSCRIPT}/filter_clusters.pl" "${LINE}_upper.clusterlength.txt"
sort -T $TMPDIR -k 1,1 -k 2,2n chr*_hotspots.bed > "${LINE}_hotspots.bed"



echo "[`date`] hotspots identification completed"
#tail -n+2 "${LINE}_hotspot.txt" | awk 'BEGIN{FS= "\t"; printf("clusterID\tchrm\tcStart\tcEnd\tcLength\tregionNum\treads\n")}{if ($2 == 23) printf ("%s\tchrx\t%s\t%s\t%s\t%s\t%s\n",$1,$3,$4,$5,$6,$7);else if ($2 == 24) printf ("%s\tchry\t%s\t%s\t%s\t%s\t%s\n",$1,$3,$4,$5,$6,$7);else printf("%s\tchr%s\t%s\t%s\t%s\t%s\t%s\n",$1,$2,$3,$4,$5,$6,$7);}' > "${LINE}_hotspot_chrm.txt"


EXITSTATUS=$?

if [ !  -s "${LINE}_hotspots.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

