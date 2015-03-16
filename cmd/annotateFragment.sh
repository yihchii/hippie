#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
RE=$2
THRE=$3
FILE="${RE}_fragment_S_reads_${THRE}_simple.bed"
if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi

echo "[`date`] annotating the hotspots"

# 20140706 update intergenic definition: (intergenic.bed) not promoter, not gene region
# A. annotate genetics features: 
# 8promoter, 9gene, 10exon, 11intron, 12miRNA, 13pseudogene, 14rnaRepeats, 15TE, 16TR, 17intergenetic
$BEDTOOLS annotate -i "${FILE}" -files "${GENOME_PATH}/refGene_promoter_merged.bed" "${GENOME_PATH}/refGene_merged.bed" "${GENOME_PATH}/refGene_exon_merged.bed" "${GENOME_PATH}/refGene_intron_merged.bed" "${GENOME_PATH}/miRNA_merged.bed" "${GENOME_PATH}/vegaPseudoGene_merged.bed" "${GENOME_PATH}/RNA_repeats_rmsk_merged.bed" "${GENOME_PATH}/TE_rmsk_merged.bed" "${GENOME_PATH}/TR_rmsk_merged.bed" "${GENOME_PATH}/intergenic.bed" > "${LINE}_${RE}fragment_${THRE}_annotated.bed"

# A.1 sort the annoated file
sort -T $TMPDIR -k 1,1 -k 2,2n "${LINE}_${RE}fragment_${THRE}_annotated.bed" > "${LINE}_${RE}fragment_${THRE}_annotated_sorted.bed"

# B. also annoate promoter gene symbol on "simple" file ## file is sorted
# 1chr 2start 3end 4geneSymbol
$BEDTOOLS intersect -a "${FILE}" -b "${GENOME_PATH}/refGene_promoter_merged.bed" -wb -loj|awk '{printf ("%s\t%s\t%s\t%s=%s:%s-%s\n",$1,$2,$3,$11,$8,$9,$10)}'|$BEDTOOLS merge -delim "," -c 4 -o collapse -i stdin > "${LINE}_${RE}fragment_${THRE}_promoter_symbol.bed"

# 1. paste promoter annotation with interaction information ==> for find promoter interaction
# 2. find the gene for that promoter 
# column number: annotated_sorted.bed(17):fragment_S_reads_${THRE}.bed(8):promoter_symbol(4)
# 1chr, 2start, 3end, 4readName, 5read, 6length, 7ave_read, 8pvalue, 9promoter, 10genesym
paste "${LINE}_${RE}fragment_${THRE}_annotated_sorted.bed" "${LINE}_${RE}fragment_S_reads_${THRE}.bed" "${LINE}_${RE}fragment_${THRE}_promoter_symbol.bed"| awk 'BEGIN{OFS="\t"}{print $1,$2,$3,$21,$4,$5,$6,$7,$8,$29}' > "${LINE}_${RE}fragment_${THRE}_promoter_annotated.bed"

if [ !  -s "${LINE}_${RE}fragment_${THRE}_promoter_symbol.bed" ]
then
 echo "Incorrect Output: file ${LINE}_${RE}fragment_${THRE}_promoter_symbol.bed not generated"
 exit 100
fi

# calculate annoated features length
awk 'function round(A) {return int( A + 0.5 )}BEGIN{intergenic=0}{len = $3-$2;
promoter+=round(len*$8);
gene+=round(len*$9);
exon+=round(len*$10);
intron+=round(len*$11);
miRNA+=round(len*$12);
pseudogene+=round(len*$13);
RNAR+=round(len*$14);
TE+=round(len*$15);
TR+=round(len*$16);
intergenic+=round(len*$17);}
END{printf ("RefSeq-promoter\t%d\nRefSeq-gene\t%d\nRefSeq-exon\t%d\nRefSeq-intron\t%d\nmiRNA\t%d\npseudogene\t%d\nRNA-repeats\t%d\nTE\t%d\nTR\t%d\nintergenic\t%d\n",promoter,gene,exon,intron,miRNA,pseudogene,RNAR,TE,TR, intergenic)}' "${LINE}_${RE}fragment_${THRE}_annotated_sorted.bed" > "${LINE}_${RE}fragment_${THRE}_annotated_length.txt"


"${ETSCRIPT}/get_annotation_length.pl" "${CLASS_LENGTH}" "${LINE}_${RE}fragment_${THRE}_annotated_length.txt" "${LINE}_${RE}fragment_${THRE}_class_percentage.txt"


$RPATH/R --no-save --args "${LINE}_${RE}fragment_${THRE}_class_percentage" < "${ETSCRIPT}/plot_percentage_annotation.R"

TOTALLENGTH=`awk 'BEGIN{sum=0}{sum+=$3-$2}END{print sum}' "${LINE}_${RE}fragment_${THRE}_annotated_sorted.bed"`
$RPATH/R --no-save --args "${LINE}_${RE}fragment_${THRE}_annotated_length" $TOTALLENGTH < "${ETSCRIPT}/plot_hotspot_ratio_annotation.R"

EXITSTATUS=$?

if [ !  -s "${LINE}_${RE}fragment_${THRE}_annotated_length_ratio.pdf" ]
then
 echo "Incorrect Output!"
 exit 100
fi


exit $EXITSTATUS

