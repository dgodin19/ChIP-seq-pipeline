#!/usr/bin/env nextflow

process FIND_MOTIFS_GENOME {
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir params.outdir, mode: "copy", pattern: '{motif_output,findMotifs.log}'
    label 'process_high'

    input:
    path filtered_bed
    path genome

    output:
    path("motif_output")
    path("findMotifs.log")

    script:
    """
    # Detailed input file checks
    echo "Input BED file contents:"
    cat ${filtered_bed}
    echo "Number of peaks:"
    wc -l ${filtered_bed}

    # Check genome file
    echo "Genome file first lines:"
    head -n 5 ${genome}

    # Create motif output directory
    mkdir -p motif_output

    # Run motif finding
    findMotifsGenome.pl ${filtered_bed} ${genome} motif_output \
        -size 200 \
        -len 8,10,12 \
        -preparse \
        -p ${task.cpus} 2>&1 | tee findMotifs.log
    """

    stub:
    """
    mkdir -p motif_output/homerResults
    mkdir -p motif_output/knownResults
    touch motif_output/homerMotifs.all.motifs
    touch motif_output/homerResults.html
    touch findMotifs.log
    """
}


