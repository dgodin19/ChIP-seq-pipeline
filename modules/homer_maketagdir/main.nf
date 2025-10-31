#!/usr/bin/env nextflow

process TAGDIR {
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.tags'
    label 'process_medium'

    input:
    tuple val(sample), val(name), path(bam)

    output:
    tuple val(sample), val(name), path("${sample}_tags"), emit: tags

    script:
    """
    mkdir -p ${sample}_tags
    makeTagDirectory ${sample}_tags ${bam}
    """

    stub:
    """
    mkdir ${sample}_tags
    """
}
