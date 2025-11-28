# ChIP-seq Data Processing and Peak Analysis Pipeline

This Nextflow pipeline automates the processing, quality assessment, alignment, coverage analysis, peak calling, and annotation of ChIP-seq datasets. It integrates flexible short-read quality control, alignment to reference genomes, downstream coverage and QC reporting, robust peak detection, and comprehensive annotation, supporting multi-replicate and multi-condition experiments.
Modules Used

The workflow is modular, with each major process defined in the modules/ folder:
```
    TRIMMOMATIC (TRIM): Adapter/trimming of sequencing reads
    FASTQC: Read-level quality control
    BOWTIE2_BUILD: Reference genome indexing
    BOWTIE2_ALIGN: Alignment of reads to reference
    SAMTOOLS_FLAGSTAT: Alignment statistics
    SAMTOOLS_SORT: BAM sorting and indexing
    SAMTOOLS_IDX: BAM indexing
    DEEPCOVERAGE (BAMCOVERAGE): Coverage profiling (bigWig generation)
    MULTIQC: Aggregated sample-level QC reports
    DEEPMULTIBWSUMMARY (MULTIBWSUMMARY): multi bigWig summary for downstream correlation/profile analysis
    DEEPTOOLSCORRELATION (PLOTCORRELATION): Correlation plots across samples
    DEEPCOMPUTEMATRIX (COMPUTEMATRIX): Matrix for meta-profile analyses
    DEEPPLOTPROFILE (PLOTPROFILE): Signal profile plots
    HOMER_MAKETAGDIR (TAGDIR): Tag directory for peak calling (per sample/replicate)
    HOMER_FINDPEAKS (FINDPEAKS): Peak detection in ChIP-seq data
    HOMER_POS2BED (POS2BED): Conversion from HOMER peak output to BED format
    BEDTOOLS_INTERSECT/BEDTOOLS_REMOVE: Bed-level intersection and removal (e.g., blacklist filtering)
    SAMTOOLS_GENOME: Genome indexing and auxiliary operations
    BEDTOOLS_EXTEND (EXTEND_PEAKS): Extension of peak regions to user-defined windows
    HOMER_ANNOTATEPEAKS (ANNOTATE): Genomic annotation of detected peaks
    HOMER_FINDMOTIFSGENOME (FIND_MOTIFS_GENOME): Motif discovery within peak regions
```
# Folder Structure

    main.nf: Central Nextflow pipeline script with workflow orchestration
    modules/: Contains all individual module definitions (processes)
    (Optional: configs/, data/, results/ folders, as required by your analysis setup)

# Workflow Steps

    Sample Sheet Ingestion: Input channel creation via CSV specifying sample identifiers and file paths.
    Preprocessing: Adapter removal and quality filtering (TRIM), quality assessment (FASTQC).
    Reference Preparation: Bowtie2 indexing (BOWTIE2_BUILD), align reads (BOWTIE2_ALIGN).
    BAM Post-processing: Sorting, indexing, flagstat metrics (SAMTOOLS_*).
    Coverage & QC: Generate bigWig coverage (BAMCOVERAGE), aggregate MultiQC reports (MULTIQC), correlation and profile plotting (MULTIBWSUMMARY, PLOTCORRELATION, COMPUTEMATRIX, PLOTPROFILE).
    Peak Calling: Tag directories (TAGDIR), peak detection (FINDPEAKS).
    Peak Processing: Conversion to BED (POS2BED), replicates merging, intersection, and blacklist removal (BEDTOOLS_INTERSECT, BEDTOOLS_REMOVE).
    Peak Extension & Annotation: Extend peak regions (EXTEND_PEAKS), annotate to genes (ANNOTATE), discover motifs (FIND_MOTIFS_GENOME).
    Outputs: Quality reports, processed BAMs, bigWig coverage, peak BEDs, annotation tables, motif results.
