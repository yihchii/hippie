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
foo=( chr[[:digit:]]_eHotspots.bed chr[[:digit:]][[:digit:]]_eHotspots.bed chrX_eHotspots.bed chrY_eHotspots.bed)

for i in "${!foo[@]}"; do 
	filename="${foo[$i]%.*}" 
	"${ETSCRIPT}/interaction.pl" "${foo[$i]}" "${filename}_interaction.txt"
done;


echo "[`date`] start finding inter-chromosomal interaction"
a=${#foo[@]}
lastIndex=`expr $a - 1`
for ((i=$lastIndex; i> 0;i--)); do 
	lastIndexy=`expr $i - 1`
	for (( j=$lastIndexy; j >= 0 ; j--)); do
		echo "[`date`] finding inter-chromosomal eHotpsot interactions between ${foo[$i]} and ${foo[$j]}"
		"${ETSCRIPT}/interaction_interChrm.pl" "${foo[$i]}" "${foo[$j]}" "${LINE}_interChrm_interaction.txt"
	done
done

echo "[`date`] find eHotpsot interactions completed"



EXITSTATUS=$?

if [ !  -s "${LINE}_interChrm_interaction.txt" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

