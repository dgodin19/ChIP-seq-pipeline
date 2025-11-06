#!/usr/bin/env nextflow

process FIND_MOTIFS_GENOME {
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.{txt,log}'
    label 'process_medium'

    input:
    path filtered_bed
    path genome

    output:
    path("motifs.txt")
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

    # Convert BED to proper format and extract sequences
    mkdir -p motif_output

    # Extract sequences for motif finding
    # Use -size 200 to get 200bp around peak center
    findMotifsGenome.pl ${filtered_bed} ${genome} motif_output \
        -size 200 \
        -len 8,10,12 \
        -preparse \
        -p ${task.cpus} 2>&1 | tee findMotifs.log

    # Check sequence extraction
    echo "Sequence extraction details:"
    cat motif_output/seq.info

    # Comprehensive directory and file checks
    echo "Motifs directory contents:"
    ls -la motif_output

    # Extract and process motifs
    if [ -f motif_output/homerMotifs.all.motifs ]; then
        echo "Motifs file found:"
        cat motif_output/homerMotifs.all.motifs > motifs.txt
        wc -l motifs.txt
    else
        echo "No motifs file found. Creating placeholder."
        echo "No motifs discovered" > motifs.txt
    fi

    # Always output the log
    cp findMotifs.log findMotifs.log
    """

    stub:
    """
    mkdir -p motif_output
    echo "Motif1\tA\tB\tC" > motifs.txt
    touch findMotifs.log
    """
}


