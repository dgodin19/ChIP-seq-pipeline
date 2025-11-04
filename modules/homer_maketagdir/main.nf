#!/usr/bin/env nextflow

process TAGDIR {
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.tags'
    label 'process_medium'

    input:
    tuple val(sample), val(name), path(bam)

    output:
    tuple val(sample), val(name), path("${sample}_tags"), emit: tags

    script:
    """
    # Verbose tag directory creation
    echo "Creating Tag Directory for ${sample}"
    echo "BAM File: ${bam}"
    
    # Create tag directory with additional parameters
    makeTagDirectory ${sample}_tags ${bam} -format sam

    # Verify tag directory contents
    echo "Tag Directory Contents:"
    ls -la ${sample}_tags

    # Verify tags.txt exists and show first few lines
    if [ -f ${sample}_tags/tags.txt ]; then
        echo "Tags.txt contents:"
        head -n 5 ${sample}_tags/tags.txt
        wc -l ${sample}_tags/tags.txt
    else
        echo "tags.txt not found in tag directory"
    fi
    """

    stub:
    """
    mkdir ${sample}_tags
    touch ${sample}_tags/tags.txt
    echo "chr1\t1000\t+\t1" > ${sample}_tags/tags.txt
    """
}