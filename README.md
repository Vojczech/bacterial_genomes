## Short read assembly
This bash script takes two FASTQ files from short read sequencing of bacterial genome. It uses Unicycler to assemble reads, filters out phiX contamination (using phiX constant size 5 386 bp in Unicycler assembly -> weak point, it might erase contig of same size) and uses Prokka to annotate genes. 16S rRNA gene is than filtered from the annotation and written to the separate fasta file. Read count and assembly size is calculated.

## Software used
[Unicycler assembler](https://github.com/rrwick/Unicycler)

[SPAdes assembler](http://cab.spbu.ru/software/spades/)

[Prokka](https://github.com/tseemann/prokka)

[bioawk](https://github.com/lh3/bioawk)

[pullseq](https://github.com/bcthomas/pullseq)
