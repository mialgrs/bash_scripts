#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Error: No arguments provided. \nUsage: $0 <workdir> [arg2] [arg3] ..."
	exit 1
fi

dir=$1
cd $dir

mkdir tmp

files=$(ls *.bam)
echo $files

for file in $files; do
	name=$(echo $file | cut -d. -f1)
	#echo $name
	if [ ! -e $name.bw ]; then
		#echo $name
		#bamCoverage -p 12 -b $file -o $name.bw --binSize 1 --extendReads
		# commande que j'ai testé sur 1 bam
		#bamCoverage -p 12 -b $file -o tmp/$name.bw --binSize 1 --extendReads 250 --ignoreDuplicates --minMappingQuality 2
		bamCoverage -p 12 -b $file -o tmp/$name.bw --binSize 1 --extendReads --ignoreDuplicates --samFlagInclude 66
		python ~/script_python/change_bw_chr_name.py ~/script_python/chr_names.txt tmp/$name.bw $name.bw
	fi
done

rm -rf tmp

echo 'done'