#!/usr/bin/env nextflow

process BOWTIE2_ALIGN {
    container 'ghcr.io/bf528/bowtie2:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.bam'
	label 'process_medium'

    input:
    tuple val(sample), path(fastq)
    tuple val(name), path(index)

    output:
    tuple val(sample), val(name), path("${sample}.bam"), emit: bam

    script:
    """
    bowtie2 -x ${index}/${name} \
    -U ${fastq} \
    -S ${sample}.sam
    samtools view -bS ${sample}.sam > ${sample}.bam
    rm ${sample}.sam

    
    """
   
    stub:
    """
    touch ${sample}.bam
    """
}