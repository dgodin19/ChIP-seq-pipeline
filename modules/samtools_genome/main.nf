#!/usr/bin/env nextflow

process SAMTOOLS_GENOME {
    container 'ghcr.io/bf528/samtools:latest'
    label 'process_medium'
    
    input:
    path genome

    output:
    path "${genome}.fai", emit: genome_idx

    script:
    """
    samtools faidx ${genome}
    """
}
