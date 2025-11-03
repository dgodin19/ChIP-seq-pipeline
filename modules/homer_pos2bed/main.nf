#!/usr/bin/env nextflow

process POS2BED {

    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.bed'
    label 'process_medium'

    input:
    tuple val(rep), val(ip_sample), path(reps_txt)

    output:
    tuple val(rep), val(ip_sample), path("${rep}_peaks.bed"), emit: bed

    script:

    """
    pos2bed.pl ${reps_txt} > ${rep}_peaks.bed
    """

    stub:
    """
    touch ${rep}_peaks.bed
    """
}


