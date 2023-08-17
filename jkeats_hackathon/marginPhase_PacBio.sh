
# Reserve a full node for testing
srun --nodes=1 --cpus-per-task=40 --pty bash

# Unload preloaded petagene module as it causes errors
module unload petagene/protect_1.3.21-1

# Load singularity to leverage containers
module load singularity

# Define local container locations
SAMTOOLS_SIF=/home/tgenref/containers/samtools_1.16.1.sif
MINIMAP2_SIF=/home/tgenref/containers/minimap2_2.25.sif
FGBIO_SAMTOOLS_SIF=/home/tgenref/containers/fgbio-samtools_2.0.2.sif
DEEPVARINT_15_SIF=/home/tgenref/containers/grandcanyon/variant_calling/deepvariant_1.5.0-gpu.sif
BCFTOOLS_SIF=/home/tgenref/containers/grandcanyon/common_tools/bcftools_1.17--h3cc50cf_1.sif
PEPPERMARGIN_SIF=/scratch/jzhang/grandcanyon_containers/pepper_deepvariant_r0.8.sif


###################################
## Define inputs, outputs, and directories to bind
###################################

# Reference files and directory
REFERENCE=/home/tgenref/homo_sapiens/t2t_chm13/chm13_v2/genome_reference/chm13v2.0_maskedY_rCRS.fa
REFERENCE_DIR=/home/tgenref/homo_sapiens/t2t_chm13/chm13_v2/genome_reference/


# Input file and directory
INPUT_UBAM=/illumina_run_folders/pacbio/revio/01/r84132_20230804_002251/1_B01/hifi_reads/m84132_230804_011218_s2.hifi_reads.bc2009.bam
INPUT_DIR=/illumina_run_folders/pacbio/revio/01/r84132_20230804_002251/1_B01/hifi_reads

# Output
OUTPUT_BASENAME=/scratch/jkeats/revio/COLO829BL_ATCCJJK_p1_CL_C2
OUTPUT_DIR=/scratch/jkeats/revio

# Define tmp directory
TEMP=/scratch/jkeats/revio/tmp

ulimit -u 10000 # https://stackoverflow.com/questions/52026652/openblas-blas-thread-init-pthread-create-resource-temporarily-unavailable/54746150#54746150


#########################################################
## FUNCTIONAL SPACE - Phase VCF file and BAM using DeepVariant and Margin
#########################################################

# Generate VCF file for entire genome - NOT THE MOST COMPUTATIONAL WAY TO DO IT, should be tasks, make examples ..., and by chromosome
singularity exec --bind /usr/lib/locale/ -B $OUTPUT_DIR -B $REFERENCE_DIR ${DEEPVARINT_15_SIF}\
    /opt/deepvariant/bin/run_deepvariant \
    --model_type PACBIO \
    --ref ${REFERENCE} \
    --reads ${OUTPUT_BASENAME}_mm_rg_sort_chm13.cram \
    --output_vcf ${OUTPUT_BASENAME}_mm_rg_sort_chm13_all.vcf.gz \
    --num_shards 40

## gVCF output is missing, should be added, also consider having deepTRIO when trio exists... but that should be county pipeline

# Filter the VCF to the Pass variants
singularity exec --bind /usr/lib/locale/ -B $OUTPUT_DIR -B $REFERENCE_DIR ${BCFTOOLS_SIF} \
    bcftools filter \
    --threads 10 \
    --include 'FILTER="PASS"' \
    --output ${OUTPUT_BASENAME}_mm_rg_sort_chm13_pass.vcf.gz \
    --output-type z \
    ${OUTPUT_BASENAME}_mm_rg_sort_chm13_all.vcf.gz

# Margin seems to work on CRAM but tossed some errors since workflow would have this input in temp as BAM
# converting to BAM for input to margin
singularity exec -B $OUTPUT_DIR -B $REFERENCE_DIR ${SAMTOOLS_SIF} \
    samtools view \
    --threads 36 \
    --output ${OUTPUT_BASENAME}_mm_rg_sort_chm13.bam \
    --output-fmt BAM \
    --reference ${REFERENCE} \
    --write-index \
    ${OUTPUT_BASENAME}_mm_rg_sort_chm13.cram


# Phase the reads and variant calls using margin
singularity exec --contain --pwd $PWD --workdir /tmp -B $OUTPUT_DIR -B $REFERENCE_DIR ${PEPPERMARGIN_SIF} \
    margin phase \
    ${OUTPUT_BASENAME}_mm_rg_sort_chm13.bam \
    ${REFERENCE} \
    ${OUTPUT_BASENAME}_mm_rg_sort_chm13_pass.vcf.gz \
    /opt/margin_dir/params/phase/allParams.haplotag.pb-hifi.snp.json \
    -t 36 \
    -o ${OUTPUT_BASENAME}_mm_rg_sort_chm13_phased

## NOTE: don't see an option for CRAM output
## EXPECTED OUTPUTS
# OUTPUT_PREFIX.haplotagged.bam: a BAM file with all reads tagged (HP) as 1, 2, or 0, with 0 indicating no haplotype assignment was made. If a region was specified, only reads from that region are included in the output. This output can be suppressed by using the --skipHaplotypeBAM parameter.
# OUTPUT_PREFIX.chunks.csv: a CSV describing the boundaries of each chunk
# OUTPUT_PREFIX.phased.vcf: a VCF with phased variants and phasesets. If a region was specified, only variants from that region are included in the output. This output can be suppressed by using the --skipPhasedVcf parameter.
# OUTPUT_PREFIX.phaseset.bed: a BED file describing the phasesets and the reason why phasing was broken with respect to the previous phaseset. This output can be suppressed by using the --skipPhasedVcf parameter.


# Index the output BAM file from margin
# For pipeline this would likely got to final output CRAM
singularity exec -B $OUTPUT_DIR -B $REFERENCE_DIR ${SAMTOOLS_SIF} \
    samtools index COLO829BL_ATCCJJK_p1_CL_C2_mm_rg_sort_chm13_phased.haplotagged.bam