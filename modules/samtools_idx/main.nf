#!/usr/bin/env nextflow

process SAMTOOLS_IDX {

    container 'ghcr.io/bf528/samtools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.bam'
	label 'process_medium'

    input:
    tuple val(sample), val(name), path(sorted_bam)

    output:
    tuple val(sample), val(name), path(sorted_bam), path("${sorted_bam}.bai"), emit: sorted_bam_bai

    script:
    """
    samtools index ${sorted_bam}
    """

    stub:
    """
    touch ${sample_id}.sorted.bam.bai
    """
}