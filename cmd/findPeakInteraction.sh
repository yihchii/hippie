#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
RE=$2
THRE=$3

FILE="${LINE}_${RE}fragment_S_reads_${THRE}.bed"

if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi

# split peak fragment files into chromosomal level
echo "[`date`] start finding intra-chromosomal interaction"
awk -v thre=${THRE} -F'\t' 'BEGIN{OFS="\t"}{print $1,$2,$3,$4,$5> $1"_"thre"_reads.bed"}' ${FILE}

# array of the peak fragment files (in chromosomes)
foo=( chr[[:digit:]]_${THRE}_reads.bed chr[[:digit:]][[:digit:]]_${THRE}_reads.bed chrX_${THRE}_reads.bed chrY_${THRE}_reads.bed)

# for each chromosome, find interactions
for i in "${!foo[@]}"; do 
	filename="${foo[$i]%.*}" 
	"${ETSCRIPT}/interaction.pl" "${foo[$i]}" "${filename}_interaction.txt"
done;


echo "[`date`] start finding inter-chromosomal interaction"
rm "${LINE}_interChrm_${THRE}_reads_interaction.txt"
a=${#foo[@]}
lastIndex=`expr $a - 1`
for ((i=$lastIndex; i> 0;i--)); do 
	lastIndexy=`expr $i - 1`
	for (( j=$lastIndexy; j >= 0 ; j--)); do
		echo "[`date`] finding inter-chromosomal restriction fragment interactions between ${foo[$i]} and ${foo[$j]}"
		"${ETSCRIPT}/interaction_interChrm.pl" "${foo[$i]}" "${foo[$j]}" "${LINE}_interChrm_${THRE}_reads_interaction.txt"
	done
done

echo "[`date`] find peak fragment interactions completed"



EXITSTATUS=$?

if [ !  -s "${LINE}_interChrm_${THRE}_reads_interaction.txt" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

