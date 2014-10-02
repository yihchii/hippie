#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1

export IN="histone_enrichment.txt"

echo "[`date`] plot epigenomics enrichment ${LINE}"
$RPATH/R --no-save --args "${LINE}" < "${ETSCRIPT}/plot_enrichment.R"


