#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
READLENGTH=$2

ADDLENGTH=$(($READLENGTH -1))

#FILES=*summary.txt.gz
FILES=*summary.binned.txt.gz

#echo "[`date`] get uniq mapped pairs"
#	for file in ${FILES};do gzip -dc ${file}|sort -T ${TMPDIR} -u -k 1,1| gzip > "${file%%.*}_uniq.txt.gz";
#done;


echo "[`date`] get the mapping START sites and replace the read_ids to number_ids"

UNIQFILES=*_uniq.txt.gz


## Maq output is 1-based for left-end, convert it to 0-based
  gzip -dc ${UNIQFILES}| awk 'BEGIN{OFS="\t"}{print $2,$3-1,$3}'|awk 'BEGIN{OFS="\t"}{sub(/^/, "chr");sub(/chr0/,"chrM"); sub(/chr23/,"chrX"); sub(/chr24/,"chrY"); sub(/chr0/,"chrM"); print}' > "${LINE}_left_temp1.bed"
#	gzip -dc ${UNIQFILES}| awk 'BEGIN{OFS="\t"}{print $5,$6,$6+1}' > "${LINE}_right_temp1.bed"
	gzip -dc ${UNIQFILES}| awk 'BEGIN{OFS="\t"}{print $6,$7-1,$7}'|awk 'BEGIN{OFS="\t"}{sub(/^/, "chr");sub(/chr0/,"chrM"); sub(/chr23/,"chrX"); sub(/chr24/,"chrY"); sub(/chr0/,"chrM"); print}' > "${LINE}_right_temp1.bed"
#	gzip -dc ${UNIQFILES}| awk -v "line=${LINE}" 'BEGIN{count=0}{count+=1;printf ("%s%s\t%s\t%s\t%s\n",line,count,$1,$4,$7)}' > "${LINE}_read_dictionary.txt"
	gzip -dc ${UNIQFILES}| awk -v "line=${LINE}" 'BEGIN{count=0}{count+=1;printf ("%s%s\t%s\t%s\t%s\n",line,count,$1,$3,$6)}' > "${LINE}_read_dictionary.txt"
#	gzip -dc ${UNIQFILES}| awk -v "line=${LINE}" 'BEGIN{count=0}{count+=1;printf ("%s%s\t%s\t%s\n",line,count,$4,$7)}' > "${LINE}_read_strands.txt"
	gzip -dc ${UNIQFILES}| awk -v "line=${LINE}" 'BEGIN{count=0}{count+=1;printf ("%s%s\t%s\t%s\n",line,count,$4,$8)}' > "${LINE}_read_strands.txt"

echo "[`date`]get the mapping END sites and generate the bed format of pair reads"

	bedtools slop -i "${LINE}_left_temp1.bed" -g "${GENOME_LEN}" -r "${ADDLENGTH}" -l 0 > "${LINE}_left_temp2.bed"
	bedtools slop -i "${LINE}_right_temp1.bed" -g "${GENOME_LEN}" -r "${ADDLENGTH}" -l 0 > "${LINE}_right_temp2.bed"

	paste "${LINE}_left_temp2.bed" "${LINE}_right_temp2.bed" "${LINE}_read_strands.txt" > s_${LINE}.bed

EXITSTATUS=$?

if [ !  -s "s_${LINE}.bed" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS
