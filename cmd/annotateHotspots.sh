#!/bin/bash
source $HIPPIE_INI
source $HIPPIE_CFG

LINE=$1
FILE="${LINE}_eHotspots.bed"


if [ !  -s "${FILE}" ]
then
 echo "Cannot find input file $FILE!"
 exit 100
fi

echo "[`date`] annotating the hotspots"

awk -F'\t' '{print > $1"_eHotspots.bed"}' ${FILE}

for i in chr*_eHotspots.bed; do bedtools annotate -i "${i}" -files "${GENOME_PATH}/refGene_promoter_merged.bed" "${GENOME_PATH}/refGene_merged.bed" "${GENOME_PATH}/refGene_exon_merged.bed" "${GENOME_PATH}/refGene_intron_merged.bed" "${GENOME_PATH}/miRNA_merged.bed" "${GENOME_PATH}/vegaPseudoGene_merged.bed" "${GENOME_PATH}/RNA_repeats_rmsk_merged.bed" "${GENOME_PATH}/TE_rmsk_merged.bed" "${GENOME_PATH}/TR_rmsk_merged.bed" "${GENOME_PATH}/intergenic.bed" > "${i%%.*}_annotated.bed";done;

sort -T $TMPDIR -k 1,1 -k 2,2n  chr*_eHotspots_annotated.bed > "${LINE}_eHotspots_annotated.bed"

awk 'function round(A) {return int( A + 0.5 )}BEGIN{intergenic=0}{len = $3-$2;
promoter+=round(len*$6);
gene+=round(len*$7);
exon+=round(len*$8);
intron+=round(len*$9);
miRNA+=round(len*$10);
pseudogene+=round(len*$11);
RNAR+=round(len*$12);
TE+=round(len*$13);
TR+=round(len*$14);
intergenic+=round(len*$15);}
END{printf ("RefSeq-promoter\t%d\nRefSeq-gene\t%d\nRefSeq-exon\t%d\nRefSeq-intron\t%d\nmiRNA\t%d\npseudogene\t%d\nRNA-repeats\t%d\nTE\t%d\nTR\t%d\nintergenic\t%d\n",promoter,gene,exon,intron,miRNA,pseudogene,RNAR,TE,TR, intergenic)}' "${LINE}_eHotspots_annotated.bed" > "${LINE}_eHotspots_annotated_length.txt"


"${ETSCRIPT}/get_annotation_length.pl" "${CLASS_LENGTH}" "${LINE}_eHotspots_annotated_length.txt" "${LINE}_eHotspots_class_percentage.txt"


R --no-save --args "${LINE}_eHotspots_class_percentage" < "${ETSCRIPT}/plot_percentage_annotation.R"

TOTALLENGTH=`awk 'BEGIN{sum=0}{sum+=$3-$2}END{print sum}' "${LINE}_eHotspots_annotated.bed"`
R --no-save --args "${LINE}_eHotspots_annotated_length" $TOTALLENGTH < "${ETSCRIPT}/plot_hotspot_ratio_annotation.R"

EXITSTATUS=$?

if [ !  -s "${LINE}_eHotspots_class_percentage.pdf" ]
then
 echo "Incorrect Output!"
 exit 100
fi

exit $EXITSTATUS

