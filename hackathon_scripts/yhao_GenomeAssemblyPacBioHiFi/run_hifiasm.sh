#!/bin/bash
#SBATCH --job-name=hifiasm	        # Job name
##SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=yhao@tgen.org     # Where to send mail	
#SBATCH --ntasks=4                    # # CPU
#SBATCH --mem=40gb                     # Job memory request
#SBATCH --time=5:00:00               # Time limit hrs:min:sec
#SBATCH --output=hifiasm_%j.log      # Standard output and error log




FILE=SRR9087600_10k_reads.fastq.gz
PREFIX=${FILE%.fastq.gz}
SCRIPT_DIR=/home/yhao/GrandCanyon/yhao_GenomeAssemblyPacBioHiFi



### hifiasm

DIR=/scratch/yhao/grandcanyon/hifiasm
cd $DIR

$SCRIPT_DIR/yh_hifiasm.sh -i $FILE -d $DIR -t 4

#check assembly stats

$SCRIPT_DIR/yh_assembly_stats.sh -a hifiasm -i $PREFIX -d $DIR
