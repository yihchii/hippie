#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

BED_DIR=$1
LINE=$2
RE=$3
THRE=$4

FILE="${BED_DIR}/${LINE}_${RE}fragment_${THRE}_promoter_annotated.bed"

if [ !  -s "${FILE}" ]
then
	echo "Cannot find input file $FILE!"
	exit 100
fi

echo "[`date`] split promoter_annotated to chromosomes "

awk -v thre=${THRE} -v beddir=${BED_DIR} -F'\t' 'BEGIN{OFS="\t"}{print > beddir"/"$1"_"thre"_promoter_annotated.bed"}' ${FILE}


echo "[`date`] start finding intra-chromosomal interaction"


cd ${BED_DIR};
for x in `\ls`; do
	if [[ $x =~ ^([A-Za-z0-9]+)_${THRE}_promoter_annotated.bed ]]; then
		export chrm=${BASH_REMATCH[1]}
		echo "Find promoter interaction for ${chrm}"
		"${ETSCRIPT}/promoterInteractionP7.pl" "${BED_DIR}/${x}" "${BED_DIR}/${chrm}_${THRE}_promoter_annotated_promoterInteraction.txt"
		awk 'BEGIN{OFS="\t"}NR==FNR{a[$1,$2]=$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13;next}{if(($1,$2) in a) print $1,$2,$3,a[$1,$2]}' "${BED_DIR}/${chrm}_${THRE}_promoter_annotated_promoterInteraction.txt" "${BED_DIR}/${chrm}_${THRE}_reads_interaction_pvalue.txt" >  "${BED_DIR}/${chrm}_${THRE}_promoter_annotated_promoterInteraction_pvalue.txt"
	fi;
done
cd -


echo "[`date`] start finding inter-chromosomal interaction"
echo "[`date`] remove ${LINE}_${THRE}_interChrm_promoterInteraction.txt if it exists"
rm ${BED_DIR}/${LINE}_${THRE}_interChrm_promoterInteraction.txt


files=($(ls ${BED_DIR}/chr*_${THRE}_promoter_annotated.bed))
a=${#files[@]}
lastIndex=`expr $a - 1`
for ((i=$lastIndex; i> 0;i--)); do 
	lastIndexy=`expr $i - 1`
	for (( j=$lastIndexy; j >= 0 ; j--)); do
		echo "[`date`] finding inter-chromosomal gragment interactions between ${files[$i]} and ${files[$j]}"
		"${ETSCRIPT}/promoterInteraction_interChrmP7.pl" "${files[$i]}" "${files[$j]}" "${BED_DIR}/${LINE}_${THRE}_interChrm_promoterInteraction.txt"
	done
done

awk 'BEGIN{OFS="\t"}NR==FNR{a[$1,$2]=$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13;next}{if(($1,$2) in a) print $1,$2,$3,a[$1,$2]}' "${BED_DIR}/${LINE}_${THRE}_interChrm_promoterInteraction.txt" "${BED_DIR}/${LINE}_interChrm_${THRE}_reads_interaction_pvalue.txt" >  "${BED_DIR}/${LINE}_${THRE}_interChrm_promoterInteraction_pvalue.txt"


echo "[`date`] find fragment interactions completed"


EXITSTATUS=$?

if [ !  -s "${BED_DIR}/${LINE}_${THRE}_interChrm_promoterInteraction.txt" ]
then
	echo "Incorrect Output!"
	exit 100
fi

exit $EXITSTATUS

