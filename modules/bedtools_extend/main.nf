#!/usr/bin/env nextflow

process EXTEND_PEAKS {
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.bed'
    
    input:
    path filtered_bed

    output:
    path('extended_peaks.bed')

    script:
    """
    # Extend peaks by 500 base pairs on each side
    bedtools slop -i ${filtered_bed} -g <(cut -f1-2 ${filtered_bed} | sort -k1,1 -k2,2n | uniq) -b 500 > extended_peaks.bed
    """

    stub:
    """
    echo -e "chr1\t1000\t2000\tPeak1\t0\t+" > extended_peaks.bed
    """
}
