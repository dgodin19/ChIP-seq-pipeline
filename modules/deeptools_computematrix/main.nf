#!/usr/bin/env nextflow

process COMPUTEMATRIX {
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.gz'
	label 'process_medium'

    input:
    val(bigwigs) 
    path(bed) 
    val(window)

    output:
    path('matrix.gz')

    script:

    """
    computeMatrix scale-regions \
        -S ${bigwigs.join(' ')} \
        -R ${bed} \
        --beforeRegionStartLength ${window} \
        --afterRegionStartLength ${window} \
        --regionBodyLength ${window} \
        -o matrix.gz
    """

    stub:
    """
    touch matrix.gz
    """
}