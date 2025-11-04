#!/usr/bin/env nextflow

process PLOTPROFILE {
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.png'
	label 'process_medium'
    
    input:
    path(compute_matrix)

    output:
    path('signal_coverage.png')

    script:
    """
    plotProfile -m $compute_matrix -o signal_coverage.png
    """


    stub:
    """
    touch signal_coverage.png
    """
}