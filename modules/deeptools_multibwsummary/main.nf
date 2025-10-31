#!/usr/bin/env nextflow

process MULTIBWSUMMARY {
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.npz'
	label 'process_medium'

    input:
    path bigwigs

    output:
    path('bw_all.npz')

    script:
    """
    multiBigwigSummary bins -b ${bigwigs.join(' ')} -o bw_all.npz
    """
    stub:
    """
    touch bw_all.npz
    """
}