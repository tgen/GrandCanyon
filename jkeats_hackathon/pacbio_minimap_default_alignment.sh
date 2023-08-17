
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
  -d chm13v2.0_maskedY_rCRS_mapHiFi.mmi \
  ${REFERENCE}


# Create fastq from pacBio uBAM, pipe directly to minimap and convert to bam via samtools collate to prep for zipperBam
# Need to review the PacBio settings particulary -Y
# I got an error with the first attempt where the sort order is not matching for the uBAM and aligned BAM
# I suspect the minimap batch of threads outputs in an order that doesn't match the uBAM so after alignment added collate for rapid sort

## Preset Information
# minimap2 - map-hifi	Align PacBio high-fidelity (HiFi) reads to a reference genome
# -k19 -w19 -U50,500 -g10k -A1 -B4 -O6,26 -E2,1 -s200

## Minimap options added
# -a	Generate CIGAR and output alignments in the SAM format. Minimap2 outputs in PAF by default.
# -Y	In SAM output, use soft clipping for supplementary alignments.
# -L	Write CIGAR with >65535 operators at the CG tag. Older tools are unable to convert alignments with >65535 CIGAR ops to BAM. This option makes minimap2 SAM compatible with older tools. Newer tools recognizes this tag and reconstruct the real CIGAR in memory.

## Minimap2 variables altered by map-hifi preset
# -k INT	Minimizer k-mer length [15]
# -w INT	Minimizer window size [2/3 of k-mer length]. A minimizer is the smallest k-mer in a window of w consecutive k-mers.
# -U INT1[,INT2] Lower and upper bounds of k-mer occurrences [10,1000000]. The final k-mer occurrence threshold is max{INT1, min{INT2, -f}}. This option prevents excessively small or large -f estimated from the input reference. Available since r1034 and deprecating --min-occ-floor in earlier versions of minimap2.
# -g NUM	Stop chain enlongation if there are no minimizers within NUM-bp [10k]
# -A INT	Matching score [2]
# -B INT	Mismatching penalty [4]
# -O INT1[,INT2] Gap open penalty [4,24]. If INT2 is not specified, it is set to INT1.
# -E INT1[,INT2] Gap extension penalty [2,1]. A gap of length k costs min{O1+k*E1,O2+k*E2}. In the splice mode, the second gap penalties are not used.
# -s INT	Minimal peak DP alignment score to output [40]. The peak score is computed from the final CIGAR. It is the score of the max scoring segment in the alignment and may be different from the total alignment score.

############################################
# Minimap2 defaults with hifi preset
############################################
singularity exec -B $OUTPUT_DIR ${SAMTOOLS_SIF} \
  samtools fastq \
  --threads 10 \
  ${OUTPUT_BASENAME}_uBAM_collated.bam \
  | \
  singularity exec -B $OUTPUT_DIR -B $REFERENCE_DIR ${MINIMAP2_SIF} \
    minimap2 \
    -t 30 \
    -x map-hifi \
    -a \
    -Y \
    -L \
    chm13v2.0_maskedY_rCRS_mapHiFi.mmi \
    /dev/stdin \
    | \
    singularity exec -B $OUTPUT_DIR ${SAMTOOLS_SIF} \
      samtools collate \
      --threads 10 \
      --no-PG \
      -o ${OUTPUT_BASENAME}_mm_collated_chm13.bam \
      --output-fmt BAM \
      -


# update RG tags using zipperBAM, sort the output, and create an index
singularity exec -B $OUTPUT_DIR -B $REFERENCE_DIR ${FGBIO_SAMTOOLS_SIF} \
  fgbio --tmp-dir ${TEMP} --compression 1 --async-io=true ZipperBams \
  --input=${OUTPUT_BASENAME}_mm_collated_chm13.bam \
  --unmapped=${OUTPUT_BASENAME}_uBAM_collated.bam \
  --ref=${REFERENCE} \
  | \
  singularity exec -B $OUTPUT_DIR -B $REFERENCE_DIR ${SAMTOOLS_SIF} \
    samtools sort \
    --threads 20 \
    --reference ${REFERENCE} \
    -o ${OUTPUT_BASENAME}_mm_rg_sort_chm13.cram \
    --output-fmt CRAM \
    --write-index \
    -
