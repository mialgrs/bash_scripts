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
	fastp -i forward.fastq.gz -I reverse.fastq.gz -o out_f.trimmed.fastq.gz -O out_r.trimmed.fastq.gz --adapter_sequence GATCGGAAGAGCACACGTCTGAACTCCAGTCACGTGCGATAATCTCGTATGCCGTCTTCTGCTTG --adapter_sequence_r2 AATGATACGGCGACCACCGAGATCTACACTGGATCGAACACTCTTTCCCTACACGACGCTCTTCCGATCT --trim_poly_g

	fastp  --thread ${GALAXY_SLOTS:-1} --report_title 'fastp report' -i 'forward_R1_fastq_gz' -I 'reverse_R2_fastq_gz' -o first.fastqsanger.gz -O second.fastqsanger.gz --adapter_sequence 'GATCGGAAGAGCACACGTCTGAACTCCAGTCACGTGCGATAATCTCGTATGCCGTCTTCTGCTTG'  --adapter_sequence_r2 'AATGATACGGCGACCACCGAGATCTACACTGGATCGAACACTCTTTCCCTACACGACGCTCTTCCGATCT' -q 3
	set -o | 
	grep -q pipefail && set -o pipefail;   
	ln -f -s '/data/dnb10/galaxy_db/files/d/f/b/dataset_dfb65702-cc98-4c2c-acf5-763711241506.dat' input_f.fastq.gz &&  
	ln -f -s '/data/dnb10/galaxy_db/files/4/c/3/dataset_4c394172-67ea-4de8-ae82-3c9d761edd12.dat' input_r.fastq.gz &&   
	THREADS=${GALAXY_SLOTS:-4} && 
	if [ "$THREADS" -gt 1 ]; 
	then (( THREADS-- )); 
	fi &&   
	bowtie2  -p "$THREADS"  -x '/data/db/data_managers/CHM13_T2T_v2.0/bowtie2_index/CHM13_T2T_v2.0/CHM13_T2T_v2.0' -1 'input_f.fastq.gz' -2 'input_r.fastq.gz' -I 0 -X 1500 --fr --sensitive | 
	samtools sort -l 0 -T "${TMPDIR:-.}" -O bam | 
	samtools view --no-PG -O bam -@ ${GALAXY_SLOTS:-1} -o '/data/jwd05e/main/078/189/78189049/outputs/dataset_b59f0adc-bd43-451b-b1c6-e6b847acc125.dat'
done
