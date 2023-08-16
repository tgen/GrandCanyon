#!/usr/bin/env bash

####Parameterized SLURM Script ####
#SBATCH --job-name="hifi_cnv"
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH --partition=defq
#SBATCH --time=0-00:40:00
#SBATCH --error="log_HiFi_CNV_jid%J.out"
#SBATCH --output="log_HiFi_CNV_jid%J.out"
#SBATCH --mail-type=FAIL,TIME_LIMIT,TIME_LIMIT_90,TIME_LIMIT_80,TIME_LIMIT_50
#SBATCH --mail-user=`whoami`@tgen.org

##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
## HELP of the TOOL hificnv
#hificnv --help
#
#hificnv 0.1.6
#Chris Saunders <csaunders@pacificbiosciences.com>, J. Matthew Holt <mholt@pacificbiosciences.com>
#Copy number variant caller and depth visualization utility for PacBio HiFi reads
#
#Usage: hificnv [OPTIONS] --ref <FILE> --bam <FILE>
#
#Options:
#      --ref <FILE>              Genome reference in FASTA format
#      --bam <FILE>              Alignment file for query sample in BAM format
#      --maf <FILE>              Variant file used to generate minor allele frequency track, in VCF or BCF format
#      --exclude <FILE>          Regions of the genome to exclude from CNV analysis, in BED format
#      --expected-cn <FILE>      Expected copy number values, in BED format
#      --output-prefix <PREFIX>  Prefix used for all file output. If the prefix includes a directory, the directory must already exist [default: hificnv]
#      --threads <THREAD_COUNT>  Number of threads to use. Defaults to all logical cpus detected
#      --cov-regex <REGEX>       Regex used to select chromosomes for mean haploid coverage estimation. All selected chromosomes are assumed diploid [default: ^(chr)?\d{1,2}$]
#  -h, --help                    Print help
#  -V, --version                 Print version
#
#Copyright (C) 2004-2023     Pacific Biosciences of California, Inc.
#This program comes with ABSOLUTELY NO WARRANTY; it is intended for
#Research Use Only and not for use in diagnostic procedures.
##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

## REQUIRED ARGUMENTS:
# --ref REF_GENOME
# --bam BAMFILE

## OPTIONAL ARGUMENTS:
## all the remaining ones: see the excerpt of the help or run hificnv --help
## the value for the cov-regex parameter MUST be a contig name; Only One contig can be provided (unless I have missed the way of providing more than one contig; Tried several delimiters; did not work)
## furthermore, the option can be used only once and if several has been provided, the last one will be taken into account.
## values for options --exclude and --expected_cn MUST be BED files
## number of threads is only use at the beginning of the process and then it is only mono-threaded




## EXPECTED OUTPUT wit only MANDATORY options, i.e. --ref and --bam
## 4 files are expected to be outputted by hifi_cnv
## hificnv.log  hificnv.Sample0.copynum.bedgraph  hificnv.Sample0.depth.bw  hificnv.Sample0.vcf.gz
## the bw file is a BigWig and can be loaded in IGV
## the bedGraph can be loaded in IGV and gives you the CN (Copy Number value)
## the vcf provide the CN value in the FORMAT CN tag
## on Full genome data ( tested on COLO829BL_chm13.bam) using 18 threads takes ~ 4 minutes



function usage(){
  echo "USAGE: minimum information needed: Ref_genome and Bam file with pacbio data; 
  $0 --ref \${REF_GENOME}  --bam \${BAM_FILE}"
  echo ""
}

function checkDir(){
        local D=$1
        if [[ ! -e ${D} ]] ; then echo -e "DIR NOT FOUND << ${D} >>; Aborting!" ; exit -1 ; fi ;
}
function checkFile(){
        local F=$1
        if [[ ! -e ${F} ]] ; then echo -e "FILE NOT FOUND << ${F} >>; Aborting!" ; exit -1 ; fi ;
}

function check_ev(){
  EV=$1 ; MSG=$2
  if [ ${EV} -ne 0 ] ; then echo -e "ERROR with: ${MSG}" ; exit 1 ; else echo "${MSG}: OK!" ; fi
}


function getOptions(){
	VERBOSE=0
	DIR_WORK=${PWD}
	REF_GENOME=""
	BAM=""
	MAF=""
	EXCLUDE=""
	EXPECTED_CN=""
	PREFIX=""
	THREADS=1
	COV_REGEX=""
	LI="RECAP_INPUTS_USED:\n-->"
	# options may be followed by one colon to indicate they have a required argument
	if ! options=`getopt -o vhd:g:b:m:e:o:t:c: -l dir-work:,ref:,reference_genome:,bam:,maf:,exclude:,expected-cn:,prefix:,threads:,cov-regex:,help,verbose -- "$@"`
	then
	# something went wrong, getopt will put out an error message for us
					echo "ERROR in Arguments" ; usage
					exit -1
	fi
	eval set -- "$options"
	while [[ $# -gt 0 ]]
	do
# echo -e "\$1 == $1 ----> $2"  ; ## uncomment to check the values of $1 and $2 within the loop
					# for options with required arguments, an additional shift is required
		case $1 in
			-d|--dir-work) checkDir ${2} ; DIR_WORK=$2 ; DIR_WORK=${2} ; LI="${LI}\nDIR_WORK==${DIR_WORK}";  shift ;;
			-g|--ref|--reference_genome) checkFile ${2} ; REF_GENOME=$2 ; LI="${LI}\nDIR_SOURCE_PATIENT==${REF_GENOME}";  shift ;;
			-b|--bam) checkFile ${2} ; BAM=${2} ; LI="${LI}\nBAM==${BAM}"  ; shift ;;
			-m|--maf) checkFile ${2} ; MAF=${2} ; LI="${LI}\nMAF==${MAF}"  ; shift ;;
			-e|--exclude)  checkFile ${2} ; EXCLUDE=$2 ; LI="${LI}\nEXCLUDE==${EXCLUDE}";  shift ;;
			--expected-cn)  checkFile ${2} ; EXPECTED_CN=${2} ; LI="${LI}\nEXPECTED_CN==${EXPECTED_CN}";  shift ;;
			-o|--prefix)  PREFIX=${2} ; LI="${LI}\nPREFIX==${PREFIX}";  shift ;;
			-t|--threads) THREADS=${2} ; LI="${LI}\nTHREADS=${THREADS}" ;  shift ;;
			-c|--cov-regex) COV_REGEX="${2}" ; LI="${LI}\nCOV_REGEX==${COV_REGEX}";  shift ;;
			-v|--verbose) VERBOSE=1 ; LI="${LI}\nVERBOSE==${VERBOSE}" ; shift ;;
			-h|--help) usage ; exit ; shift ;;
			(--) shift ; echo "--" ;;
			(-*) echo -e "$0: error - unrecognized option $1\n\n" 1>&2   ; usage;  exit 1  ;;
			(*) break ; echo "$0: error --- unrecognized option $1" 1>&2 ; usage;  exit 1  ;;
		esac
		shift
	done
	if [ ${VERBOSE} -eq 1 ] ; then
					## recap defaults
					recap_defaults ${DEFAULTS_INI_FILE}
					#input recap
					echo -e "\n+----------------------------+\n${LI[@]}\n+----------------------------+\n"
	fi

}


module load singularity/3.8.4
SIF_IMAGE_HIFICNV="/home/tgenref/containers/grandcanyon/copy_number/hificnv_0.1.6b--h9ee0642_0.sif"

echo "capture arguments using getOptions ... " ;
getOptions $@


ADD_OPTIONS=" "
## manage options based on given inputs

## REQUIRED ARGUMENTS
if [[ ${REF_GENOME} != "" ]] ; 
then 
	ADD_OPTIONS=" ${ADD_OPTIONS[@]} --ref ${REF_GENOME}" ; 
else 
	echo -e "ERROR REFERENCE GENOME MUST BE PROVIDED; Aborting;" ; 
	exit 1 ; 
fi 

if [[ ${BAM} != "" ]] ; 
then 
	ADD_OPTIONS=" ${ADD_OPTIONS[@]} --bam ${BAM}" ; 
else 
	echo -e "ERROR REFERENCE GENOEM MUST BE PROVIDED; Aborting;" ; 
	exit 1 ; 
fi 


## OPTIONAL ARGUMENTS
if [[ ${MAF} != "" ]] ; then	ADD_OPTIONS=" ${ADD_OPTIONS[@]} --maf ${MAF}" ; fi
if [[ ${EXCLUDE} != "" ]] ; then	ADD_OPTIONS=" ${ADD_OPTIONS[@]} --exclude ${EXCLUDE}" ; fi
if [[ ${EXPECTED_CN} != "" ]] ; then	ADD_OPTIONS=" ${ADD_OPTIONS[@]} --expected-cn ${EXPECTED_CN}" ; fi
if [[ ${PREFIX} != "" ]] ; then	ADD_OPTIONS=" ${ADD_OPTIONS[@]} --output-prefix ${PREFIX}" ; fi
if [[ ${THREADS} -ne 1 && ${THREADS} =~ ^[0-9]*$ ]] ; then	ADD_OPTIONS=" ${ADD_OPTIONS[@]} --threads ${THREADS}" ; fi
if [[ ${COV_REGEX} != "" ]] ; then	ADD_OPTIONS=" ${ADD_OPTIONS[@]} --cov-regex ${COV_REGEX}" ; fi


mycmd="singularity exec -B /scratch,/home ${SIF_IMAGE_HIFICNV} hificnv ${ADD_OPTIONS}"

echo ${mycmd}
eval ${mycmd}

check_ev $? "hifi_cnv"
