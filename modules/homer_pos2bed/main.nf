#!/usr/bin/env nextflow

process POS2BED {

    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.txt'
    label 'process_medium'

    input:
    tuple val(rep), val(ip_sample), path(reps_txt)

    output:
    


    stub:
    """
    touch ${homer_txt.baseName}.bed
    """
}


