#!/bin/bash
#SBATCH --job-name=minimap2	        # Job name
##SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=yhao@tgen.org     # Where to send mail	
#SBATCH --ntasks=20                    # # CPU
#SBATCH --mem=200gb                     # Job memory request
#SBATCH --time=10:00:00               # Time limit hrs:min:sec
#SBATCH --output=minimap2_%j.log      # Standard output and error log

# Working directory
DIR=/scratch/yhao/grandcanyon/RNA_align_pacbio

# File name
File=Alzheimers_pacbio_hifi

if [[ -e ${DIR}/$File.fastq.gz ]]
then
		echo "Found fastq.gz file"
        echo "Align with minimap2"
       ./yh_minimap2.sh ${DIR}/$File.fastq.gz
elif [[ -e ${DIR}/$File.bam ]]
then
        echo "Found bam file"
        if [[ ! -e ${DIR}/$File.bam.pbi ]]
        then
                echo "Generate index"
                ./yh_pbindex.sh ${DIR}/$File.bam
        fi
        echo "Convert bam to fastq"
		./yh_bam2fastq.sh ${DIR}/$File.bam
        echo "Align with minimap2"
        ./yh_minimap2.sh ${DIR}/$File.fastq.gz
fi