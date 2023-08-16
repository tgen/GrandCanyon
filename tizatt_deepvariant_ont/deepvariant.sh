
print_help(){
    printf "
    Usage:
        run_deepvariant --model_type ONT_R104 --ref /path/to/reference.fa --reads /path/to/bam --output_vcf /path/to/output_vcf --output_gvcf /path/to/output_gvcf --num_shards /num/threads --regions regions(s) --intermediate_results_dir /path/to/intermediate_results_dir

    Available arguments:
        -h  | --help         - Print this help dialog
        -i  | --input        - Input BAM/CRAM
        -o  | --output       - Path and name of the output vcf
        -g  | --output_gvcf  - Path and name of the output gvcf
        -c  | --regions      - Region (such as chr20)
        -t  | --threads      - Number of threads to use in deepvariant
        -r  | --reference    - Path to the reference fasta for alignment	
        -q  | --quiet        - Suppresses debug/processing info
    \n"

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
        -i|--input)
            INPUT="$2"
            shift 2 ;;
        -o|--output)
            OUTPUT="$2"
            shift 2 ;;
        -g|--output_gvcf)
            OUTPUT_GVCF="$2"
            shift 2 ;;
        -c|--regions)
            REGIONS="$2"
            shift 2 ;;
        -t|--threads)
            THREADS="$2"
            shift 2 ;;
        -r|--reference)
            REFERENCE="$2"
            shift 2 ;;
        -q|--quiet)
            quiet="true"
            shift 1 ;;
    esac
    num_args_rem=$((num_args_rem-1))
done

[[ -v quiet ]] || echo "Script called via $commands"

module load singularity

DEEPVARIANT=/home/tgenref/containers/deepvariant_1.5.0-gpu.sif

INPUT_BIND=$(dirname ${INPUT})
OUTPUT_BIND=$(dirname ${OUTPUT})
OUTPUT_GVCF_BIND=$(dirname $OUTPUT_GVCF})
[[ -e $OUTPUT_BIND ]] || mkdir -p $OUTPUT_BIND
[[ -e $OUTPUT_GVCF_BIND ]] || mkdir -p $OUTPUT_GVCF_BIND
REF_BIND=$(dirname $REFERENCE)

[[ -v quiet ]] || echo "singularity exec -B $PWD -B $INPUT_BIND -B $OUTPUT_BIND -B $OUTPUT_GVCF_BIND -B $REF_BIND $DEEPVARIANT sh -c \"run_deepvariant --model_type ONT_R104 --ref ${REFERENCE} --reads ${INPUT} --output_vcf ${OUTPUT} --output_gvcf ${OUTPUT_GVCF} --num_shards ${THREADS} --regions ${REGIONS} - " "


singularity exec -B $PWD -B ${INPUT_BIND} -B ${OUTPUT_BIND} -B ${OUTPUT_GVCF_BIND} -B ${REF_BIND} $DEEPVARIANT sh -c \"run_deepvariant --model_type ONT_R104 --ref ${REFERENCE} --reads ${INPUT} --output_vcf ${OUTPUT} --output_gvcf ${OUTPUT_GVCF} --num_shards ${THREADS} --regions ${REGIONS} "
