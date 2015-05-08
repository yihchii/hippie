#!/bin/bash

source "./setup.ini"

export REF_FASTA=$1

${STAR} \
  --runThreadN 1 \
  --genomeDir ${REF_FASTA} \
  --genomeLoad Remove \
  --outFileNamePrefix "${PWD}/rmStarGenome"


