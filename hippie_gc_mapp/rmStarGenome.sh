#!/bin/bash

source "./setup.ini"

export REF_FASTA=$1

${STAR} \
  --runThreadN 1 \
  --genomeDir ${REF_FASTA} \
  --genomeLoad Remove \
  --outFileNamePrefix "${PWD}/rmStarGenome"

rm rmStarGenomeLog.progress.out
rm rmStarGenomeAligned.out.sam
rm rmStarGenomeLog.out
rm -rf rmStarGenome_STARtmp
