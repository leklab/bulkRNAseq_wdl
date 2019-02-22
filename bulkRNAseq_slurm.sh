#!/bin/bash
#SBATCH --partition=general
#SBATCH --job-name=my_job
#SBATCH --nodes=1
#SBATCH --mem=64000
#SBATCH --cpus=8
#SBATCH --time=24:00:00
#SBATCH --mail-type=ALL

#SPECIFY INPUT .JSON FILE HERE
input_file=/home/ec753/project/RNAseq/bulkRNAseq_inputs.json
#SPECIFY paired end reads or not in inputs.json

#make output directories
mkdir bulkRNAseq_out
cd bulkRNAseq_out
mkdir STAR_out
mkdir MarkDuplicates_out
mkdir RSEM_out
cd ..

#cd into new running directory
mkdir temp
cd temp

#run bulkRNAseq.wdl with cromwell
java -Dconfig.file=/gpfs/ycga/project/ysm/lek/shared/tools/cromwell_wdl/slurm.conf \
	-jar /gpfs/ycga/project/ysm/lek/shared/tools/jars/cromwell-36.jar run ../bulkRNAseq.wdl \
	--inputs $input_file

#move important files to thier final destination
#find name of fastqs_file from .json wdl input
fastqs_file=$(grep 'bulkRNAseq_fastqs' $input_file | sed 's/.*bulkRNAseq.bulkRNAseq_fastqs": "\(.*\)"/\1/')

#get sample names from fastqs_file and add needed files to out directory
#STAR
#ReadsPerGene.out.tab
cut -f1 $fastqs_file | xargs -L1 -I '$' find -name '$.ReadsPerGene.out.tab' -exec cp {} ../bulkRNAseq_out/STAR_out/ \;
#Aligned.out.bam
cut -f1 $fastqs_file | xargs -L1 -I '$' find -name '$.Aligned.out.tab' -exec cp {} ../bulkRNAseq_out/STAR_out/ \;

#MARK DUPLICATES
#marked_dup_metrics
cut -f1 $fastqs_file | xargs -L1 -I '$' find -name '$.marked_dup_metrics.txt' -exec cp {} ../bulkRNAseq_out/MarkDuplicates_out/ \;
#marked_dup.bam
cut -f1 $fastqs_file | xargs -L1 -I '$' find -name '$.marked_dup.bam' -exec cp {} ../bulkRNAseq_out/MarkDuplicates_out/ \;

#RSEM
#isoforms.results
cut -f1 $fastqs_file | xargs -L1 -I '$' find -name '$.isoforms.results' -exec cp {} ../bulkRNAseq_out/RSEM_out/ \;
#genes.results
cut -f1 $fastqs_file | xargs -L1 -I '$' find -name '$.genes.results' -exec cp {} ../bulkRNAseq_out/RSEM_out/ \;

#all other files will be kept in temp/ directory
#to be efficient with storage remove temp/ with 'rm -r temp'
