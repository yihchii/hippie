#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

BED_DIR=$1
OUT_DIR=$2
LINE=$3
CELL=$4
THRE=$5

# aggregate all interactions from each chromosome or inter-chromosomal interactions
cat ${BED_DIR}/chr*_${THRE}_reads_interaction_pvalue.txt ${BED_DIR}/${LINE}_interChrm_${THRE}_reads_interaction_pvalue.txt > ${OUT_DIR}/${LINE}_${THRE}_promoter_annotated_promoterInteraction_pvalue.bed

# find all promoter interaction
cat ${BED_DIR}/*${THRE}_promoter_annotated_promoterInteraction_pvalue.txt ${BED_DIR}/*${THRE}_interChrm_promoterInteraction_pvalue.txt |awk 'BEGIN{OFS="\t"}{ if ($8>0){sub (/:/,"\t",$2);sub (/-/,"\t",$2);print $2,$9,$3,$4;}if($13>0){sub (/:/,"\t",$1);sub (/-/,"\t",$1); print $1,$14,$3,$4;}}'|sort -T $TMPDIR -k1,1 -k2,2n >  ${OUT_DIR}/${LINE}_${THRE}_partnerTogene.bed

# Using threshould of p-value estimated by NB distribution
awk 'BEGIN{OFS="\t"}{if ($5<=0.1)print}' ${OUT_DIR}/${LINE}_${THRE}_partnerTogene.bed > ${OUT_DIR}/${LINE}_${THRE}_partnerTogene_sig.bed

# Merge target gene by the partner
$BEDTOOLS merge -i ${OUT_DIR}/${LINE}_${THRE}_partnerTogene.bed -c 4 -o collapse,count -delim "|">  ${OUT_DIR}/${LINE}_${THRE}_partnerTogene_merged.bed

# significant
$BEDTOOLS merge -i ${OUT_DIR}/${LINE}_${THRE}_partnerTogene_sig.bed -c 4 -o collapse,count -delim "|">  ${OUT_DIR}/${LINE}_${THRE}_partnerTogene_sig_merged.bed

if [ "$USESEG" == 0 ]; then
$BEDTOOLS annotate -i ${OUT_DIR}/${LINE}_${THRE}_partnerTogene_merged.bed -files $BROAD_PATH/${CELL}H3k27ac.gz $BROAD_PATH/${CELL}H3k4me1.gz $BROAD_PATH/${CELL}H3k4me2.gz $BROAD_PATH/${CELL}H3k4me3.gz $BROAD_PATH/${CELL}H3k27me3.gz $DNASE_PATH/${CELL}DNase.gz $BROAD_PATH/${CELL}P300.gz $BROAD_PATH/${CELL}Ctcf.gz> ${OUT_DIR}/${LINE}_${THRE}_promoter_partner_merged_ENCODE.bed

echo "significant annoatate"
$BEDTOOLS annotate -i ${OUT_DIR}/${LINE}_${THRE}_partnerTogene_sig_merged.bed -files $BROAD_PATH/${CELL}H3k27ac.gz $BROAD_PATH/${CELL}H3k4me1.gz $BROAD_PATH/${CELL}H3k4me2.gz $BROAD_PATH/${CELL}H3k4me3.gz $BROAD_PATH/${CELL}H3k27me3.gz $DNASE_PATH/${CELL}DNase.gz $BROAD_PATH/${CELL}P300.gz $BROAD_PATH/${CELL}Ctcf.gz> ${OUT_DIR}/${LINE}_${THRE}_promoter_partner_sig_merged_ENCODE.bed

# 1-3: bed regions
# 4: target gene(s) in the same fragment
# 5: # promoter fragment interacting
# 6: ${CELL}H3k27ac
# 7: ${CELL}H3k4me1
# 8: ${CELL}H3k4me2
# 9: ${CELL}H3k4me3
# 10: ${CELL}H3k27me3
# 11: DNaseI
# 12: P300
# 13: Ctcf
#c("K27ac","K4me1","K4me2","K4me3","K27me3","DnaseI","p300","CTCF")

cat ${OUT_DIR}/${LINE}_${THRE}_promoter_partner_merged_ENCODE.bed| awk 'BEGIN{OFS="\t"}{if ($6+$7>0&&$11>0&&$9==0&&$10==0)print $1,$2,$3,$4,$5}' |sort -u> ${OUT_DIR}/${LINE}_${THRE}_CEE_gene.bed
cat ${OUT_DIR}/${LINE}_${THRE}_promoter_partner_sig_merged_ENCODE.bed| awk 'BEGIN{OFS="\t"}{if ($6+$7>0&&$11>0&&$9==0&&$10==0)print $1,$2,$3,$4,$5}' |sort -u> ${OUT_DIR}/${LINE}_${THRE}_CEE_gene_sig.bed

else   #$USESEG==1 
$BEDTOOLS intersect -a ${OUT_DIR}/${LINE}_${THRE}_partnerTogene_merged.bed -b ${BROAD_PATH}/${CELL}CombSegEnh.gz -wa -u > ${OUT_DIR}/${LINE}_${THRE}_CEE_gene.bed
$BEDTOOLS intersect -a ${OUT_DIR}/${LINE}_${THRE}_partnerTogene_sig_merged.bed -b ${BROAD_PATH}/${CELL}CombSegEnh.gz -wa -u > ${OUT_DIR}/${LINE}_${THRE}_CEE_gene_sig.bed


fi

EXITSTATUS=$?

if [ !  -s "${OUT_DIR}/${LINE}_${THRE}_CEE_gene_sig.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS


