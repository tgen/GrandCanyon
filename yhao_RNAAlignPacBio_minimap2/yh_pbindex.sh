#!/bin/bash

# Generate index for PacBio bam file

module load singularity

PBBAM="/home/tgenref/containers/grandcanyon/pacbio/pbbam_2.1.0--h8db2425_5.sif"


DIR=/scratch/yhao/grandcanyon/RNA_align_pacbio
#INPUT_DIR=DIR
#OUTPUT_DIR=DIR

INPUT=$1

singularity exec -B $PWD -B $DIR $PBBAM sh -c "pbindex ${INPUT}"
