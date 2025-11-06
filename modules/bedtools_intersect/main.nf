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
    # Check input file contents
    echo "Bed1 file contents:"
    cat ${bed1}
    echo "Bed2 file contents:"
    cat ${bed2}

    # Convert to standard BED format with proper columns
    awk 'BEGIN{OFS="\t"} {print \$2, \$3-1, \$3, \$1, \$4, \$5}' ${bed1} > bed1_converted.bed
    awk 'BEGIN{OFS="\t"} {print \$2, \$3-1, \$3, \$1, \$4, \$5}' ${bed2} > bed2_converted.bed

    # Perform intersection
    bedtools intersect -a bed1_converted.bed -b bed2_converted.bed > intersect.bed
    
    # Show intersection results
    echo "Intersection results:"
    cat intersect.bed
    wc -l intersect.bed
    """

    stub:
    """
    # Create a stub intersect.bed file
    echo "chr1\t1000\t2000\tStub_Peak1\t0\t+" > intersect.bed
    """
}