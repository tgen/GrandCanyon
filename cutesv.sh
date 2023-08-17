#!/bin/bash 


function help {

	echo ""
	echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	echo "CuteSV"
	echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	echo 'Usage: cuteSV <sorted.bam> <reference.fa> <output.vcf> <max_cluster_bias_INS> <diff_ratio_merging_INS> <max_cluster_bias_DEL> <diff_ratio_merging_DEL> <threads>'
	echo ""
	echo 'Reccomended parameters for data-type:'
	echo "> For PacBio CLR data:
	--max_cluster_bias_INS		100
	--diff_ratio_merging_INS	0.3
	--max_cluster_bias_DEL	200
	--diff_ratio_merging_DEL	0.5

> For PacBio CCS(HIFI) data:
	--max_cluster_bias_INS		1000
	--diff_ratio_merging_INS	0.9
	--max_cluster_bias_DEL	1000
	--diff_ratio_merging_DEL	0.5

> For ONT data:
	--max_cluster_bias_INS		100
	--diff_ratio_merging_INS	0.3
	--max_cluster_bias_DEL	100
	--diff_ratio_merging_DEL	0.3
> For force calling:
	--min_mapq 			10"
	echo ""

}


function cutesv {

	module load singularity 

	bam=$1 # path to .bam file
	ref=$2 # path to reference file
	out=$3 # output path and filename
	mcbIns=$4 # Max cluster bias for insertions
	drmIns=$5 # breakpoint basepair identity threshold for insertions
	mcbDel=$6 # Max cluster bias for deletions
	drmDel=$7 # breakpoint basepair identity threshold for deletions
	threads=$8 # number of threads

	# Create temporary directory for CuteSV to write to
	mkdir temp

	#Run cutesv with container
	singularity exec -B $PWD -B /scratch -B /home cutesv_2.0.3--pyhdfd78af_0.sif \
	cuteSV $bam $ref $out temp/ \
	--max_cluster_bias_INS $mcbIns \
	--diff_ratio_merging_INS $drmIns \
	--max_cluster_bias_DEL $mcbDel \
	--diff_ratio_merging_INS $drmDel \
	--threads $threads

	# Delete temporary directory after CuteSV run finishes
	rm -r temp

}







