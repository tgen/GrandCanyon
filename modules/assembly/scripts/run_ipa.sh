#!/bin/bash
#SBATCH --job-name=ipa	        # Job name
##SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=yhao@tgen.org     # Where to send mail	
#SBATCH --ntasks=4                    # # CPU
#SBATCH --mem=100gb                     # Job memory request
#SBATCH --time=5:00:00               # Time limit hrs:min:sec
#SBATCH --output=ipa_%j.log      # Standard output and error log


SCRIPT_DIR=/home/yhao/GrandCanyon/yhao_GenomeAssemblyPacBioHiFi


# File name
#FILE=SRR9087600_10k_reads.fastq.gz
FILE=ecoli.fastq.gz
PREFIX=${FILE%.fastq.gz}



DIR=/scratch/yhao/grandcanyon/ipa
cd $DIR


$SCRIPT_DIR/yh_ipa.sh -i $FILE -d $DIR -t 4 -j 1