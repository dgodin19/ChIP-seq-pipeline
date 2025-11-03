#!/usr/bin/env nextflow

process FINDPEAKS {

    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.txt'
    label 'process_medium'
    
    input:
    tuple(
        val(rep),
        val(ip_sample), val(name), path(ip_tags),
        val(control_sample), val(name2), path(control_tags)
    )

    output:
    tuple val(rep), val(ip_sample), path("${rep}_peaks.txt"), emit: peaks

    script:

    """
    findPeaks ${ip_tags} -style chipseq -i ${control_tags} > ${rep}_peaks.txt
    """

    stub:
    """
    touch ${rep}_peaks.txt
    """
}


