#!/bin/bash

# Map long mRNA/cDNA reads with minimap2

module load singularity

MINIMAP2="/home/tgenref/containers/grandcanyon/alignment/minimap2_2.26--he4a0461_1.sif"
SAMTOOLS="/home/tgenref/containers/grandcanyon/common_tools/samtools_1.17--hd87286a_1.sif"

INPUT_DIR=/scratch/yhao/grandcanyon/RNA_align_pacbio
OUTPUT_DIR=/scratch/yhao/grandcanyon/RNA_align_pacbio  # change later for output directories

[[ -e $OUTPUT_DIR ]] || mkdir -p $OUTPUT_DIR

REFERENCE=/home/tgenref/homo_sapiens/t2t_chm13/chm13_v2/genome_reference/chm13v2.0_maskedY_rCRS.fa
REF_DIR=$(dirname $REFERENCE)

THREADS=20


[[ -e $OUTPUT_DIR ]] || mkdir -p $OUTPUT_DIR

#fastq.gz input
INPUT=$1
#.sam tempfile
SAMFILE=${INPUT%.fastq.gz}_aligned.sam
#.bam output
OUTPUT=${SAMFILE%.sam}.bam


# For PacBio Iso-seq/traditional cDNA
singularity exec -B $PWD -B $INPUT_DIR -B $OUTPUT_DIR -B $REF_DIR $MINIMAP2 sh -c "minimap2 -ax splice:hq -t ${THREADS} -uf ${REFERENCE} ${INPUT} > ${SAMFILE}"

# Sort and convert to bam
singularity exec -B $PWD -B $INPUT_DIR -B $OUTPUT_DIR -B $REF_DIR $SAMTOOLS sh -c "samtools sort -@ ${THREADS} --write-index -O BAM -o ${SAMFILE} > ${OUTPUT}"



