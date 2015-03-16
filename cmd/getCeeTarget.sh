#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
CELL=$2
THRE=$3

# find all promoter interaction
# 2014/07/28 fix the sort uniq bug (was sort -k1,1 -k2,2n -u), which would keep only one gene targeted by a putative enhancer
cat *${THRE}_promoter_annotated_promoterInteraction_pvalue.txt *${THRE}_interChrm_promoterInteraction_pvalue.txt |awk 'BEGIN{OFS="\t"}{ if ($8>0){sub (/:/,"\t",$2);sub (/-/,"\t",$2);print $2,$9,$3,$4;}if($13>0){sub (/:/,"\t",$1);sub (/-/,"\t",$1); print $1,$14,$3,$4;}}'|sort -T $TMPDIR -k1,1 -k2,2n >  ${LINE}_${THRE}_partnerTogene.bed

# 2014/09/21 update: using threshould of p-value estimated by NB distribution
awk 'BEGIN{OFS="\t"}{if ($5<=0.1)print}' ${LINE}_${THRE}_partnerTogene.bed > ${LINE}_${THRE}_partnerTogene_sig.bed

# merge target gene by the partner
$BEDTOOLS merge -i ${LINE}_${THRE}_partnerTogene.bed -c 4 -o collapse,count -delim "|">  ${LINE}_${THRE}_partnerTogene_merged.bed

# find all promoter partner


if [ "$USESEG" == 0 ]; then

$BEDTOOLS annotate -i ${LINE}_${THRE}_partnerTogene_merged.bed -files $BROAD_PATH/${CELL}H3k27ac.gz $BROAD_PATH/${CELL}H3k4me1.gz $BROAD_PATH/${CELL}H3k4me2.gz $BROAD_PATH/${CELL}H3k4me3.gz $BROAD_PATH/${CELL}H3k27me3.gz $DNASE_PATH/${CELL}DNase.gz $BROAD_PATH/${CELL}P300.gz $BROAD_PATH/${CELL}Ctcf.gz> ${LINE}_${THRE}_promoter_partner_merged_ENCODE.bed

echo "strong annoatate"
#strong
$BEDTOOLS merge -i ${LINE}_${THRE}_partnerTogene_sig.bed -c 4 -o collapse,count -delim "|">  ${LINE}_${THRE}_partnerTogene_sig_merged.bed
$BEDTOOLS annotate -i ${LINE}_${THRE}_partnerTogene_sig_merged.bed -files $BROAD_PATH/${CELL}H3k27ac.gz $BROAD_PATH/${CELL}H3k4me1.gz $BROAD_PATH/${CELL}H3k4me2.gz $BROAD_PATH/${CELL}H3k4me3.gz $BROAD_PATH/${CELL}H3k27me3.gz $DNASE_PATH/${CELL}DNase.gz $BROAD_PATH/${CELL}P300.gz $BROAD_PATH/${CELL}Ctcf.gz> ${LINE}_${THRE}_promoter_partner_sig_merged_ENCODE.bed

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

cat ${LINE}_${THRE}_promoter_partner_merged_ENCODE.bed| awk 'BEGIN{OFS="\t"}{if ($6+$7>0&&$11>0&&$9==0&&$10==0)print $1,$2,$3,$4,$5}' |sort -u> ${LINE}_${THRE}_CEE_gene.bed
cat ${LINE}_${THRE}_promoter_partner_sig_merged_ENCODE.bed| awk 'BEGIN{OFS="\t"}{if ($6+$7>0&&$11>0&&$9==0&&$10==0)print $1,$2,$3,$4,$5}' |sort -u> ${LINE}_${THRE}_CEE_gene_sig.bed

else   #$USESEG==1 
$BEDTOOLS intersect -a ${LINE}_${THRE}_partnerTogene_merged.bed -b ${BROAD_PATH}/${CELL}CombSegEnh.gz -wa -u > ${LINE}_${THRE}_CEE_gene.bed
$BEDTOOLS intersect -a ${LINE}_${THRE}_partnerTogene_sig_merged.bed -b ${BROAD_PATH}/${CELL}CombSegEnh.gz -wa -u > ${LINE}_${THRE}_CEE_gene_sig.bed


fi

EXITSTATUS=$?

if [ !  -s "${LINE}_${THRE}_CEE_gene_sig.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS


# Final CEE-target
#join -t $'\t' -j1 1-3 -j2 1-3 -o 1.1 1.2 1.3 2.4 2.5 2.6 ${LINE}_${THRE}_CEE.bed ${LINE}_${THRE}_partner_gene.bed > ${LINE}_${THRE}_enhancer_gene.bed

#20130318 comment out the plot heatmap script
#R --no-save <plot_partner_ENCODE_heatmap.R

