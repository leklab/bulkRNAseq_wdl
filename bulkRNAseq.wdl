#WRKFLO

workflow bulkRNAseq {
  File bulkRNAseq_fastqs
  Array[Array[File]] fastqs = read_tsv(bulkRNAseq_fastqs)
    #fastqs[0]: sample ID
    #fastqs[1]: path to 1 or 2 fastq files, separated by a single space if 2
  String star_index
  String rsem_reference
  Boolean paired_end_reads  

  scatter (fastq_set in fastqs) {
    call STAR {
      input:
        fastq = fastq_set[1],
        sample_id = fastq_set[0],
        star_index = star_index
    }
    call MarkDuplicates {
      input:
        sample_id = fastq_set[0],
        sortedByCoord_bam = STAR.sortedByCoord_bam,
    }
    if(paired_end_reads){
      call RSEM_paired {
        input:
          sample_id = fastq_set[0],
          transcript_bam = STAR.transcript_bam,
          rsem_ref = rsem_reference
      }
    }
    if(!paired_end_reads) {
      call RSEM_single {
        input:
	  sample_id = fastq_set[0],
          transcript_bam = STAR.transcript_bam,
          rsem_ref = rsem_reference
      }
    }
  }
  #add outputs
}

#TSKS

task STAR {
  String star_index
  String fastq
  String sample_id
  command {
    module load STAR
    STAR --runMode alignReads \
      --runThreadN 16 \
      --genomeDir ${star_index} \
      --twopassMode Basic \
      --outFilterMultimapNmax 20 \
      --alignSJoverhangMin 8 \
      --alignSJDBoverhangMin 1 \
      --outFilterMismatchNmax 999 \
      --outFilterMismatchNoverLmax 0.1 \
      --alignIntronMin 20 \
      --alignIntronMax 1000000 \
      --alignMatesGapMax 1000000 \
      --outFilterType BySJout \
      --outFilterScoreMinOverLread 0.33 \
      --outFilterMatchNminOverLread 0.33 \
      --limitSjdbInsertNsj 1200000 \
      --readFilesIn ${fastq} \
      --readFilesCommand zcat \
      --outFileNamePrefix ${sample_id}. \
      --outSAMstrandField intronMotif \
      --outFilterIntronMotifs None \
      --alignSoftClipAtReferenceEnds Yes \
      --quantMode TranscriptomeSAM GeneCounts \
      --outSAMtype BAM Unsorted SortedByCoordinate \
      --outSAMunmapped Within \
      --genomeLoad NoSharedMemory \
      --chimSegmentMin 15 \
      --chimJunctionOverhangMin 15 \
      --chimOutType WithinBAM SoftClip \
      --chimMainSegmentMultNmax 1 \
      --outSAMattributes NH HI AS nM NM ch \
      --outSAMattrRGline ID:rg1 SM:sm1
  }
  runtime {
    cpus: 16
    requested_memory: 64000
  }
  output {
    File sortedByCoord_bam = "${sample_id}.Aligned.sortedByCoord.out.bam"
    File aligned_bam = "${sample_id}.Aligned.out.bam"
    File transcript_bam = "${sample_id}.Aligned.toTranscriptome.out.bam"
    File chimeric_junction = "${sample_id}.Chimeric.out.junction"
    File chimeric_sam = "${sample_id}.Chimeric.out.sam"
    File final_log = "${sample_id}.Log.final.out"
    File log = "${sample_id}.Log.out"
    File progress_log = "${sample_id}.Log.progress.out"
    File reads_per_gene = "${sample_id}.ReadsPerGene.out.tab"
    File sj = "${sample_id}.SJ.out.tab"
    String STARgenome = "${sample_id}._STARgenome"
    String STARpass1 = "${sample_id}._STARpass1"
  }
}

task MarkDuplicates{
    File sortedByCoord_bam
    String sample_id
    command {
      module load picard/2.9.0-Java-1.8.0_121
      java -jar $EBROOTPICARD/picard.jar \
        MarkDuplicates I=${sortedByCoord_bam} \
        O=${sample_id}.marked_dup.bam \
        M=${sample_id}.marked_dup_metrics.txt \
        ASSUME_SORT_ORDER=coordinate
    }
    runtime {
      cpus: 16
      requested_memory: 32000
    }
    output {
      File md_bam_file = "${sample_id}.marked_dup.bam"
      File md_metrics_file = "${sample_id}.marked_dup_metrics.txt"
    }
}

task RSEM_paired{
    File transcript_bam
    String sample_id
    String rsem_ref
    command {
      module load RSEM/1.3.0-foss-2016b
      rsem-calculate-expression \
        --num-threads 2 \
        --no-bam-output \
        --paired-end \
        --alignments \
        --fragment-length-max 1000 \
        ${transcript_bam} \
        ${rsem_ref} \
        ${sample_id}
    }
    runtime {
      cpus: 16
      requested_memory: 16000
    }
    output {

    }
}

task RSEM_single{
    File transcript_bam
    String sample_id
    String rsem_ref
    command {
      module load RSEM/1.3.0-foss-2016b
      rsem-calculate-expression \
        --num-threads 2 \
        --no-bam-output \
        --alignments \
        --fragment-length-max 1000 \
        ${transcript_bam} \
        ${rsem_ref} \
        ${sample_id}
    }
    runtime {
      cpus: 16
      requested_memory: 16000
    }
    output {

    }
}

