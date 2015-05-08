#!/bin/bash
#######################################################
# This is a pipeline to calculate gc content, mappability of the restriction fragment for Hi-C experiments.
# It generates the characteristics file for HIPIIE to correct possible Hi-C biases
# Created on 2015/05/05 by: Yih-Chii Hwang <yihhwang@upenn.edu>
#######################################################

# Please (1) set the parameters for your Hi-C experiment, and (2) the path for STAR and BEDTools in the following file
source "./setup.ini"


#######################################################
# settings for qsub (open grid scheduler)
export GRID_QUEUE="all.q"
mkdir -p "${HOME}/stdout"
export STDOUT="${HOME}/stdout"
export QSUBARGS="-S /bin/bash -q $GRID_QUEUE -cwd -j y -o $STDOUT -l h_stack=256m,h_vmem=1G"
#######################################################

mkdir -p out
export OUT=${PWD}/out

#######################################################
# The pipeline execution starts here
# A. generate the fragment file
qsub -N get_fragment $QSUBARGS -l h_vmem=3G get_fragment.sh $RESite $RE $fastaDir $OUT

# B. calculate the gc content
qsub -N calculate_gc -hold_jid get_fragment $QSUBARGS -l h_vmem=1G calculate_gc.sh $RE $sizeSelect $fastaDir $OUT

# C. for each chromosome, calculate the mappability with 3 steps:
# i. getSeq.sh:
#    generate the reads with the sliding windows with size of read length, and spreading the size selection range
# ii. starMappingforMappability.sh:
#     map the reads using STAR
# iii. getMapp.sh
#      parse the mapped bam file and calculate the mappability for each fragment
fastaFiles=$(ls -d1 -v $fastaDir/*|xargs -n1 basename|grep "chr[A-LN-Z0-9]\{1,2\}.fa$")
for i in ${fastaFiles[*]}; do
  export chrm=`echo $i|sed "s/\(.*\).fa/\1/"`
	# extract 36 nt windows sequence fastq file 
	qsub -N getSeq_${chrm} -hold_jid get_fragment $QSUBARGS -pe DJ 4 -l h_vmem=3G ./getSeq.sh $RE $sizeSelect $readLength $fastaDir $chrm ${OUT}
	# map the sliding windows toward the genome using STAR
	qsub -N mapping_${chrm} -hold_jid getSeq_${chrm} $QSUBARGS -pe DJ 1 -l h_vmem=30G ./starMappingforMappability.sh $REF_FASTA ${OUT}/${RE}_${chrm}_Flanking${sizeSelect}_${readLength}nt_reads.fastq.gz ${OUT};
	# calculate mappability (uniqness)
	qsub -N getMapp_${chrm} -hold_jid mapping_${chrm} $QSUBARGS -pe DJ 2 -l h_vmem=1G ./getMapp.sh $RE $sizeSelect $readLength $fastaDir $chrm $OUT;
done;

	# remove the genome in the shared memory after mapping is done
	qsub -N rmStarGenome -hold_jid "mapping_*"  $QSUBARGS -pe DJ 1 -l h_vmem=30G ./rmStarGenome.sh $REF_FASTA

# D. merge mappability conent from all chromosomes to one file
qsub -N merge_gc_mapp -hold_jid "getMapp_*",calculate_gc $QSUBARGS -l h_vmem=1G merge_gc_mapp.sh $RE $sizeSelect $readLength ${RE}_fragments.bed ${OUT}

