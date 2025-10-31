#!/usr/bin/env nextflow

process BAMCOVERAGE {
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.bw'
	label 'process_medium'

    input:
    tuple val(sample), val(name), path(sorted_bam), path(sorted_bam_bai)

    output:
    tuple val(sample), val(name), path("${sample}.bw"), emit:bigwig
    script:
    """
    bamCoverage \
        -b ${sorted_bam} \
        -o ${sample}.bw \
        --binSize 10 \
        --normalizeUsing CPM
    """

    stub:
    """
    touch ${sample}.bw
    """
}