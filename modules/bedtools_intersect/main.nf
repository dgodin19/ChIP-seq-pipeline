#!/usr/bin/env nextflow

process BEDTOOLS_INTERSECT {
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.bed'
    label 'process_medium'

    input:
    tuple path(bed1), path(bed2)

    output:
    path "intersect.bed"

    script:
    """
    # Check input file sizes
    echo "Bed1 file size:"
    wc -l ${bed1}
    echo "Bed2 file size:"
    wc -l ${bed2}

    # Only intersect if both files have content
    if [ -s ${bed1} ] && [ -s ${bed2} ]; then
        bedtools intersect -a ${bed1} -b ${bed2} > intersect.bed
    else
        echo "# No intersection possible" > intersect.bed
    fi

    # Show intersection results
    cat intersect.bed
    wc -l intersect.bed
    """

    stub:
    """
    # Create a stub intersect.bed file
    echo "chr1\t1000\t2000\tStub_Peak1\t0\t+" > intersect.bed
    """
}