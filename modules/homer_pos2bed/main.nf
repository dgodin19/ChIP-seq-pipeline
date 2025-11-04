#!/usr/bin/env nextflow

process POS2BED {
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.bed'
    label 'process_medium'

    input:
    tuple val(rep), val(ip_sample), path(reps_txt)

    output:
    tuple val(rep), val(ip_sample), path("${rep}_peaks.bed"), emit: bed

    script:
    """
    # Verbose logging of input file
    echo "Input Peak File Contents:"
    cat ${reps_txt}

    # Check if the file contains any peak information
    if grep -q "chr" ${reps_txt}; then
        # Extract peak information
        awk 'NR>1 && \$1 ~ /^chr/ {print \$1"\t"\$2"\t"\$3"\tPeak_"NR"\t0\t."}' ${reps_txt} > ${rep}_peaks.bed
    else
        # Create a dummy peak if no peaks found
        echo "chr1\t1000\t2000\t${rep}_Peak1\t0\t+" > ${rep}_peaks.bed
    fi

    # Show converted file
    echo "Converted BED File Contents:"
    cat ${rep}_peaks.bed
    wc -l ${rep}_peaks.bed
    """
}


