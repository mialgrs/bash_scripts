#!/bin/bash
# Go to the right directory 

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
	echo "Error: No arguments provided. \nUsage: $0 <workdir> <adapter> [arg3] ..."
	exit 1
fi

dir=$1

cd $dir

fastq=$(ls *1.fastq..gz | cut -d. -f1 | sort -u)
echo $fastq

mkdir trim_data

for fna in ${fastq[@]}; do

	file2=${fna/%1/2}
	cutadapt -j 8 -a $2 -A $2 -o trim_data/tr_$fna.fastq.gz -p trim_data/tr_$file2.fastq.gz $fna.fastq.gz $file2.fastq.gz

done
