#!/usr/bin/env nextflow

process TRIM {
    container 'ghcr.io/bf528/trimmomatic:latest'
	publishDir params.outdir, mode: "copy", pattern: '*.log'
	label 'process_low'

    input:
	tuple val(sample), path(fastq)
    path(adapters)

	output:
	tuple val(sample), path('*_trim.log'), emit: log
	tuple val(sample), path('*_trimmed.fastq.gz'), emit: trim

    
    script:
    """
    trimmomatic SE -phred33 ${fastq} ${sample}_trimmed.fastq.gz \
        ILLUMINACLIP:${adapters}:2:30:10 \
        LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 \
        2> ${sample}_trim.log
    """ 
    
    stub:
    """
    touch ${sample}_stub_trim.log
    touch ${sample}_stub_trimmed.fastq.gz
    """
}
