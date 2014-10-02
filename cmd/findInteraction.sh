#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

FILE=$1
LINE=$2

if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi


echo "[`date`] start finding intra-chromosomal interaction"
awk -F'\t' '{print > $1"_S_reads.bed"}' ${FILE}

#ignore non-classic chromosomes
rm chr*_*_S_reads.bed
rm chr*_*_random_S_reads.bed



foo=( chr[[:digit:]]_S_reads.bed chr[[:digit:]][[:digit:]]_S_reads.bed chrX_S_reads.bed chrY_S_reads.bed)

for i in "${!foo[@]}"; do 
	filename="${foo[$i]%.*}" 
	"${ETSCRIPT}/interaction.pl" "${foo[$i]}" "${filename}_S_interaction.txt"
done;


echo "[`date`] start finding inter-chromosomal interaction"
a=${#foo[@]}
lastIndex=`expr $a - 1`
for ((i=$lastIndex; i> 0;i--)); do 
	lastIndexy=`expr $i - 1`
	for (( j=$lastIndexy; j >= 0 ; j--)); do
		echo "[`date`] finding inter-chromosomal restriction fragment interactions between ${foo[$i]} and ${foo[$j]}"
		"${ETSCRIPT}/interaction_interChrm.pl" "${foo[$i]}" "${foo[$j]}" "${LINE}_interChrm_S_interaction.txt"
	done
done

echo "[`date`] find restriction fragment interactions completed"



EXITSTATUS=$?

if [ !  -s "${LINE}_interChrm_S_interaction.txt" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

