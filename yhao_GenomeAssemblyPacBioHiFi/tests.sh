#!/bin/bash
#SBATCH --job-name=asmhifi	        # Job name
##SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=yhao@tgen.org     # Where to send mail	
#SBATCH --ntasks=4                    # # CPU
#SBATCH --mem=40gb                     # Job memory request
#SBATCH --time=5:00:00               # Time limit hrs:min:sec
#SBATCH --output=asmhifi_%j.log      # Standard output and error log



# Testing assemblers for genome assembly using PacBio HiFi data

FILE=SRR9087600_10k_reads.fastq.gz
PREFIX=${FILE%.fastq.gz}
SCRIPT_DIR=/home/yhao/GrandCanyon/yhao_GenomeAssemblyPacBioHiFi




### hifiasm

DIR=/scratch/yhao/grandcanyon/hifiasm
cd $DIR
$SCRIPT_DIR/yh_hifiasm.sh -i $FILE -d $DIR -t 4

#check assembly stats

$SCRIPT_DIR/yh_assembly_stats.sh -a hifiasm -i $PREFIX -d $DIR




### flye

DIR=/scratch/yhao/grandcanyon/flye
cd $DIR

$SCRIPT_DIR/yh_flye.sh -i $FILE -d $DIR -t 4


#check assembly stats

$SCRIPT_DIR/yh_assembly_stats.sh -a flye -i $PREFIX -d $DIR



### hicanu


DIR=/scratch/yhao/grandcanyon/canu
cd $DIR

#Test passed with ecoli data
#cd $DIR/echoli
#FILE=ecoli.fastq.gz
#PREFIX=${FILE%.fastq.gz}
#$SCRIPT_DIR/yh_canu.sh -i $FILE -d $DIR -g 4.8m
#$SCRIPT_DIR/yh_assembly_stats.sh -a canu -i $PREFIX -d $DIR


#testing with downsized human test data even with "fake" genome size and relaxed thresholds
#Not working
cd $DIR
FILE=SRR9087600.fastq.gz
PREFIX=${FILE%.fastq.gz}
$SCRIPT_DIR/yh_canu.sh -i $FILE -d $DIR -g 5m



#check assembly stats

#$SCRIPT_DIR/yh_assembly_stats.sh -a canu -i $PREFIX -d $DIR



### ipa


#FILE=SRR9087600_10k_reads.fastq.gz

#Testing with ecoli data
FILE=ecoli.fastq.gz
PREFIX=${FILE%.fastq.gz}



DIR=/scratch/yhao/grandcanyon/ipa
cd $DIR


$SCRIPT_DIR/yh_ipa.sh -i $FILE -d $DIR -t 4 -j 1

