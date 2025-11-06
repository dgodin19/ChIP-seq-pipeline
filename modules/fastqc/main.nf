#!/usr/bin/env nextflow

process FASTQC {
    container 'ghcr.io/bf528/fastqc:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.{html,zip}'
    label 'process_high'

    input:
    tuple val(sample), path(fastq)

    output:
    tuple val(sample), path('*_fastqc.html'), emit: html
    tuple val(sample), path('*_fastqc.zip'), emit: zip

    script:
    """
    fastqc $fastq -t $task.cpus
    """

    stub:
    """
    touch ${sample}_fastqc.html
    touch ${sample}_fastqc.zip
    """
}


