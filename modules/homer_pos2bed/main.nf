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
    # Verbose logging of input file
    echo "Input Peak File Contents:"
    cat ${reps_txt}

    # Check if the file contains any peak information
    pos2bed.pl ${reps_txt} > ${rep}_peaks.bed

    # Show converted file
    echo "Converted BED File Contents:"
    cat ${rep}_peaks.bed
    wc -l ${rep}_peaks.bed
    """
}


