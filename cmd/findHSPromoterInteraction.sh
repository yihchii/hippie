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
foo=( chr[[:digit:]]_eHotspots_annotated.bed chr[[:digit:]][[:digit:]]_eHotspots_annotated.bed chrX_eHotspots_annotated.bed chrY_eHotspots_annotated.bed)

for i in "${!foo[@]}"; do 
	filename="${foo[$i]%.*}" 
	"${ETSCRIPT}/promoterInteraction.pl" "${foo[$i]}" "${filename}_interaction_promoterAnno.txt"
	awk '{if ($6>0 || $7>0) print}' "${filename}_interaction_promoterAnno.txt" > "${filename}_promoterInteraction.txt"
done;


echo "[`date`] start finding inter-chromosomal interaction"
a=${#foo[@]}
lastIndex=`expr $a - 1`
for ((i=$lastIndex; i> 0;i--)); do 
	lastIndexy=`expr $i - 1`
	for (( j=$lastIndexy; j >= 0 ; j--)); do
		echo "[`date`] finding inter-chromosomal eHotpsot interactions between ${foo[$i]} and ${foo[$j]}"
		"${ETSCRIPT}/promoterInteraction_interChrm.pl" "${foo[$i]}" "${foo[$j]}" "${LINE}_interChrm_promoterInteraction.txt"
	done
done

echo "[`date`] find eHotpsot interactions completed"



EXITSTATUS=$?

if [ !  -s "${LINE}_interChrm_promoterInteraction.txt" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

