#!/usr/bin/env nextflow

process BEDTOOLS_REMOVE {
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.bed'
    label 'process_medium'

    input:
    path intersect_bed 
    path blacklist

    output:
    path('repr_peaks_filtered.bed')

    script:
    """
    # Remove peaks that overlap with blacklist regions
    bedtools intersect -v -a ${intersect_bed} -b ${blacklist} > repr_peaks_filtered.bed
    """

    stub:
    """
    # Create a stub filtered peaks file with a few example peaks
    echo -e "chr1\t1000\t2000\tPeak1\t0\t+\nchr2\t3000\t4000\tPeak2\t0\t+" > repr_peaks_filtered.bed
    """
}