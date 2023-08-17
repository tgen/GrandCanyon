#!/usr/bin/env bash

#SBATCH --job-name=ont_raw_processing
#SBATCH -N 1
#SBATCH -t 0-12:00
#SBATCH -n 1
#SBATCH --cpus-per-task 40
#SBATCH --mem=32G
#SBATCH --profile=ltask 
#SBATCH --acctg-freq=task=1
# Reserve a full node for testing

# Unload preloaded petagene module as it causes errors
module unload petagene/protect_1.3.21-1

# Load singularity to leverage containers
module load singularity

source variables.txt

# Define local container locations
SAMTOOLS_SIF=/home/tgenref/containers/samtools_1.16.1.sif

###################################
## Define inputs, outputs, and directories to bind
###################################

# Reference files and directory
REFERENCE=/home/tgenref/homo_sapiens/grch38_hg38/hg38tgen/genome_reference/GRCh38tgen_decoy_alts_hla.fa
ALT_FILE=/home/tgenref/homo_sapiens/grch38_hg38/hg38tgen/tool_resources/bwa2_2.2.1/GRCh38tgen_decoy_alts_hla.fa.alt
REFERENCE_DIR=/home/tgenref/homo_sapiens/grch38_hg38/hg38tgen/genome_reference

# Input file and directory
INPUT_UBAM=/scratch/fmadrid/hackathon/grandcanyon/KMS11/raw_ubams/KMS11_JCRBsus_p13_CL_Whole_T1_OGL14_L68602_PAO94632_NoIndex_L001_150f1934.simplex.5mCG_5hmCG.ubam
INPUT_DIR=/scratch/fmadrid

# Output
OUTPUT_BASENAME=/scratch/fmadrid/hackathon/ont/KMS11_JCRBsus
OUTPUT_DIR=/scratch/fmadrid/hackathon/ont

# Define tmp directory
TEMP=/scratch/fmadrid/hackathon/ont/tmp

# Input for other tags from LIMS
source /scratch/fmadrid/hackathon/variables.txt

# Create readgroup information
# NOTES: What is the CM tag? Will need a way to capture the DS tag string to include in updated uBAM. Is there a SMRT-cell identifier akin to flowcell ID?

# Extracting header from ubam, need to make sure only one line is extracted grep -c? 
ubam_header=$(singularity exec -B ${INPUT_DIR} ${SAMTOOLS_SIF} samtools head ${INPUT_UBAM} | grep '@RG')

[[ $(echo "${ubam_header}" | wc -l) -ne "1" ]] && echo "More RG lines than expected" && exit 1

# capture DS tag
rg_ds=$(echo ${ubam_header} | grep -Po '(?<=DS:)\S*')
rg_ds=$(echo ${rg_ds} | sed 's/ /;/g')

FULL_RG="@RG\tID:${rg_id}\tPL:${rg_pl}\tPM:${rg_pm}\tPU:${rg_pu}\tLB:${rg_lb}\tSM:${rg_sm}\tBC:${rg_bc}\tCN:${rg_cn}\tDS:${rg_ds}\tCM:${rg_cm}"

###################################
## Update the SMRT-link Created uBAM to have TGen Compliant RG tags and be ready for zipperBam
###################################

# Collate the BAM and update readgroups
singularity exec -B $INPUT_DIR -B $OUTPUT_DIR -B $REFERENCE_DIR ${SAMTOOLS_SIF} \
  samtools collate \
  --threads 30 \
  --no-PG \
  -O \
  -u \
  ${INPUT_UBAM} | \
  singularity exec -B $INPUT_DIR -B $OUTPUT_DIR ${SAMTOOLS_SIF} \
    samtools addreplacerg \
    --threads 10 \
    --no-PG \
    -r ${FULL_RG} \
    -o ${OUTPUT_BASENAME}_uBAM_collated.bam \
    --output-fmt BAM \
    -