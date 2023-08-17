#!/bin/bash

print_help(){
    printf "
    Usage:
        margin_phasing.sh -b <ALIGN_BAM> -r <REFERENCE_FASTA> -v <VARIANT_VCF> -p <PARAMS> 

    Available arguments:
        -h  | --help         - Print this help dialog
        -b  | --bam          - Input bam
        -r  | --reference    - Reference fasta file
        -v  | --vcf          - Variant vcf file
        -p  | --param        - Parameter file that matches your read data 	
        -t  | --thread       - Thread count
        -o  | --output       - Output prefix"
    exit 0
}


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

PEPPER="/home/tgenref/containers/grandcanyon/variant_calling/pepper_deepvariant_r0.8.sif"

# Preparing singularity binds and making the output directory if it does not exist
INPUT_BIND=$(dirname $INPUT)
OUTPUT_BIND=$(dirname $OUTPUT)
[[ -e $OUTPUT_BIND ]] || mkdir -p $OUTPUT_BIND

echo input bind $INPUT_BIND
echo output bind $OUTPUT_BIND
echo BAM ${BAM}
echo REF ${REFERENCE}
echo VCF ${VCF}
echo PARAM ${PARAM}
echo THREAD ${THREAD}
echo OUTPUT ${OUTPUT}

singularity exec -B $PWD -B $INPUT_BIND -B $OUTPUT_BIND $PEPPER margin phase $BAM $REFERENCE $VCF $PARAM -t $THREAD -o $OUTPUT
