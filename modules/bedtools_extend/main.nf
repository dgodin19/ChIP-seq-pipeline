#!/usr/bin/env nextflow

process EXTEND_PEAKS {
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.bed'
    
    input:
    path filtered_bed
    path genome

    output:
    path('extended_peaks.bed')

    script:
    """
    # Extract first 6 columns (chr, start, end, name, score, strand)
    cut -f1-6 ${filtered_bed} | sort -k1,1 -k2,2n | uniq > clean_peaks.bed

    # Extend peaks by 500 base pairs on each side
    bedtools slop -i clean_peaks.bed -g ${genome} -b 500 > extended_peaks.bed
    """

    stub:
    """
    echo -e "chr1\t1000\t2000\tPeak1\t0\t+" > extended_peaks.bed
    """
}
