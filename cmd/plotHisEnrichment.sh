#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
OUT_DIR=$2


echo "[`date`] plot epigenomics enrichment ${LINE}"
$RPATH/R --no-save --args "${LINE}" "histone_enrichment.txt" $OUT_DIR < "${ETSCRIPT}/plot_enrichment.R"

EXITSTATUS=$?

if [ !  -s "${OUT_DIR}/${LINE}_histone_enrichment.jpg" ]
then
 echo "Incorrect Output!"
 exit 100
fi


exit $EXITSTATUS

