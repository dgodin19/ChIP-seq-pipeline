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
    # Run findPeaks
    findPeaks ${ip_tags} -style factor -o auto -i ${control_tags}
    
    # Check if peaks file exists
    echo "Checking peaks file:"
    ls -l ${ip_tags}/peaks.txt
    
    # Copy the automatically generated peaks file to the expected output name
    cp ${ip_tags}/peaks.txt ${rep}_peaks.txt
    
    # Verify copied file
    echo "Copied peaks file:"
    ls -l ${rep}_peaks.txt
    """

    stub:
    """
    echo "# Chromosome\tStart\tEnd\tPeak Name\tScore" > ${rep}_peaks.txt
    echo "chr1\t1000\t2000\tPeak1\t100" >> ${rep}_peaks.txt
    """
}