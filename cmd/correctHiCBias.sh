#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
RE=$2
THRE=$3

FILE="chr1_${THRE}_reads_interaction.txt"

if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi

# calculate p-values and correct the Hi-C bias of GC content, mappability and length
echo "[`date`] correcting intra-chromosomal interaction by GC content, mappability, and length"
"${ETSCRIPT}/estimate_intra_read_pairs_sig.pl" "${GENOME_CHRM}/${RE}_fragment_GC_MAPP_LEN.bed" chr*_95_reads_interaction.txt "intra_Fgc_binned.txt" "intra_L_binned.txt"

echo "[`date`] correcting inter-chromosomal interaction by GC content, mappability, and length"
"${ETSCRIPT}/estimate_inter_read_pairs_sig.pl" "${GENOME_CHRM}/${RE}_fragment_GC_MAPP_LEN.bed" "${LINE}_interChrm_${THRE}_reads_interaction.txt" "inter_Fgc_binned.txt" "inter_L_binned.txt" "${LINE}_interChrm_${THRE}_reads_interaction_pvalue.txt"

echo "[`date`] Complete find interaction p-values"


EXITSTATUS=$?
if [ !  -s "${LINE}_interChrm_${THRE}_reads_interaction_pvalue.txt" ]
then
 echo "Incorrect Output!"
 exit 100
fi
exit $EXITSTATUS

