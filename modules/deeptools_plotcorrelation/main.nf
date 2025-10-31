#!/usr/bin/env nextflow

process PLOTCORRELATION {
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.png'
	label 'process_medium'

    input:
    path(matrix)

    output:
    path('correlation_plot.png')

    script:
    """
    plotCorrelation -in ${matrix} -c spearman -p heatmap -o correlation_plot.png
    """


    stub:
    """
    touch correlation_plot.png
    """
}






