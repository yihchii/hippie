#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
RE=$2
THRE=$3

FILE="${LINE}_${RE}fragment_${THRE}_promoter_annotated.bed"

if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi

echo "[`date`] split promoter_annotated to chromosomes "

awk -F'\t' -v thre="${THRE}" '{print > $1"_"thre"_promoter_annotated.bed"}' ${FILE}

echo "[`date`] start finding intra-chromosomal interaction"

foo=( chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY)
#foo=( chr[[:digit:]]_${THRE}_promoter_annotated.bed chr[[:digit:]][[:digit:]]_${THRE}_promoter_annotated.bed chrX_${THRE}_promoter_annotated.bed chrY_${THRE}_promoter_annotated.bed)

for i in "${!foo[@]}"; do
#	filename="${foo[$i]%.*}" 
	echo "Find promoter interaction for ${foo[$i]}"
  # 2014/01/28:
  # edit promoterInteractionP7.pl to keep only promoter involved interations 
  # skip promoterAnno, directly get promoterInteractions
	"${ETSCRIPT}/promoterInteractionP7.pl" "${foo[$i]}_${THRE}_promoter_annotated.bed" "${foo[$i]}_${THRE}_promoter_annotated_promoterInteraction.txt"
	# 2014/09/21: add in p-values for promoter interactions
	#chr1:90823274-90826629  chr1:115320768-115324428        1       294     0.588   0.005   0.000000        .=.:-1--1       434     0.868   0.003   0.136612        SIKE1=chr1:115323308-115323808
	# chr1:242249728-242252819        chr1:242598834-242604813        0.312894373569298       1       288     356

	awk 'BEGIN{OFS="\t"}NR==FNR{a[$1,$2]=$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13;next}{if(($1,$2) in a) print $1,$2,$3,a[$1,$2]}' "${foo[$i]}_${THRE}_promoter_annotated_promoterInteraction.txt" "${foo[$i]}_${THRE}_reads_interaction_pvalue.txt" >  "${foo[$i]}_${THRE}_promoter_annotated_promoterInteraction_pvalue.txt"
	
done;


echo "[`date`] start finding inter-chromosomal interaction"
echo "[`date`] remove ${LINE}_${THRE}_interChrm_promoterInteraction.txt if it exists"
rm ${LINE}_${THRE}_interChrm_promoterInteraction.txt
 
a=${#foo[@]}
lastIndex=`expr $a - 1`
for ((i=$lastIndex; i> 0;i--)); do 
	lastIndexy=`expr $i - 1`
	for (( j=$lastIndexy; j >= 0 ; j--)); do
		echo "[`date`] finding inter-chromosomal gragment interactions between ${foo[$i]} and ${foo[$j]}"
		"${ETSCRIPT}/promoterInteraction_interChrmP7.pl" "${foo[$i]}_${THRE}_promoter_annotated.bed" "${foo[$j]}_${THRE}_promoter_annotated.bed" "${LINE}_${THRE}_interChrm_promoterInteraction.txt"
	done
done

awk 'BEGIN{OFS="\t"}NR==FNR{a[$1,$2]=$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13;next}{if(($1,$2) in a) print $1,$2,$3,a[$1,$2]}' "${LINE}_${THRE}_interChrm_promoterInteraction.txt" "${LINE}_interChrm_${THRE}_reads_interaction_pvalue.txt" >  "${LINE}_${THRE}_interChrm_promoterInteraction_pvalue.txt"


echo "[`date`] find fragment interactions completed"


EXITSTATUS=$?

if [ !  -s "${LINE}_${THRE}_interChrm_promoterInteraction.txt" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

