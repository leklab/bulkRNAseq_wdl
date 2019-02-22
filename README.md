# bulkRNAseq_wdl

This repo consists of wdl script, cromwell confs, and bash wrapper for bulk RNA-seq analysis optimized for Yale hpc Ruddle

## Input

A) bulkRNAseq_inputs.json

wdl inputs .json file containing paths for input fastqs file, STAR index, and RSEM reference

B) input fastqs file

.txt file containing one or more rows for each sample. 

Format: 1 sample per row, each row consists of sample_id and 1 or 2 paths to fastq files corresponding to single read or paired-end reads.
White space must be very specific, sample_id and paths must be separated with '\t', the two paths for paired-end reads must be separated by ' ' (one single space).

C) STAR index

D) RSEM reference

## Module Requirements

```
STAR/2.5.3a
picard/2.9.0-Java-1.8.0_121
RSEM/1.3.0
```
When Running on Ruddle, these modules are automatically loaded within the wdl

## Output

```bulkRNAseq_slurm.sh``` wrapper script creates a few directories.

1) temp

Temp is created to store all of the run-time output of cromwell including the output of STAR, RSEM, and MarkDuplicates as well as any error or log messages.

2) bulkRNAseq_out (can be specified in ```bulkRNAseq_slurm.sh```)

Important files at each step are automatically moved to one of the 3 following subdirectories

2.a) STAR_out
  
    a) $.ReadsPerGene.out.tab
    b) $.Aligned.out.tab
    
2.b) MarkDuplicates_out
  
    a) $.marked_dup_metrics.txt
    b) $.marked_dup.bam
    
2.c) RSEM_out
  
    a) $.isoforms.results
    b) $.genes.results
    
