
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

singularity exec --bind /usr/lib/locale/ -B $OUTPUT_DIR -B $REFERENCE_DIR ${DEEPVARINT_15_SIF} \
  /opt/deepvariant/bin/make_examples \
  --mode calling \
  --ref "/home/tgenref/homo_sapiens/t2t_chm13/chm13_v2/genome_reference/chm13v2.0_maskedY_rCRS.fa" \
  --reads "/scratch/jkeats/revio/COLO829BL_ATCCJJK_p1_CL_C2_mm_rg_sort_chm13.cram" \
  --examples "/tmp/tmp5fm6_ges/make_examples.tfrecord@10.gz" \
  --add_hp_channel \
  --alt_aligned_pileup "diff_channels" \
  --max_reads_per_partition "600" \
  --min_mapping_quality "1" \
  --parse_sam_aux_fields \
  --partition_size "25000" \
  --phase_reads \
  --pileup_image_width "199" \
  --norealign_reads \
  --regions "chr20" \
  --sort_by_haplotypes \
  --track_ref_reads \
  --vsc_min_fraction_indels "0.12" \
  --task {}



time seq 0 9 | parallel -q --halt 2 --line-buffer /opt/deepvariant/bin/make_examples --mode calling --ref "/home/tgenref/homo_sapiens/t2t_chm13/chm13_v2/genome_reference/chm13v2.0_maskedY_rCRS.fa" --reads "/scratch/jkeats/revio/COLO829BL_ATCCJJK_p1_CL_C2_mm_rg_sort_chm13.cram" --examples "/tmp/tmp5fm6_ges/make_examples.tfrecord@10.gz" --add_hp_channel --alt_aligned_pileup "diff_channels" --max_reads_per_partition "600" --min_mapping_quality "1" --parse_sam_aux_fields --partition_size "25000" --phase_reads --pileup_image_width "199" --norealign_reads --regions "chr20" --sort_by_haplotypes --track_ref_reads --vsc_min_fraction_indels "0.12" --task {}

