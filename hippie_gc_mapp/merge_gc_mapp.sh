
RE=$1
sizeSelect=$2
readLength=$3
RF=$4
OUT=$5

# merge the mappability files from all chromosomes to one file
cat $(ls -v ${OUT}/${RE}_*_sizeSelect${sizeSelect}_${readLength}nt_mappability.bed) > ${OUT}/${RE}_sizeSelect${sizeSelect}_${readLength}nt_mappability.bed

# merge the gc content file with the full restriction fragemnt file
awk 'BEGIN{OFS="\t"}FNR==NR{a[$1"\t"$2"\t"$3]=$4;next;}{if ($1"\t"$2"\t"$3 in a)print $1,$2,$3,a[$1"\t"$2"\t"$3];else print $1,$2,$3,0}' ${OUT}/${RE}_sizeSelect${sizeSelect}_gc.bed ${RF} > ${OUT}/${RE}_fragments_gc.bed

# merge the gc content file with the mappability file and report the length information
awk 'BEGIN{OFS="\t"}FNR==NR{a[$1"\t"$2"\t"$3]=$4;next;}{if ($1"\t"$2"\t"$3 in a)print $1,$2,$3,$4,a[$1"\t"$2"\t"$3],log($3-$2);else print $1,$2,$3,$4,0,log($3-$2)}' ${OUT}/${RE}_sizeSelect${sizeSelect}_${readLength}nt_mappability.bed ${OUT}/${RE}_fragments_gc.bed > ${RE}_fragment_GC_MAPP_LEN.bed


