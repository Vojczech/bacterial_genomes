#!/bin/bash
# Unicycler short reads only
spades_algorithm=/home/lab141/tools/SPAdes-3.14.0-Linux/bin/spades.py
samtools=/home/lab141/tools/samtools-1.9/samtools
makeblastdb=/mnt/DATA01/vojta/ncbi-blast-2.9.0+/bin/makeblastdb
tblastn=/mnt/DATA01/vojta/ncbi-blast-2.9.0+/bin/tblastn
unicycler=/home/lab141/tools/Unicycler_v0.4.8/unicycler-runner.py
pilon=/home/lab141/tools/pilon-1.23.jar
threads_used=10
for file1 in *_S*_L003_R1_001.fastq.gz
do 
file2=${file1/R1/R2}
out=${file1%%_S*_L003_R1_001.fastq.gz}
$unicycler --short1 ./$file1 \
	--short2 ./$file2 \
	--out ./${out} \
	--threads $threads_used \
	--verbosity 2 \
	--spades_path $spades_algorithm \
	--min_fasta_length 200 \
	--keep 1 \
	--mode normal \
	--min_polish_size 1000 \
	--samtools_path $samtools \
	--makeblastdb_path $makeblastdb \
	--pilon_path $pilon \
	--tblastn_path $tblastn
done \
&& for file1 in *_S*_L003_R1_001.fastq.gz; do 
out=${file1%%_S*_L003_R1_001.fastq.gz}
	echo "unicycler finished" >> ./${out}/my_script_output.txt 
done \
&& for file1 in *_S*_L003_R1_001.fastq.gz; do
out=${file1%%_S*_L003_R1_001.fastq.gz}
	genome_id=${file1%%_S*_L003_R1_001.fastq.gz}
	mv ./${out}/assembly.fasta ./${out}/${genome_id}_assembly.fasta
done \
&& for file1 in *_S*_L003_R1_001.fastq.gz; do
	out=${file1%%_S*_L003_R1_001.fastq.gz}
	genome_id=${file1%%_S*_L003_R1_001.fastq.gz}
	/home/lab141/tools/pullseq/src/pullseq --input ./${out}/${genome_id}_assembly.fasta --min 5387 --verbose > ./${out}/${genome_id}_assembly_phagefree.fas
    /home/lab141/tools/pullseq/src/pullseq --input ./${out}/${genome_id}_assembly.fasta --max 5385 --verbose >> ./${out}/${genome_id}_assembly_phagefree.fas
done \
&& for file1 in *_S*_L003_R1_001.fastq.gz; do 
out=${file1%%_S*_L003_R1_001.fastq.gz}
	echo "phiX filtered out" >> ./${out}/my_script_output.txt 
done \
&& for file1 in *_S*_L003_R1_001.fastq.gz; do
	genome_id=${file1%%_S*_L003_R1_001.fastq.gz}
	out=${file1%%_S*_L003_R1_001.fastq.gz}
	awk '/^>/{print s? s"\n"$0:$0;s="";next}{s=s sprintf("%s",$0)}END{if(s)print s}' ./${out}/${genome_id}_assembly_phagefree.fas > ./${out}/${genome_id}_assembly_phagefree_lin.fas
	done \
&& for file1 in *_S*_L003_R1_001.fastq.gz; do 
out=${file1%%_S*_L003_R1_001.fastq.gz}
	echo "fasta linearized" >> ./${out}/my_script_output.txt 
done \
&& for file1 in *_S*_L003_R1_001.fastq.gz; do
	genome_id=${file1%%_S*_L003_R1_001.fastq.gz}
	out=${file1%%_S*_L003_R1_001.fastq.gz}
	prokka \
	--kingdom Bacteria \
	--mincontiglen 10 \
	--cpus $threads_used \
	--force --rnammer \
	--outdir ./${out}/${genome_id}_prokka \
	--prefix ${genome_id}_annotation \
	./${out}/${genome_id}_assembly_phagefree_lin.fas
done \
&& for file1 in *_S*_L003_R1_001.fastq.gz; do 
out=${file1%%_S*_L003_R1_001.fastq.gz}
	echo "prokka annotation finished" >> ./${out}/my_script_output.txt
done \
&& for file1 in *_S*_L003_R1_001.fastq.gz; do
	genome_id=${file1%%_S*_L003_R1_001.fastq.gz}
	out=${file1%%_S*_L003_R1_001.fastq.gz}
	awk '/^>/{print s? s"\n"$0:$0;s="";next}{s=s sprintf("%s",$0)}END{if(s)print s}' ./${out}/${genome_id}_prokka/${genome_id}_annotation.ffn > ./${out}/${genome_id}_prokka/${genome_id}_annotation_lin.ffn
done \
&& for file1 in *_S*_L003_R1_001.fastq.gz; do
	genome_id=${file1%%_S*_L003_R1_001.fastq.gz}
	out=${file1%%_S*_L003_R1_001.fastq.gz}
	grep "16S ribosomal RNA" -A 1 ./${out}/${genome_id}_prokka/${genome_id}_annotation_lin.ffn > ./16S_folder/${genome_id}_16S_rRNA.fas
done \
&& for file1 in *_S*_L003_R1_001.fastq.gz; do 
out=${file1%%_S*_L003_R1_001.fastq.gz}
	echo "16s rRNA extracted" >> ./${out}/my_script_output.txt
done \
&& for file1 in *_S*_L003_R1_001.fastq.gz; do
genome_id=${file1%%_S*_L003_R1_001.fastq.gz}
base_no=`grep "^[ACGTN]" ./${genome_id}/${genome_id}_assembly_phagefree.fas | tr -d "\n" | wc -m`
read_no=`echo $(zcat ${file1}|wc -l)/4|bc`
printf '%s\t%s\t%s\n' "$genome_id" "$base_no" "$read_no" >> stat_all.txt
done \
&& for file1 in *_S*_L003_R1_001.fastq.gz; do 
out=${file1%%_S*_L003_R1_001.fastq.gz}
	echo "lengths printed out" >> ./${out}/my_script_output.txt
done
