#!/bin/bash
# Unicycler assembly short reads only
spades_algorithm=/home/lab141/tools/SPAdes-3.13.1-Linux/bin/spades.py
samtools=/home/lab141/tools/samtools-1.9/samtools
makeblastdb=/mnt/DATA01/vojta/ncbi-blast-2.9.0+/bin/makeblastdb
tblastn=/mnt/DATA01/vojta/ncbi-blast-2.9.0+/bin/tblastn
unicycler=/home/lab141/tools/Unicycler_v0.4.8/unicycler-runner.py
threads_used=20
for file1 in *_R1_001.fastq.gz
do 
file2=${file1/R1/R2}
out=${file1%%_R1_001.fastq.gz}
$unicycler --short1 ./$file1 \
	--short2 ./$file2 \
	--out ./${out} \
	--threads $threads_used \
	--verbosity 2 \
	--spades_path $spades_algorithm \
	--min_fasta_length 100 \
	--keep 1 \
	--mode normal \
	--min_polish_size 1000 \
	--samtools_path $samtools \
	--makeblastdb_path $makeblastdb \
	--tblastn_path $tblastn
done \
&& for file1 in *_R1_001.fastq.gz; do 
out=${file1%%_R1_001.fastq.gz}
	echo "unicycler finished" >> ./${out}/my_script_output.txt 
done \
&& for file1 in *_R1_001.fastq.gz; do
out=${file1%%_R1_001.fastq.gz}
	genome_id=${file1%%_R1_001.fastq.gz}
	mv ./${out}/assembly.fasta ./${out}/${genome_id}_assembly.fasta
done \
&& for file1 in *_R1_001.fastq.gz; do
	out=${file1%%_R1_001.fastq.gz}
	genome_id=${file1%%_R1_001.fastq.gz}
	/home/lab141/tools/pullseq/src/pullseq --input ./${out}/${genome_id}_assembly.fasta --min 5387 --verbose > ./${out}/${genome_id}_assembly_phagefree.fas
    /home/lab141/tools/pullseq/src/pullseq --input ./${out}/${genome_id}_assembly.fasta --max 5385 --verbose >> ./${out}/${genome_id}_assembly_phagefree.fas
done \
&& for file1 in *_R1_001.fastq.gz; do 
out=${file1%%_R1_001.fastq.gz}
	echo "phiX filtered out" >> ./${out}/my_script_output.txt 
done \
&& for file1 in *_R1_001.fastq.gz; do
	genome_id=${file1%%_R1_001.fastq.gz}
	out=${file1%%_R1_001.fastq.gz}
	bioawk -c fastx '{ gsub(/\n/,"",seq); print ">"$name; print $seq }' ./${out}/${genome_id}_assembly_phagefree.fas > ./${out}/${genome_id}_assembly_phagefree_lin.fas
done \
&& for file1 in *_R1_001.fastq.gz; do 
out=${file1%%_R1_001.fastq.gz}
	echo "fasta linearized" >> ./${out}/my_script_output.txt 
done \
&& for file1 in *_R1_001.fastq.gz; do
	genome_id=${file1%%_R1_001.fastq.gz}
	out=${file1%%_R1_001.fastq.gz}
	/home/lab141/tools/prokka/bin/prokka \
	--kingdom Bacteria \
	--mincontiglen 10 \
	--cpus $threads_used \
	--force --rnammer \
	--outdir ./${out}/${genome_id}_prokka \
	--prefix ${genome_id}_genome \
	./${out}/${genome_id}_assembly_phagefree_lin.fas
done \
&& for file1 in *_R1_001.fastq.gz; do 
out=${file1%%_R1_001.fastq.gz}
	echo "prokka annotation finished" >> ./${out}/my_script_output.txt
done 