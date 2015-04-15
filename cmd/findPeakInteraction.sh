#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

BED_DIR=$1
LINE=$2
RE=$3
THRE=$4

FILE="${BED_DIR}/${LINE}_${RE}fragment_S_reads_${THRE}.bed"

if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi

# split peak fragment files into chromosomal level
echo "[`date`] start finding intra-chromosomal interaction"
awk -v thre=${THRE} -v beddir=${BED_DIR} -F'\t' 'BEGIN{OFS="\t"}{print $1,$2,$3,$4,$5 > beddir"/"$1"_"thre"_reads.bed"}' ${FILE}

# for each chromosome, find interactions
for i in ${BED_DIR}/*_${THRE}_reads.bed; do
	FILE="${i}"
	FILEpref=${FILE%.*}
	if [ -s "${FILE}" ]
	then
	"${ETSCRIPT}/interaction.pl" "${FILE}" "${FILEpref}_interaction.txt"
	fi
done;

echo "[`date`] start finding inter-chromosomal interaction"
rm "${BED_DIR}/${LINE}_interChrm_${THRE}_reads_interaction.txt"

files=($(ls ${BED_DIR}/*_${THRE}_reads.bed))
a=${#files[@]}
lastIndex=`expr $a - 1`

for ((i=$lastIndex; i> 0;i--)); do 
	lastIndexy=`expr $i - 1`
	for (( j=$lastIndexy; j >= 0 ; j--)); do
		echo "[`date`] finding inter-chromosomal restriction fragment interactions between ${files[$i]} and ${files[$j]}"
		"${ETSCRIPT}/interaction_interChrm.pl" "${files[$i]}" "${files[$j]}" "${BED_DIR}/${LINE}_interChrm_${THRE}_reads_interaction.txt"
	done
done

echo "[`date`] find peak fragment interactions completed"



EXITSTATUS=$?

if [ !  -s "${BED_DIR}/${LINE}_interChrm_${THRE}_reads_interaction.txt" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

