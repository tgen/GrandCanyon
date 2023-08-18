#!/bin/bash 


function help {

	# Function to show usage and parameters
	echo ""
	echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	echo "LongShot"
	echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	echo 'Usage: longshot <sorted.bam> <reference.fa> <output.vcf>'
	echo ""

}


function longshot {

	module load singularity 

	bam=$1 # path to .bam file
	ref=$2 # path to reference file
	out=$3 # output path and filename

	#Run longshot with container
	singularity exec -B $PWD -B /scratch -B /home longshot_0.4.5--hd175d40_2.sif \
	longshot -b $bam -f $ref -o $out 

}
