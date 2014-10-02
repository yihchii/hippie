#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
FILE="${LINE}_hotspots.bed"
REMEDIAN=$2

if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi


echo "[`date`] extending the hotspots"
"${ETSCRIPT}/extend_hotspot_to_median.pl" "${REMEDIAN}"  "${LINE}_hotspots.bed" $GENOME_LEN "${LINE}_eHotspots_temp.bed"

echo "[`date`] merging the extended hotspots"
bedtools merge -i "${LINE}_eHotspots_temp.bed" -nms -scores sum > "${LINE}_eHotspots.bed"

EXITSTATUS=$?

if [ !  -s "${LINE}_eHotspots.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

