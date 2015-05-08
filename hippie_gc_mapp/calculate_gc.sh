#!/bin/bash


source "./setup.ini"

export RE=$1
export sizeSelect=$2
export fastaDir=$3
export OUT=$4

# for each chromosome, calculate the gc content using bedtool
for i in $(ls -v ${OUT}/*_${RE}_fragments.bed|xargs -n1 basename); do
	chrm=`echo $i|sed "s/\(.*\)_${RE}_fragments.bed/\1/"`
	awk -v sizeSelect=${sizeSelect} 'BEGIN{OFS="\t"}{if ($3-$2 <= sizeSelect) print $0,$0; else{print $1,$2,$2+sizeSelect/2,$0;print $1,$3-sizeSelect/2,$3,$0}}' ${OUT}/${chrm}_${RE}_fragments.bed | $BEDTOOLS nuc -fi ${fastaDir}/${chrm}.fa -bed -|cut -f 1-6,8|tail -n+2|awk 'BEGIN{OFS="\t";prekey="";pregc=0}{if($4"\t"$5"\t"$6==prekey) {a[$4"\t"$5"\t"$6]=($7+pregc)/2; } else {a[$4"\t"$5"\t"$6]=$7 ;}  prekey=$4"\t"$5"\t"$6;pregc=$7;}END{for (x in a)print x,a[x]}'|sort -k1,1 -k2,2n> ${OUT}/${RE}_${chrm}_sizeSelect${sizeSelect}_gc.bed
done;

# merge gc conent from all chromosomes to one file
cat $(ls -tr ${OUT}/${RE}_*_sizeSelect${sizeSelect}_gc.bed) > ${OUT}/${RE}_sizeSelect${sizeSelect}_gc.bed


