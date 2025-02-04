#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Error: No arguments provided. \nUsage: $0 <workdir> [arg2] [arg3] ..."
	exit 1
fi

dir=$1
cd $dir

files=$(ls *.bam)
echo $files

for file in $files; do
	name=$(echo $file | cut -d. -f1)
	#echo $name
	if [ ! -e $name.txt ]; then
		echo $name
		samtools flagstat -@5 $file > $name.txt
	fi
done

echo 'done'