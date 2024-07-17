#!/bin/bash
# Go to the right directory 

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
	echo "Error: No arguments provided. \nUsage: $0 <workdir> [arg2] [arg3] ..."
	exit 1
fi

dir=$1
cd $dir

fastq=$(ls *.fastq.gz | cut -d. -f1 | sort -u)
echo $fastq

for fna in ${fastq[@]}; do
	# if fastq name ends with _1
	if [[ $fna == *_1 ]]; then

		file2=${fna/%_1/_2}
		out=${fna/%_1}

		# if file $out.sam do not exist
		if [ ! -e $out.sam ]; then
			bowtie2 -p 12 -x ~/index/ref_t2t/t2t -1 $fna.fastq.gz -2 $file2.fastq.gz > $out.sam
			samtools view -@ 12 -bS $out.sam | samtools sort -@ 12 -o $out.sorted.bam
			rm -rf $out.sam
			samtools index -@ 12 $out.sorted.bam
		fi

	elif [[ $fna == *_2 ]]; then
		continue

	else
		if [ ! -e $fna.sam ]; then
			bowtie2 -p 12 -x ~/index/ref_t2t/t2t $fna.fastq.gz > $fna.sam
			samtools view -@ 12 -bS $fna.sam | samtools sort -@ 12 -o $fna.sorted.bam
			rm -rf $fna.sam
			samtools index -@ 12 $fna.sorted.bam
		fi
	fi
done
