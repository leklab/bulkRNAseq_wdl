# bulkRNAseq_wdl

This repo consists of wdl script, cromwell confs, and bash wrapper for bulk RNA-seq analysis optimized for Yale hpc Ruddle

## Input

A) bulkRNAseq_inputs.json

wdl inputs .json file containing paths for input fastqs file, STAR index, and RSEM reference

B) input fastqs file

.txt file containing one or more rows for each sample. 

Format: 1 sample per row, each row consists sample_id and 1 or 2 paths to fastq files corresponding to single read or paired-end reads.
White space must be very specific, sample and paths must be separated with '\t', the two paths for paired-end reads must be separated by ' ' (one single space).

C) STAR index

D) RSEM reference



