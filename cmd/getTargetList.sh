#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

# 2014/09/21 update: using threshould of p-value estimated by NB distribution

LINE=$1
THRE=$2
FILE="${LINE}_${THRE}_CEE_gene_sig.bed"
OUT="${LINE}_${THRE}_target.txt"

if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi


# extract target gene list
"${ETSCRIPT}/extract_gene.pl" "${FILE}" "${OUT}"


EXITSTATUS=$?

if [ ! -s $OUT ]
then
 echo "Incomplete output file $OUT"
 exit 100
fi

exit $EXITSTATUS

