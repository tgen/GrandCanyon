
module load singularity


# Reserving a full node just for testing

#srun --nodes=1 --cpus-per-task=40 --pty bash

# Input is a Pacbio aligned bam, with the sample name stored in the SM tag of the read groups.
INPUT=$1 
INPUT_DIR=$(dirname ${INPUT})

#  Output is a vcf file
OUTPUT=$2
OUTPUT_DIR=$(dirname ${OUTPUT})
REFERENCE=$3
REF_DIR=$(dirname $REFERENCE)
SAMPLE=$4
PBSV_DISCOVER_FILE="${OUTPUT_DIR}/ref.${SAMPLE}.svsig.gz"

PBSV=/home/tgenref/containers/grandcanyon/pacbio/pbsv_2.9.0--h9ee0642_0.sif
SAMTOOLS=/home/tgenref/containers/grandcanyon/common_tools/samtools_1.17--hd87286a_1.sif


# 1. Call pbsv discover to identify signatures of structural variation
singularity exec -B $INPUT_DIR -B $OUTPUT_DIR $PBSV pbsv discover ${INPUT} ${PBSV_DISCOVER_FILE}

# It is highly recommended to provide one tandem repeat annotation .bed file of your reference to pbsv discover via --tandem-repeats. This increases sensitivity and recall.
# optionally index svsig.gz to allow random access via `pbsv call -r`

chmod 755 ${PBSV_DISCOVER_FILE}
# 2. Call tabix on the output of step 1
echo "Calling tabix"
singularity exec -B ${OUTPUT_DIR} $SAMTOOLS \
    tabix -c '#' -s 3 -b 4 -e 4 ${PBSV_DISCOVER_FILE}


# 3. Call structural variants

echo "pbsv call structural variants"
singularity exec -B $PWD -B ${REF_DIR} -B ${OUTPUT_DIR} $PBSV pbsv call ${REFERENCE} ${PBSV_DISCOVER_FILE} ${OUTPUT}

