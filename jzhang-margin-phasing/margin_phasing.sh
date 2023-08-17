#!/bin/bash

print_help(){
    printf "
    Usage:
        margin_phasing.sh -b <ALIGN_BAM> -r <REFERENCE_FASTA> -v <VARIANT_VCF> -p <PARAMS> -t <thread> -o <output_format>

    Available arguments:
        -h  | --help         - Print this help dialog
        -b  | --bam          - Input bam
        -r  | --reference    - Reference fasta file
        -v  | --vcf          - Variant vcf file
        -p  | --param        - Parameter file that matches your read data
                               to haplotag ONT data use allParams.haplotag.ont-r94g507.json
                               to haplotag PacBio HiFi data use allParams.haplotag.pb-hifi.json
                               to phase a VCF generated using ONT data use allParams.phase_vcf.ont.json
                               to phase a VCF generated using PacBio-HiFi data use: allParams.phase_vcf.pb-hifi.json
        -t  | --thread       - Thread count
        -o  | --output       - Output prefix"
    exit 0
}

#Default Options
REFERENCE="/home/tgenref/homo_sapiens/t2t_chm13/chm13_v2/genome_reference/chm13v2.0_maskedY_rCRS.fa"

commands=$(echo "$(realpath $0)" $*)

# Reads each argument provided after calling the script
# if no argument is provided then the script will print a usage message
num_args_rem=$#

if [[ $num_args_rem == 0 ]] ; then
    print_help
fi

# Grabbing the remaining arguments to pass on to operations
while [[ $num_args_rem -ne 0 ]] ; do
    case "$1" in
        -h|--help)
            print_help
            shift 1 ;;
        -b|--bam)
            BAM="$2"
            shift 2 ;;
        -r|--reference)
            REFERENCE="$2"
            shift 2 ;;
        -v|--vcf)
            VCF="$2"
            shift 2 ;;
        -p|--param)
            PARAM="$2"
            shift 2 ;;
        -t|--thread)
            THREAD="$2"
            shift 2 ;;
        -o|--output)
            OUTPUT="$2"
            shift 1 ;;
    esac
    num_args_rem=$((num_args_rem-1))
done


# Load singularity
module load singularity

#PEPPER="/home/tgenref/containers/grandcanyon/variant_calling/pepper_deepvariant_r0.8.sif"
PEPPER="/scratch/jzhang/containers/pepper_deepvariant_r0.8.sif"

# Preparing singularity binds and making the output directory if it does not exist
INPUT_BIND=$(dirname $BAM)
OUTPUT_BIND=$(dirname $OUTPUT)
[[ -e $OUTPUT_BIND ]] || mkdir -p $OUTPUT_BIND

singularity exec -B $PWD -B $INPUT_BIND -B $OUTPUT_BIND $PEPPER margin phase $BAM $REFERENCE $VCF /opt/margin_dir/params/phase/$PARAM -t $THREAD -o $OUTPUT
