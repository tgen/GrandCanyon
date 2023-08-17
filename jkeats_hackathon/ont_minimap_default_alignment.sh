
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
INPUT_UBAM=/labs/MMRF/cell_lines/fastq_DoNotTouch/20230711_0817_3G_PAO86842_143fa590/dorado_0.3.1/KMS11_JCRBsus_p19_CL_Whole_T1_OGL14_L74672_PAO86842_NoIndex_L001_143fa590.simplex.5mCG_5hmCG.ubam
INPUT_DIR=/labs/MMRF/cell_lines/fastq_DoNotTouch/20230711_0817_3G_PAO86842_143fa590/dorado_0.3.1/

RSYNC_UBAM=KMS11_JCRBsus_p19_CL_Whole_T1_OGL14_L74672_PAO86842_NoIndex_L001_143fa590.simplex.5mCG_5hmCG.ubam

# Output
OUTPUT_BASENAME=/scratch/jkeats/ont_testing/KMS11_JCRBsus_p19_CL_Whole_T1_OGL14
OUTPUT_DIR=/scratch/jkeats/ont_testing

# Define tmp directory
TEMP=/scratch/jkeats/revio/tmp

# Define Read Group
FULL_RG='@RG\tID:PAO86842_1_L74672\tPL:ONT\tPM:PROMETHION\tPU:PAO86842_1\tLB:L74672\tSM:KMS11_JCRBsus_p19_CL_Whole_T1\tBC:NNNNNNNN\tCN:TGen\tDS:basecall_model=dna_r10.4.1_e8.2_400bps_sup@v4.2.0;runid=a78752787a2ae9912c3ceb09e32ef4639a3a3351'

###################################
## Update the SMRT-link Created uBAM to have TGen Compliant RG tags and be ready for zipperBam
###################################

cd ${OUTPUT_DIR}
rsync $INPUT_UBAM .

# Collate the BAM and update readgroups
singularity exec -B $INPUT_DIR -B $OUTPUT_DIR ${SAMTOOLS_SIF} \
    samtools addreplacerg \
    --threads 10 \
    --no-PG \
    -r ${FULL_RG} \
    --output-fmt BAM \
    ${RSYNC_UBAM} \
    | \
    singularity exec -B $INPUT_DIR -B $OUTPUT_DIR ${SAMTOOLS_SIF} \
      samtools collate \
      --threads 30 \
      -n 128 \
      --no-PG \
      --output-fmt BAM \
      - \
      ${OUTPUT_BASENAME}_uBAM_collated

# Kept getting errors like this so flipped things around and rsynced the file, how do you define /scratch as tmp for samtools?
# samtools collate: Couldn't write to intermediate file "/tmp/collate5a2a2.0021.bam": No such file or directory
# Seems like an error in collate, when you provide -o output.bam it uses /tmp but if you provide <prefix> then it write temp files to current dir
# This is not the expected behavior but might have been fixed in 1.17
## WARNING, might want to test samtools sort, might be slower but reading the /tmp issue on samtools leaves me uneasy about using collate on long-read data


###################################
## Align reads with minimap
###################################

## THIS SECTION COULD BE CHUNKED TO OPTIMIZE COMPUTATION FOLLOWED BY MERGE

# Create PacBio HiFi compatible index
# IMPORTANT: precalculated index MUST match the presets used for alignment
# ONT and HiFi indexes are NOT interchangeable
singularity exec -B $OUTPUT_DIR -B $REFERENCE_DIR ${MINIMAP2_SIF} \
  minimap2 \
  -x map-ont \
  -d chm13v2.0_maskedY_rCRS_mapONT.mmi \
  ${REFERENCE}


# Create fastq from pacBio uBAM, pipe directly to minimap and convert to bam via samtools collate to prep for zipperBam
# Need to review the PacBio settings particulary -Y
# I got an error with the first attempt where the sort order is not matching for the uBAM and aligned BAM
# I suspect the minimap batch of threads outputs in an order that doesn't match the uBAM so after alignment added collate for rapid sort

## Preset Information
# map-ont is the default, so minimap defaults are the map-ont setting

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
    -x map-ont \
    -a \
    -Y \
    -L \
    chm13v2.0_maskedY_rCRS_mapONT.mmi \
    /dev/stdin \
    | \
    singularity exec -B $OUTPUT_DIR ${SAMTOOLS_SIF} \
      samtools collate \
      --threads 10 \
      -n 128 \
      --no-PG \
      --output-fmt BAM \
      - \
      ${OUTPUT_BASENAME}_mm_collated_chm13.bam

## NOTE: the ont alignment is much slower than the pacbio version, will need


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
