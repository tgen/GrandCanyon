#!/bin/bash

# Convert PacBio bam file to fastq format

module load singularity

PBTK="/home/tgenref/containers/grandcanyon/pacbio/pbtk_3.1.0--h9ee0642_0.sif"


DIR=/scratch/yhao/grandcanyon/RNA_align_pacbio

#bam input
INPUT=$1
#fastq.gz output
OUTPUT=${INPUT%.bam}

singularity exec -B $PWD -B $DIR $PBTK sh -c "bam2fastq -o ${OUTPUT} ${INPUT} "


