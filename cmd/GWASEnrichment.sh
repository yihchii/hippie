#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
THRE=$2

# 2014/09/21 update: using threshould of p-value estimated by NB distribution

export OUT="${LINE}_${THRE}_GWAS_enrichment.txt"

echo -e "cond\tGWAS" > ${OUT} 

# intersect CEE
#bedtools intersect -a ${LINE}_${THRE}_CEE_sig.bed -b ${GENOME_PATH}/snp137Flagged.bed.gz -wa > ${LINE}_${THRE}_CEE_sig_GWAS.bed
$BEDTOOLS intersect -a ${LINE}_${THRE}_CEE_sig.bed -b ${GENOME_PATH}/gwascatalog_20131111.bed -wa > ${LINE}_${THRE}_CEE_sig_GWAS.bed


# intersect Hi-C interactor with the encode marks
#cat ${LINE}_${THRE}_promoter_partner_ENCODE.bed| awk 'BEGIN{OFS="\t"}{if ($5>1 && ($6+$7+$8+$9>0&&$11>0))print $1,$2,$3,$4,$5}' |sort -u> ${LINE}_${THRE}_CEE_gene_sig.bed
###
# ${LINE}_${THRE}_sig_interactor_sorted_ENCODE.bed
# 1. chr
# 2. start
# 3. end
# 4. H3k27ac
# 5. H3k4me1
# 6. H3k4me2
# 7. H3k4me3
# 8. H3k27me3
# 9. DNase
# 10. P300
# 11. Ctcf


cat ${LINE}_${THRE}_sig_interactor_ENCODE.bed | awk 'BEGIN{OFS="\t"}{if (($4+$5+$6+$7>0&&$9>0))print $1,$2,$3}' |sort -u> ${LINE}_${THRE}_notPARTNER_sig.bed
#bedtools intersect -a ${LINE}_${THRE}_notPARTNER_sig.bed -b ${GENOME_PATH}/snp137Flagged.bed.gz -wa > ${LINE}_${THRE}_notCEEPartner_GWAS.bed
#bedtools intersect -a ${LINE}_${THRE}_interactor_sorted.bed -b ${GENOME_PATH}/snp137Flagged.bed.gz -wa > ${LINE}_${THRE}_interactor_GWAS.bed
bedtools intersect -a ${LINE}_${THRE}_notPARTNER_sig.bed -b ${GENOME_PATH}/gwascatalog_20131111.bed -wa > ${LINE}_${THRE}_notCEEPartner_GWAS.bed
bedtools intersect -a ${LINE}_${THRE}_interactor_sorted.bed -b ${GENOME_PATH}/gwascatalog_20131111.bed -wa > ${LINE}_${THRE}_interactor_GWAS.bed

CEE=$(wc ${LINE}_${THRE}_CEE_sig.bed|awk '{print $3}')
CEEGWAS=$(wc ${LINE}_${THRE}_CEE_sig_GWAS.bed| awk '{print $3}')
NOTPARTNER=$(wc ${LINE}_${THRE}_notPARTNER_sig.bed| awk '{print $3}')
NOTPARTNERGWAS=$(wc ${LINE}_${THRE}_notCEEPartner_GWAS.bed| awk '{print $3}')
INTERACTOR=$(wc ${LINE}_${THRE}_interactor_sorted.bed| awk '{print $3}')
INTERACTORGWAS=$(wc ${LINE}_${THRE}_interactor_GWAS.bed| awk '{print $3}')

echo -e "CEE\t${CEE}" >> ${OUT}
echo -e "CEE_GWAS\t${CEEGWAS}" >> ${OUT}
echo -e "NOTPARTNER\t${NOTPARTNER}" >> ${OUT}
echo -e "NOTPARTNER_GWAS\t${NOTPARTNERGWAS}" >> ${OUT}
echo -e "INTERACTOR\t${INTERACTOR}" >> ${OUT}
echo -e "INTERACTOR_GWAS\t${INTERACTORGWAS}" >> ${OUT}

NOTPARTNERFOLD=$(bc <<< " scale =10; (${CEEGWAS}/${CEE})/(${NOTPARTNERGWAS}/${NOTPARTNER})")
FOLD=$(bc <<< " scale =10; (${CEEGWAS}/${CEE})/(${INTERACTORGWAS}/${INTERACTOR})")

echo -e "NOTPARTNERFOLD\t${NOTPARTNERFOLD}" >> ${OUT}
echo -e "FOLD\t${FOLD}" >> ${OUT}




if [ ! -s $OUT ]
then
 echo "Incomplete output file $OUT"
 exit 100
fi

exit $EXITSTATUS

