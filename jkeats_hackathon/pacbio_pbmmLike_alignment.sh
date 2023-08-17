
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

# Create fastq from pacBio uBAM, pipe directly to minimap and convert to bam via samtools collate to prep for zipperBam
# Need to review the PacBio settings particulary -Y
# I got an error with the first attempt where the sort order is not matching for the uBAM and aligned BAM
# I suspect the minimap batch of threads outputs in an order that doesn't match the uBAM so after alignment added collate for rapid sort

## Preset comparison
# minimap2 - map-hifi	Align PacBio high-fidelity (HiFi) reads to a reference genome
# -k19 -w19 -U50,500 -g10k -A1 -B4 -O6,26 -E2,1 -s200
# pbmm2 - - "CCS" or "HIFI"
# -k 19 -w 19 -u -o 6 -O 26 -e 2 -E 1 -A 1 -B 4 -z 400 -Z 50  -r 2000   -g 5000
# pbmm2 - other implicity enabled settings:
# soft clipping with -Y
# long cigars for tag CG with -L
# X/= cigars instead of M with --eqx
# no secondary alignments are produced with --secondary=no

## Minimap
# -a	Generate CIGAR and output alignments in the SAM format. Minimap2 outputs in PAF by default.
# -Y	In SAM output, use soft clipping for supplementary alignments.
# -L	Write CIGAR with >65535 operators at the CG tag. Older tools are unable to convert alignments with >65535 CIGAR ops to BAM. This option makes minimap2 SAM compatible with older tools. Newer tools recognizes this tag and reconstruct the real CIGAR in memory.

## Minimap2 variables altered by a preset or pbmm2
# -k INT	Minimizer k-mer length [15]
# -w INT	Minimizer window size [2/3 of k-mer length]. A minimizer is the smallest k-mer in a window of w consecutive k-mers.
# -U INT1[,INT2] Lower and upper bounds of k-mer occurrences [10,1000000]. The final k-mer occurrence threshold is max{INT1, min{INT2, -f}}. This option prevents excessively small or large -f estimated from the input reference. Available since r1034 and deprecating --min-occ-floor in earlier versions of minimap2.
# -g NUM	Stop chain enlongation if there are no minimizers within NUM-bp [10k]
# -A INT	Matching score [2]
# -B INT	Mismatching penalty [4]
# -O INT1[,INT2] Gap open penalty [4,24]. If INT2 is not specified, it is set to INT1.
# -E INT1[,INT2] Gap extension penalty [2,1]. A gap of length k costs min{O1+k*E1,O2+k*E2}. In the splice mode, the second gap penalties are not used.
# -s INT	Minimal peak DP alignment score to output [40]. The peak score is computed from the final CIGAR. It is the score of the max scoring segment in the alignment and may be different from the total alignment score.

## Additional variables altered by pbmm2
# -u CHAR	How to find canonical splicing sites GT-AG - f: transcript strand; b: both strands; n: no attempt to match GT-AG [n]
### github says this is set but the example is incorrect as it should be -u [f/b/n]. Also why set for genomic alignments?
### reading pbmm2 repo it seems like this is setting: Disable homopolymer-compressed k-mer (compression is active for SUBREAD and UNROLLED preset)
### This should mean that -H IS NOT SET for HiFi/CCS reads unlike Subreads
# -o FILE	Output alignments to FILE [stdout]
### they are setting the output file to be 6? No, they have a different internal parser instead of providing -O an myArray+=(item)
# -z INT1[,INT2]  Truncate an alignment if the running alignment score drops too quickly along the diagonal of the DP matrix
# (diagonal X-drop, or Z-drop) [400,200]. If the drop of score is above INT2, minimap2 will reverse complement the query in
# the related region and align again to test small inversions. Minimap2 truncates alignment if there is an inversion or the
# drop of score is greater than INT1. Decrease INT2 to find small inversions at the cost of performance and false positives.
# Increase INT1 to improves the contiguity of alignment at the cost of poor alignment in the middle.
# -r NUM1[,NUM2]  Bandwidth for chaining and base alignment [500,20k]. NUM1 is used for initial chaining and alignment
# extension; NUM2 for RMQ-based re-chaining and closing gaps in alignments.
# -g NUM	Stop chain enlongation if there are no minimizers within NUM-bp [10k].

############################################
# Replicate pbmm2 alignment settings
############################################

# setting individual flags as expected by pbmm2 as preset might alter
# allowing it to self create an index as the custom settings make me scared
singularity exec -B $OUTPUT_DIR ${SAMTOOLS_SIF} \
  samtools fastq \
  --threads 10 \
  ${OUTPUT_BASENAME}_uBAM_collated.bam \
  | \
  singularity exec -B $OUTPUT_DIR -B $REFERENCE_DIR ${MINIMAP2_SIF} \
    minimap2 \
    -t 30 \
    -k 19 -w 19 -O 6,26 -E 2,1 -A 1 -B 4 -z 400,50 -r 2000 -g 5000 \
    -a \
    -Y \
    -L \
    --eqx \
    --secondary=no \
    ${REFERENCE} \
    /dev/stdin \
    | \
    singularity exec -B $OUTPUT_DIR ${SAMTOOLS_SIF} \
      samtools collate \
      --threads 10 \
      --no-PG \
      -o ${OUTPUT_BASENAME}_pbmmLike_collated.bam \
      --output-fmt BAM \
      -


# update RG tags using zipperBAM, sort the output, and create an index
singularity exec -B $OUTPUT_DIR -B $REFERENCE_DIR ${FGBIO_SAMTOOLS_SIF} \
  fgbio --tmp-dir ${TEMP} --compression 1 --async-io=true ZipperBams \
  --input=${OUTPUT_BASENAME}_pbmmLike_collated.bam \
  --unmapped=${OUTPUT_BASENAME}_uBAM_collated.bam \
  --ref=${REFERENCE} \
  | \
  singularity exec -B $OUTPUT_DIR -B $REFERENCE_DIR ${SAMTOOLS_SIF} \
    samtools sort \
    --threads 20 \
    --reference ${REFERENCE} \
    -o ${OUTPUT_BASENAME}_pbmmLike_rg_sort.cram \
    --output-fmt CRAM \
    --write-index \
    -
