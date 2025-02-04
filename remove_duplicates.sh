#!/bin/bash
# Go to the right directory 

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
	echo "Error: No arguments provided. \nUsage: $0 <workdir> <adapter> [arg3] ..."
	exit 1
fi

dir=$1

cd $dir

bam=$(ls *.sorted.bam | cut -d. -f1 | sort -u)
echo $bam

for file in ${bam[@]}; do

	picard MarkDuplicates -I $file.sorted.bam -O mark_dup_$file.sorted.bam -M marked_dup_metrics.txt --REMOVE_SEQUENCING_DUPLICATES


done