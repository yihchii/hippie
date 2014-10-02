#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1

if [ -e "${LINE}_NS_intra_reads.txt" ]
then 
	echo "${LINE}_NS_intra_reads.txt exists! Please remove it before finding interaction reads"
	exit 100
fi

if [ -e "${LINE}_NS_inter_reads.txt" ]
then 
	echo "${LINE}_NS_inter_reads.txt exists! Please remove it before finding interaction reads"
	exit 100
fi

if [ ! -s "${LINE}_interChrm_NS_interaction.txt" ]
then 
	echo "Cannot find inputfile ${LINE}_interChrm_NS_interaction.txt!"
	exit 100
fi

echo "[`date`] start finding intra-chromosomal interaction reads"
foo=( chr[[:digit:]]_NS_reads_NS_interaction.txt chr[[:digit:]][[:digit:]]_NS_reads_NS_interaction.txt chrX_NS_reads_NS_interaction.txt chrY_NS_reads_NS_interaction.txt)

for i in "${!foo[@]}"; do 
	if [ !  -s "${foo[$i]}" ]
	then
 		echo "Cannot find input file ${foo[$i]}!"
 		exit 100
	fi
	filename="${foo[$i]%.*}" 
	cut -f 3,4,5 "${foo[$i]}" >> ${LINE}_NS_intra_reads.txt
done;


echo "[`date`] start finding inter-chromosomal interaction reads"
cut -f 3,5,5 "${LINE}_interChrm_NS_interaction.txt" > ${LINE}_NS_inter_reads.txt

echo "[`date`] find eHotpsot interaction read completed"


#echo "[`date`] plot interaction reads"
#R --no-save --args "${LINE}_NS_intra_reads" < "${ETSCRIPT}/plot_num_inter.R"
#R --no-save --args "${LINE}_NS_inter_reads" < "${ETSCRIPT}/plot_num_inter.R"


EXITSTATUS=$?

if [ !  -s "${LINE}_NS_inter_reads.pdf" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

