#!/bin/bash
#SBATCH --job-name=longread_stats_test
#SBATCH -N 1
#SBATCH -t 0-6:00
#SBATCH -n 1
#SBATCH --cpus-per-task 8
#SBATCH --mem=16G

module load singularity/3.8.4

########################################################################
# Variables that need to be defined within the config file or passed
#
########################################################################
# Samtools container
samtools_container="$1"

# BAM file to generate sam stats from
bam="$2"

# Output location for the samtools stats result file
output_dir="$3"

# results directory is only needed for the singularity bind
results_dir=$(dirname ${bam})

# Prefix used for the resulting sam stats file
prefix=$(basename ${bam} | cut -d"." -f1)

# Reference fasta file
reference_fasta="$4"

######################################################################################################
# Parameters:
# samtools view
#     -q 10                 ==> Output reads with mapping quality >= INT. Using a conservative mapQ
# samtools stats
#     --filtering-flag 256  ==> Filter reads that are not primary alignments
#     --coverage 1,2500,1   ==> Coverage distribution min,max,step. Max default is 1000. Kept max=2500
#                               from tempe workflow
#     --GC-depth 100        ==> The size of GC-depth bins. Default is 2e4 (20000). Smaller bins increases
#                                memory usage. Kept 100 from tempe workflow since no reason to change.
#     --remove-dups         ==> THIS OPTION IS EXCLUDED SINCE THERE ARE NO DUPLICATES (IS IN TEMPE WORKFLOW). 
#                               MIGHT RETHINK THIS IF WE EVER RUN ILLUMINA'S LONG READ PREPS.
#     --remove-overlaps     ==> THIS OPTION IS EXCLUDED SINCE THERE ARE SINGLE END READS
#                               (IS IN TEMPE WORKFLOW). MIGHT RETHINK THIS IF WE EVER RUN ILLUMINA'S LONG 
#                               READ PREPS.
######################################################################################################

# Samtools command
singularity exec -B ${results_dir} -B ${output_dir} ${samtools_container} samtools view \
  --threads 7 \
  -q 10 \
  -h \
  "${bam}" \
  | \
singularity exec -B ${results_dir} -B ${output_dir} ${samtools_container} samtools stats \
      --threads 7 \
      --GC-depth 100 \
      --filtering-flag 256 \
      --coverage 1,2500,1 \
      --reference "${reference_fasta}" \
      > "${output_dir}/${prefix}.bamstats.txt"

