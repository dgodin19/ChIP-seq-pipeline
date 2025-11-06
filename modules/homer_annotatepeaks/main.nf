#!/usr/bin/env nextflow

process ANNOTATE {
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir params.outdir, mode: "copy", pattern: '*.txt'
    label 'process_medium'

    input:
    path filtered_bed
    path genome
    path gtf

    output:
    path('annotated_peaks.txt')
    path('annotate_log.txt')

    script:
    """
    # Check input files
    echo "Input BED file:"
    cat ${filtered_bed}
    echo "Number of peaks:"
    wc -l ${filtered_bed}

    echo "Genome file first lines:"
    head -n 5 ${genome}

    echo "GTF file first lines:"
    head -n 5 ${gtf}

    # Convert BED to HOMER peak file format
    # Ensure 6 columns: PeakID, chr, start, end, score, strand
    awk 'BEGIN{OFS="\t"} {print "Peak_"NR, \$1, \$2, \$3, \$5, \$6}' ${filtered_bed} > converted_peaks.txt

    # Run annotation with verbose output
    annotatePeaks.pl converted_peaks.txt ${genome} \
    -gtf ${gtf} \
    -ann_type basicInfo \
    -noHeader > annotated_peaks.txt 2> annotate_log.txt

    # Check output
    echo "Annotation output:"
    head -n 5 annotated_peaks.txt
    wc -l annotated_peaks.txt

    # Show any errors or logs
    cat annotate_log.txt
    """

    stub:
    """
    echo -e "chr\tstart\tend\tpeakID\tscore\tstrand\tannotation" > annotated_peaks.txt
    echo -e "chr1\t1000\t2000\tPeak1\t0\t+\tgene1" >> annotated_peaks.txt
    touch annotate_log.txt
    """
}