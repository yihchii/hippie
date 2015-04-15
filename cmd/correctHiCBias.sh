#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

BED_DIR=$1
LINE=$2
RE=$3
THRE=$4

cd ${BED_DIR};
files=()
for x in `ls`; do
    if [[ $x =~ ^[A-Za-z0-9]+_${THRE}_reads_interaction.txt ]]; then
				files+=("${BED_DIR}/$x")
    fi;
done
cd -

FILE="${files[0]}"

if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi


# calculate p-values and correct the Hi-C bias of GC content, mappability and length
for i in "${!files[@]}"; do
	echo "[`date`] correcting intra-chromosomal interaction by GC content, mappability, and length"
	"${ETSCRIPT}/estimate_intra_read_pairs_sig.pl" "${GENOME_CHRM_PATH}/${RE}_fragment_GC_MAPP_LEN.bed" ${files[$i]} "${BED_DIR}/intra_Fgc_binned.txt" "${BED_DIR}/intra_L_binned.txt" "${BED_DIR}"
done

echo "[`date`] correcting inter-chromosomal interaction by GC content, mappability, and length"
"${ETSCRIPT}/estimate_inter_read_pairs_sig.pl" "${GENOME_CHRM_PATH}/${RE}_fragment_GC_MAPP_LEN.bed" "${BED_DIR}/${LINE}_interChrm_${THRE}_reads_interaction.txt" "${BED_DIR}/inter_Fgc_binned.txt" "${BED_DIR}/inter_L_binned.txt" "${BED_DIR}/${LINE}_interChrm_${THRE}_reads_interaction_pvalue.txt"

echo "[`date`] Complete find interaction p-values"


EXITSTATUS=$?
if [ !  -s "${BED_DIR}/${LINE}_interChrm_${THRE}_reads_interaction_pvalue.txt" ]
then
 echo "Incorrect Output!"
 exit 100
fi
exit $EXITSTATUS

