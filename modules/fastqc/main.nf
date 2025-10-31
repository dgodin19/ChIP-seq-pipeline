#!/usr/bin/env nextflow

process FASTQC {
	container 'ghcr.io/bf528/fastqc:latest'
	publishDir params.outdir, mode: "copy", pattern: '*.html'
	label 'process_low'

	input:
	tuple val(sample), path(fastq)

	output:
	tuple val(sample), path('*.zip'), emit: zip
	tuple val(sample), path('*.html'), emit: html

	script:
	"""
	fastqc $fastq -t $task.cpus
	"""

	stub:
	"""
	touch ${sample}_stub_fastqc.zip
	touch ${sample}_stub_fastqc.html
    """
	
}


