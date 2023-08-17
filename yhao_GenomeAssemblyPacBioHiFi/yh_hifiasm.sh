#!/bin/bash

# Primary/alternate assemblies using HiFi data

#help menu is modified from Bryce's
print_help(){
    printf "
    Usage:
        yh_hifiasm.sh -i input.fastq.gz -d working/directory -t 20

    Available arguments:
        -h  | --help         - Print this help dialog
        -i  | --input        - Input fastq
        -d  | --directory    - Path of the input file
        -t  | --threads      - Number of threads to use	
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
        -d|--directory)
            DIR="$2"
            shift 2 ;;
        -t|--threads)
            THREADS="$2"
            shift 2 ;;
        -q|--quiet)
            quiet="true"
            shift 1 ;;
    esac
    num_args_rem=$((num_args_rem-1))
done

[[ -v quiet ]] || echo "Script called via $commands"



module load singularity

HIFIASM="/home/tgenref/containers/grandcanyon/assembly_tools/hifiasm_0.19.5--h43eeafb_2.sif"

#prefix of output files
OUTPUT=${INPUT%.fastq.gz}



# Produce primary/alternate assemblies using HiFi data

singularity exec -B $PWD -B $DIR $HIFIASM sh -c "hifiasm -o $OUTPUT --primary -t $THREADS $INPUT"


