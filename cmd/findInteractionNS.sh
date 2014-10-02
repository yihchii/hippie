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
awk -F'\t' '{print > $1"_NS_reads.bed"}' ${FILE}

#ignore non-classic chromosomes
rm chr*_*_NS_reads.bed
rm chr*_*_random_NS_reads.bed

foo=( chr[[:digit:]]_NS_reads.bed chr[[:digit:]][[:digit:]]_NS_reads.bed chrX_NS_reads.bed chrY_NS_reads.bed)

for i in "${!foo[@]}"; do 
	filename="${foo[$i]%.*}" 
	"${ETSCRIPT}/interaction.pl" "${foo[$i]}" "${filename}_NS_interaction.txt"
done;


echo "[`date`] start finding inter-chromosomal interaction"
a=${#foo[@]}
lastIndex=`expr $a - 1`
for ((i=$lastIndex; i> 0;i--)); do 
	lastIndexy=`expr $i - 1`
	for (( j=$lastIndexy; j >= 0 ; j--)); do
		echo "[`date`] finding inter-chromosomal eHotpsot interactions between ${foo[$i]} and ${foo[$j]}"
		"${ETSCRIPT}/interaction_interChrm.pl" "${foo[$i]}" "${foo[$j]}" "${LINE}_interChrm_NS_interaction.txt"
	done
done

echo "[`date`] find eHotpsot interactions completed"



EXITSTATUS=$?

if [ !  -s "${LINE}_interChrm_NS_interaction.txt" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

