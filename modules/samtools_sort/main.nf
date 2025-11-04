#!/usr/bin/env nextflow

process SAMTOOLS_SORT {

    container 'ghcr.io/bf528/samtools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.bam'
	label 'process_medium'

    input:
    tuple val(sample), val(name), path(bam)

    output:
    tuple val(sample), val(name), path("${sample}.sorted.bam"), emit: sorted_bam

    script:

    """
    samtools sort -o ${sample}.sorted.bam ${bam}
    """

    stub:
    """
    touch ${sample}.sorted.bam
    """
}