#!/bin/bash

# Default variable values
DIR="../../data/labo/new/"
FASTQ="EN00007584_RPE1_INPUT_W3_1.fastq.gz"
ADAPTER1="AGATCGGAAGAGCACACGTCTGAACTCCAGTCA"
ADAPTER2="AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT"

# Function to display script usage
usage() {
 echo "Usage: $0 [OPTIONS]"
 echo "Options:"
 echo " -h, --help		Display this help message"
 echo " -d, --directory	Path to directory with fastq file"
 echo " -f, --fastq		Fastq file name"
 echo " --adapter1		forward sequence of the adapter trimming (optional)"
 echo " --adapter2		reverse sequence of the adapter trimming (optional)"
}

has_argument() {
		[[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*)  ]];
}

extract_argument() {
	echo "${2:-${1#*=}}"
}

# Function to handle options and arguments
handle_options() {
	while [[ $# -gt 0 ]]; do
		case $1 in
			-h | --help)
				usage
				exit 0
				;;
			-d | --directory)
				if ! has_argument $@; then
					echo "Directory not specified"
					usage
					exit 1
				fi

				DIR=$2

				shift # shift past the flag
				;;
			-f | --fastq)
				if ! has_argument $@; then
					echo "Fastq file not specified"
					usage
					exit 1
				fi

				FASTQ=$2

				shift 
				;;
			--adapter1)
				ADAPTER1=$2

				shift
				;;
			--adapter2)
				ADAPTER2=$2

				shift
				;;
			*)
				echo "Invalid option: $1"
				usage
				exit 1
				;;
		esac
		shift
	done
}

# Main script execution
handle_options "$@"

cd $DIR

name1=$(echo $FASTQ | cut -d. -f1)
name2=${name1/%1/2}
name=${name1/%_1/}

fastp  --thread 10 -i $name1.fastq.gz -I $name2.fastq.gz -o $name1.trimmed.fastq.gz -O $name2.trimmed.fastq.gz --adapter_sequence $ADAPTER1 --adapter_sequence_r2 $ADAPTER2
bowtie2 -p 12 -x ~/index/ref_t2t/t2t -1 $name1.trimmed.fastq.gz -2 $name2.trimmed.fastq.gz > $name.sam
samtools view -@ 12 -bS $name.sam | samtools sort -@ 12 -o $name.sorted.bam
rm -rf $name.sam
samtools index -@ 12 $name.sorted.bam

mkdir tmp

bamCoverage -p 12 -b $name.sorted.bam -o tmp/$name.bw --binSize 1 --extendReads --ignoreDuplicates --samFlagInclude 66
python ~/script_python/change_bw_chr_name.py ~/script_python/chr_names.txt tmp/$name.bw $name.bw

rm -rf tmp

echo 'done'
