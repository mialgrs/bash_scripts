#!/bin/bash
# Go to the right directory 

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
	echo "Error: No arguments provided. \nUsage: $0 <workdir> [arg2] [arg3] ..."
	exit 1
fi

dir=$1

cd $dir
files=$(ls *.bam)
echo $files
#for file in $files; do
#	if [[ $file =~ .gz$ ]]; then
#		echo $file | cut -d_ -f1 | sort -u
#	fi
#done
bam=$(ls *.bam | cut -d. -f1 | sort -u)
echo $bam

for one in $bam; do
    samtools sort -@ 12 $one.bam -o ../$one.sorted.bam
	samtools index -@ 12 ../$one.sorted.bam
done