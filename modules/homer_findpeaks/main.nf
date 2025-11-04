#!/usr/bin/env nextflow

process FINDPEAKS {
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.txt'
    label 'process_medium'
    
    input:
    tuple(
        val(rep),
        val(ip_sample), val(name), path(ip_tags),
        val(control_sample), val(name2), path(control_tags)
    )

    output:
    tuple val(rep), val(ip_sample), path("${rep}_peaks.txt"), emit: peaks

    script:
    """
    # Detailed diagnostics of tag directories
    echo "IP Tags Directory Path: ${ip_tags}"
    echo "Control Tags Directory Path: ${control_tags}"

    # Count total reads in tag directories
    echo "IP Tags Total Reads:"
    grep -c "chr" ${ip_tags}/tags.txt || echo "No reads found in IP tags"

    echo "Control Tags Total Reads:"
    grep -c "chr" ${control_tags}/tags.txt || echo "No reads found in control tags"

    # Try peak calling with multiple strategies
    findPeaks ${ip_tags} -style chipseq -i ${control_tags} -o ${rep}_peaks.txt \
        -L 4 \
        -fdr 0.001 \
        -minTagThreshold 10 \
        -tbp 1 \
        -size 300 \
        -res 50

    # If no peaks found, create a detailed log
    if [ ! -s ${rep}_peaks.txt ]; then
        echo "# No peaks found. Detailed diagnostics:" > ${rep}_peaks.txt
        echo "# IP Tags Total Reads: \$(grep -c 'chr' ${ip_tags}/tags.txt)" >> ${rep}_peaks.txt
        echo "# Control Tags Total Reads: \$(grep -c 'chr' ${control_tags}/tags.txt)" >> ${rep}_peaks.txt
        echo "# Debug Information:" >> ${rep}_peaks.txt
        cat findpeaks_debug.txt >> ${rep}_peaks.txt
    fi

    # Always show debug information
    cat findpeaks_debug.txt
    """

    stub:
    """
    echo "# Chromosome\tStart\tEnd\tPeak Name\tScore" > ${rep}_peaks.txt
    echo "chr1\t1000\t2000\tPeak1\t100" >> ${rep}_peaks.txt
    """
}