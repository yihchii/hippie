#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
CELL=$2


cat *_promoterInteraction.txt|awk '{if($3>1)print}' |awk '{ if ($6>0) print $2;else if($7>0) print $1;}'|tr - :|cut -d\: -f1,2,3 --output-delimiter='	'|sort -u|sort -k1,1 -k2,2n >  ${LINE}_promoter_partner_strong.bed
cat *_promoterInteraction.txt|awk '{ if ($6>0) print $2;else if($7>0) print $1;}'|tr - :|cut -d\: -f1,2,3 --output-delimiter='	'|sort -u|sort -k1,1 -k2,2n >  ${LINE}_promoter_partner.bed


$BEDTOOLS annotate -i ${LINE}_promoter_partner.bed -files $BROAD_PATH/${CELL}H3k27ac.gz $BROAD_PATH/${CELL}H3k4me1.gz $BROAD_PATH/${CELL}H3k4me2.gz $BROAD_PATH/${CELL}H3k4me3.gz $BROAD_PATH/${CELL}H3k27me3.gz $DNASE_PATH/${CELL}DNase.gz $BROAD_PATH/${CELL}P300.gz $BROAD_PATH/${CELL}Ctcf.gz> ${LINE}_promoter_partner_ENCODE.bed

$BEDTOOLS annotate -i ${LINE}_promoter_partner_strong.bed -files $BROAD_PATH/${CELL}H3k27ac.gz $BROAD_PATH/${CELL}H3k4me1.gz $BROAD_PATH/${CELL}H3k4me2.gz $BROAD_PATH/${CELL}H3k4me3.gz $BROAD_PATH/${CELL}H3k27me3.gz $DNASE_PATH/${CELL}DNase.gz $BROAD_PATH/${CELL}P300.gz $BROAD_PATH/${CELL}Ctcf.gz > ${LINE}_promoter_partner_strong_ENCODE.bed
# 1-3: bed regions
# 4: ${CELL}H3k27ac
# 5: ${CELL}H3k4me1
# 6: ${CELL}H3k4me2
# 7: ${CELL}H3k4me3
# 8: ${CELL}H3k27me3
# 9: DNaseI
# 10: P300
# 11: Ctcf
#c("K27ac","K4me1","K4me2","K4me3","K27me3","DnaseI","p300","CTCF")


#wc -l  ${LINE}_promoter_partner_ENCODE.bed
#wc -l  ${LINE}_promoter_partner_strong_ENCODE.bed

#cat ${LINE}_promoter_partner_ENCODE.bed|awk 'BEGIN{sum=0}{sum+=$10}END{print sum/NR}'
#cat ${LINE}_promoter_partner_strong_ENCODE.bed|awk 'BEGIN{sum=0}{sum+=$10}END{print sum/NR}'
#0.2

#cat ${LINE}_promoter_partner_ENCODE.bed| awk '{if ($4+$5+$6+$7>0&&$9>0)print $10}'|awk 'BEGIN{sum=0}{sum+=$1}END{print sum/NR}'
#cat ${LINE}_promoter_partner_strong_ENCODE.bed| awk '{if ($4+$5+$6+$7>0&&$9>0)print $10}'|awk 'BEGIN{sum=0}{sum+=$1}END{print sum/NR}'
#0.4
cat ${LINE}_promoter_partner_ENCODE.bed| awk '{if ($4+$5+$6+$7>0&&$9>0)printf "%s\t%s\t%s\n",$1,$2,$3}' > ${LINE}_CEE.bed
cat ${LINE}_promoter_partner_strong_ENCODE.bed| awk '{if ($4+$5+$6+$7>0&&$9>0)printf "%s\t%s\t%s\n",$1,$2,$3}' > ${LINE}_CEE_strong.bed

#R --no-save <plot_partner_ENCODE_heatmap.R

