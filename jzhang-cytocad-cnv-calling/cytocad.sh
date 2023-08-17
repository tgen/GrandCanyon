#!/bin/bash


##################################################        Note       ################################################
##  CytoCAD detects copy number events in long reads with low coverage                                             ##
##  The results should be compared with hificnv on pacbio long reads                                               ##
##  The sif container isn't under tgenref and I don't have write access                                            ##
##  A test run was done using /scratch/bturner/grandcanyon/oxford_nano_data/KMS11/KMS11_JPN.sorted.ont.chm13.bam   ##
##  The test results are in /scratch/jzhang/cytocad_test_output/                                                   ##
##                                                                                                                 ##
#####################################################################################################################

print_help(){
    printf "
    Usage:
        cytocad.sh -i /path/to/input/sample.bam -o /path/to/output_dir -b hg38 -f png -v 50000 -j 10 -p 500 -s 0.25 

    Available arguments:
        -h  | --help         - Print this help dialog
        -i  | --input        - Input bam
        -o  | --output       - Path and name of the output directory
        -b  | --build        - Genome build, Default hg38
        -f  | --format       - Output graph format	
        -v  | --interval     - Spread between each point in a chromosome where coverage is enquired, in bp. Minimum CNV sensitive detection size ~= interval x rolling, Default:50000
        -j  | --buffer       - Window size of each point, in bp,Default:10
        -r  | --rolling      - Rolling mean window size, Default:10
        -p  | --penalty      - Linear kernel penalty value for change point detection using Ruptures, Default:500
        -s  | --scale        - Proportion of mean coverage to be used for buffering to call hetero- and homozygous CNVs, Default:0.25"

    exit 0
}

# Dafault arguments
BUILD="hg38"
FORMAT="png"
INTERVAL="50000"
BUFFER="10"
ROLLING="10"
PENALTY="500"
SCALE="0.25"

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
        -b|--build)
            BUILD="$2"
            shift 2 ;;
        -f|--format)
            FORMAT="$2"
            shift 2 ;;
        -v|--interval)
            INTERVAL="$2"
            shift 2 ;;
        -j|--buffer)
            BUFFER="$2"
            shift 2 ;;
        -r|--rolling)
            ROLLING="$2"
            shift 2 ;;
        -p|--penalty)
            PENALTY="$2"
            shift 2 ;;
        -s|--scale)
            SCALE="$2"
            shift 1 ;;
    esac
    num_args_rem=$((num_args_rem-1))
done


# Load singularity
module load singularity

CYTOCAD="/scratch/jzhang/grandcanyon_containers/cytocad.sif"

# Preparing singularity binds and making the output directory if it does not exist
INPUT_BIND=$(dirname $INPUT)
OUTPUT_BIND=$(dirname $OUTPUT)
[[ -e $OUTPUT_BIND ]] || mkdir -p $OUTPUT_BIND

singularity exec -B $PWD -B $INPUT_BIND -B $OUTPUT_BIND $CYTOCAD cytocad ${INPUT} ${OUTPUT} -b ${BUILD} -f ${FORMAT} -i ${INTERVAL} -j ${BUFFER} -r ${ROLLING} -p ${PENALTY} -s ${SCALE} --add_plots

