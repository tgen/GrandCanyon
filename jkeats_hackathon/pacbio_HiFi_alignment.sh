
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
DEEPVARIANT_SIF=/home/tgenref/containers/
PEPPER_MARGIN_SIF=/home/tgenref/containers/



###################################
## Define inputs, outputs, and directories to bind
###################################

# Reference files and directory
REFERENCE=/home/tgenref/homo_sapiens/grch38_hg38/hg38tgen/genome_reference/GRCh38tgen_decoy_alts_hla.fa
ALT_FILE=/home/tgenref/homo_sapiens/grch38_hg38/hg38tgen/tool_resources/bwa2_2.2.1/GRCh38tgen_decoy_alts_hla.fa.alt
REFERENCE_DIR=/home/tgenref/homo_sapiens/grch38_hg38/hg38tgen/genome_reference

# Input file and directory
INPUT_UBAM=/illumina_run_folders/pacbio/revio/01/r84132_20230804_002251/1_B01/hifi_reads/m84132_230804_011218_s2.hifi_reads.bc2009.bam
INPUT_DIR=/illumina_run_folders/pacbio/revio/01/r84132_20230804_002251/1_B01/hifi_reads

# Create readgroup information
# NOTES: What is the CM tag? Will need a way to capture the DS tag string to include in updated uBAM. Is there a SMRT-cell identifier akin to flowcell ID?
FULL_RG='@RG\tID:m84132_B01_bc2009\tPL:PACBIO\tPM:REVIO\tPU:m84132\tLB:L78024\tSM:COLO829BL_ATCCJJK_p1_CL_C2\tBC:CGATCGCACTGAGTAT\tCN:TGen\tDS:READTYPE=CCS;Ipd:Frames=ip;PulseWidth:Frames=pw;BINDINGKIT=102-739-100;SEQUENCINGKIT=102-118-800;BASECALLERVERSION=5.0;FRAMERATEHZ=100.000000;BarcodeFile=metadata/m84132_230804_011218_s2.barcodes.fasta;BarcodeHash=e7c4279103df8c8de7036efdbdca9008;BarcodeCount=113;BarcodeMode=Symmetric;BarcodeQuality=Score'

# Output
OUTPUT_BASENAME=/scratch/jkeats/revio/COLO829BL_ATCCJJK_p1_CL_C2
OUTPUT_DIR=/scratch/jkeats/revio

# Define tmp directory
TEMP=/scratch/jkeats/revio/tmp

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

###################################
## Align reads with minimap
###################################

## THIS SECTION COULD BE CHUNKED TO OPTIMIZE COMPUTATION FOLLOWED BY MERGE

# Create PacBio HiFi compatible index
# IMPORTANT: precalculated index MUST match the presets used for alignment
# ONT and HiFi indexes are NOT interchangeable
singularity exec -B $OUTPUT_DIR -B $REFERENCE_DIR ${MINIMAP2_SIF} \
  minimap2 \
  -x map-hifi \
  -d GRCh38tgen_decoy_alts_hla.ont.mmi \
  --alt ${ALT_FILE} \
  ${REFERENCE}


# Create fastq from pacBio uBAM, pipe directly to minimap and convert to bam via samtools collate to prep for zipperBam
# Need to review the PacBio settings particulary -Y
singularity exec -B $OUTPUT_DIR ${SAMTOOLS_SIF} \
  samtools fastq \
  --threads 10 \
  ${OUTPUT_BASENAME}_uBAM_collated.bam \
  | \
  singularity exec -B $OUTPUT_DIR -B $REFERENCE_DIR ${MINIMAP2_SIF} \
    minimap2 \
    -t 30 \
    -a \
    -x map-hifi \
    -L GRCh38tgen_decoy_alts_hla.ont.mmi \
    /dev/stdin \
    | \
    singularity exec -B $OUTPUT_DIR ${SAMTOOLS_SIF} \
      samtools collate \
      --threads 10 \
      --no-PG \
      -o ${OUTPUT_BASENAME}_mm_collated.bam \
      --output-fmt BAM \
      -


# update RG tags using zipperBAM, sort the output, and create an index
singularity exec -B $OUTPUT_DIR -B $REFERENCE_DIR ${FGBIO_SAMTOOLS_SIF} \
  fgbio --tmp-dir ${TEMP} --compression 1 --async-io=true ZipperBams \
  --input=${OUTPUT_BASENAME}_mm_collated.bam \
  --unmapped=${OUTPUT_BASENAME}_uBAM_collated.bam \
  --ref=${REFERENCE} \
  | \
  singularity exec -B $OUTPUT_DIR -B $REFERENCE_DIR ${SAMTOOLS_SIF} \
    samtools sort \
    --threads 20 \
    --reference ${REFERENCE} \
    -o ${OUTPUT_BASENAME}_mm_rg_sort.cram \
    --output-fmt CRAM \
    --write-index \
    -
