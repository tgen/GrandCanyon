#!/bin/bash

# Get assembly stats


#help menu is modified from Bryce's
print_help(){
    printf "
    Usage:
        yh_assembly_stats.sh -a assembler -i input.file -d working/directory

    Available arguments:
        -h  | --help         - Print this help dialog
        -a  | --assembler    - Assembler used, choose from hifiasm, flye, ipa, canu
        -i  | --input        - File name without extention
        -d  | --directory    - Path of the input INPUT
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
        -a|--assembler)
            ASM="$2"
            shift 2 ;;    
        -i|--input)
            INPUT="$2"
            shift 2 ;;
        -d|--directory)
            DIR="$2"
            shift 2 ;;
        -q|--quiet)
            quiet="true"
            shift 1 ;;
    esac
    num_args_rem=$((num_args_rem-1))
done

[[ -v quiet ]] || echo "Script called via $commands"




module load singularity
ASMSTATS="/home/tgenref/containers/grandcanyon/assembly_tools/assembly-stats_1.0.1--h4ac6f70_7.sif"


if [[ $ASM == "hifiasm" ]]
then
	#Convert output gfa to fasta
	awk '/^S/{print ">"$2;print $3}' ${INPUT}.p_ctg.gfa > ${INPUT}.p_ctg.fasta
	awk '/^S/{print ">"$2;print $3}' ${INPUT}.a_ctg.gfa > ${INPUT}.a_ctg.fasta
	
	singularity exec -B $PWD -B $DIR $ASMSTATS sh -c "assembly-stats -t ${INPUT}.p_ctg.fasta ${INPUT}.a_ctg.fasta > ${INPUT}_assembly-stats.txt"
elif [[ $ASM == "flye" ]]
then
	singularity exec -B $PWD -B $DIR $ASMSTATS sh -c "assembly-stats -t assembly.fasta > ${INPUT}_assembly-stats.txt"
elif [[ $ASM == "canu" ]]
then
	singularity exec -B $PWD -B $DIR $ASMSTATS sh -c "assembly-stats -t ${INPUT}.contigs.fasta > ${INPUT}_assembly-stats.txt"
else
	echo "Assembler not supported yet, please check back later."
fi
	
