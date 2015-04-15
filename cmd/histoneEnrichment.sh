#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
CELL=$2
THRE=$3
BED_DIR=$4
OUT_DIR=$5

# 2014/09/21 update: using threshould of p-value estimated by NB distribution
# ${LINE}_${THRE}_promoter_partner_sig_ENCODE.bed
# 1-3: bed regions
# 4: target gene(s) in the same fragment
# 5: read support
# 6: ${CELL}H3k27ac
# 7: ${CELL}H3k4me1
# 8: ${CELL}H3k4me2
# 9: ${CELL}H3k4me3
# 10: ${CELL}H3k27me3
# 11: DNaseI
# 12: P300
# 13: Ctcf
#c("K27ac","K4me1","K4me2","K4me3","K27me3","DnaseI","p300","CTCF")

export OUT="${OUT_DIR}/histone_enrichment.txt"

echo -e "cond\tH3K27ac\tH3K4me1\tH3K4me2\tH3K4me3\tH3K27me3\tDNaseI\tP300\tCTCF" > ${OUT} 
# each line is unique for each promoter partner
cat ${OUT_DIR}/${LINE}_${THRE}_promoter_partner_merged_ENCODE.bed|awk 'BEGIN{OFS="\t";sum6=sum7=sum8=sum9=sum10=sum11=sum12=sum13=0}{sum6+=$6;sum7+=$7;sum8+=$8;sum9+=$9;sum10+=$10;sum11+=$11;sum12+=$12;sum13+=$13}END{print "pro_partner", sum6/NR,sum7/NR,sum8/NR,sum9/NR,sum10/NR,sum11/NR,sum12/NR,sum13/NR}' >> ${OUT}
cat ${OUT_DIR}/${LINE}_${THRE}_promoter_partner_sig_merged_ENCODE.bed|awk 'BEGIN{OFS="\t";sum6=sum7=sum8=sum9=sum10=sum11=sum12=sum13=0}{sum6+=$6;sum7+=$7;sum8+=$8;sum9+=$9;sum10+=$10;sum11+=$11;sum12+=$12;sum13+=$13}END{print "pro_partner_sig", sum6/NR,sum7/NR,sum8/NR,sum9/NR,sum10/NR,sum11/NR,sum12/NR,sum13/NR}' >> ${OUT}

# get all the interactors in Hi-C
rm ${OUT_DIR}/${LINE}_${THRE}_interactor.bed;
for i in ${BED_DIR}/*_${THRE}_reads_interaction_pvalue.txt; do awk 'BEGIN{OFS="\n"}{print $1, $2}' $i|sort -u|tr ":|-" "\t" >> ${OUT_DIR}/${LINE}_${THRE}_interactor.bed ;done;

sort -T $TMPDIR -u -k1,1 -k2,2n ${OUT_DIR}/${LINE}_${THRE}_interactor.bed > ${OUT_DIR}/${LINE}_${THRE}_interactor_sorted.bed

# get all the interactors that are shown interacting significantly
rm ${OUT_DIR}/${LINE}_${THRE}_sig_interactor.bed;
for i in ${BED_DIR}/*_${THRE}_reads_interaction_pvalue.txt; do awk 'BEGIN{OFS="\n"}{if($3<=0.1) print $1, $2}' $i|sort -u|tr ":|-" "\t" >> ${OUT_DIR}/${LINE}_${THRE}_sig_interactor.bed ;done;
sort -T $TMPDIR -u -k1,1 -k2,2n ${OUT_DIR}/${LINE}_${THRE}_sig_interactor.bed > ${OUT_DIR}/${LINE}_${THRE}_sig_interactor_sorted.bed


# annotate Hi-C interactor
$BEDTOOLS annotate -i ${OUT_DIR}/${LINE}_${THRE}_interactor_sorted.bed -files $BROAD_PATH/${CELL}H3k27ac.gz $BROAD_PATH/${CELL}H3k4me1.gz $BROAD_PATH/${CELL}H3k4me2.gz $BROAD_PATH/${CELL}H3k4me3.gz $BROAD_PATH/${CELL}H3k27me3.gz $DNASE_PATH/${CELL}DNase.gz $BROAD_PATH/${CELL}P300.gz $BROAD_PATH/${CELL}Ctcf.gz> ${OUT_DIR}/${LINE}_${THRE}_interactor_ENCODE.bed

# annotate significant Hi-C interactor
$BEDTOOLS annotate -i ${OUT_DIR}/${LINE}_${THRE}_sig_interactor_sorted.bed -files $BROAD_PATH/${CELL}H3k27ac.gz $BROAD_PATH/${CELL}H3k4me1.gz $BROAD_PATH/${CELL}H3k4me2.gz $BROAD_PATH/${CELL}H3k4me3.gz $BROAD_PATH/${CELL}H3k27me3.gz $DNASE_PATH/${CELL}DNase.gz $BROAD_PATH/${CELL}P300.gz $BROAD_PATH/${CELL}Ctcf.gz> ${OUT_DIR}/${LINE}_${THRE}_sig_interactor_ENCODE.bed


# ${LINE}_${THRE}_promoter_partner_sig_ENCODE.bed
# 1-3: bed regions
# 4: target gene(s) in the same fragment
# 5: read support
# 6: ${CELL}H3k27ac
# 7: ${CELL}H3k4me1
# 8: ${CELL}H3k4me2
# 9: ${CELL}H3k4me3
# 10: ${CELL}H3k27me3
# 11: DNaseI
# 12: P300
# 13: Ctcf
#c("K27ac","K4me1","K4me2","K4me3","K27me3","DnaseI","p300","CTCF")


awk 'FNR==NR {a[$1,$2]; next} !(($1,$2) in a)'  ${OUT_DIR}/${LINE}_${THRE}_promoter_partner_merged_ENCODE.bed ${OUT_DIR}/${LINE}_${THRE}_interactor_ENCODE.bed|sort -u|awk 'BEGIN{OFS="\t";sum4=sum5=sum6=sum7=sum8=sum9=sum10=sum11=0}{sum4+=$4;sum5+=$5;sum6+=$6;sum7+=$7;sum8+=$8;sum9+=$9;sum10+=$10;sum11+=$11}END{print "interactor",sum4/NR,sum5/NR,sum6/NR,sum7/NR,sum8/NR,sum9/NR,sum10/NR,sum11/NR}' >> ${OUT}
awk 'FNR==NR {a[$1,$2]; next} !(($1,$2) in a)' ${OUT_DIR}/${LINE}_${THRE}_promoter_partner_sig_merged_ENCODE.bed ${OUT_DIR}/${LINE}_${THRE}_sig_interactor_ENCODE.bed|sort -u|awk 'BEGIN{OFS="\t";sum4=sum5=sum6=sum7=sum8=sum9=sum10=sum11=0}{sum4+=$4;sum5+=$5;sum6+=$6;sum7+=$7;sum8+=$8;sum9+=$9;sum10+=$10;sum11+=$11}END{print "interactor_sig", sum4/NR,sum5/NR,sum6/NR,sum7/NR,sum8/NR,sum9/NR,sum10/NR,sum11/NR}' >> ${OUT}

EXITSTATUS=$?

rawNum=$(wc -l histone_enrichment.txt|cut -d" " -f1)
if [[ $rawNum != 5 ]] then
 echo "Incorrect Output!"
 exit 100
fi


exit $EXITSTATUS



