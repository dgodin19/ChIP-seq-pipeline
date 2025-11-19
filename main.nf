// Include your modules here
include {TRIM} from './modules/trimmomatic'
include {FASTQC} from './modules/fastqc'
include {BOWTIE2_BUILD} from './modules/bowtie2_build'
include {BOWTIE2_ALIGN} from './modules/bowtie2_align'
include {SAMTOOLS_FLAGSTAT} from './modules/samtools_flagstat'
include {SAMTOOLS_SORT} from './modules/samtools_sort'
include {SAMTOOLS_IDX} from './modules/samtools_idx'
include {BAMCOVERAGE} from './modules/deeptools_bamcoverage'
include {MULTIQC} from './modules/multiqc'
include {MULTIBWSUMMARY} from './modules/deeptools_multibwsummary'
include {PLOTCORRELATION} from './modules/deeptools_plotcorrelation'
include {COMPUTEMATRIX} from './modules/deeptools_computematrix'
include {PLOTPROFILE} from './modules/deeptools_plotprofile'
include {TAGDIR} from './modules/homer_maketagdir'
include {FINDPEAKS} from './modules/homer_findpeaks'
include {POS2BED} from './modules/homer_pos2bed'
include {BEDTOOLS_INTERSECT} from './modules/bedtools_intersect'
include {BEDTOOLS_REMOVE} from './modules/bedtools_remove'
include {ANNOTATE} from './modules/homer_annotatepeaks'
include {FIND_MOTIFS_GENOME} from './modules/homer_findmotifsgenome'
include {EXTEND_PEAKS} from './modules/bedtools_extend'
include {SAMTOOLS_GENOME} from './modules/samtools_genome'

workflow {

    
    //Here we construct the initial channels we need
    
    Channel.fromPath(params.samplesheet)
    | splitCsv( header: true )
    | map{ row -> tuple(row.name, file(row.path)) }
    | set { read_ch }
    

    TRIM(read_ch, params.adapter_fa)
    FASTQC(read_ch)
    BOWTIE2_BUILD(tuple("GRCh38", params.genome))
    BOWTIE2_ALIGN(TRIM.out.trim, BOWTIE2_BUILD.out.index)
    SAMTOOLS_FLAGSTAT(BOWTIE2_ALIGN.out.bam)
    SAMTOOLS_SORT(BOWTIE2_ALIGN.out.bam)
    SAMTOOLS_IDX(SAMTOOLS_SORT.out.sorted_bam)
    BAMCOVERAGE(SAMTOOLS_IDX.out.sorted_bam_bai)

   multiqc_ch = Channel
    .empty()
    .mix(TRIM.out.log.map { it[1] })  
    .mix(SAMTOOLS_FLAGSTAT.out.flagstat.map { it[2] }) 
    .mix(FASTQC.out.html.map { it[1] })
    .mix(FASTQC.out.zip.map { it[1] })  // Add FastQC zip files
    .flatten()
    .unique()
    .map { 
        println "MultiQC Input: $it"  // Debug print
        it 
    }
    .collect()

    MULTIQC(multiqc_ch)

    bigwig_summary = BAMCOVERAGE.out.bigwig.map { it[2] }.collect()
    MULTIBWSUMMARY(bigwig_summary)
    PLOTCORRELATION(MULTIBWSUMMARY.out)
    ip_bigwig_summary = BAMCOVERAGE.out.bigwig
    .filter { sample, name, bw -> sample.startsWith('IP') }
    .map { sample, name, bw -> bw }
    .collect()
    COMPUTEMATRIX(ip_bigwig_summary, params.ucsc_genes, params.window)
    PLOTPROFILE(COMPUTEMATRIX.out)

    TAGDIR(BOWTIE2_ALIGN.out.bam)
    TAGDIR.out.tags.view { "TAGDIR full output: $it" }

    ip_ch = TAGDIR.out.tags
        .filter { it[0].startsWith("IP") }
        .map { sample, name, path ->
            def rep = sample.find(/rep\d+/)
            [rep, sample, name, path]
        }
    ip_ch.view()

    input_ch = TAGDIR.out.tags
        .filter { it[0].startsWith("INPUT") }
        .map { sample, name, path ->
            def rep = sample.find(/rep\d+/)
            [rep, sample, name, path]
        }
    input_ch.view()
   
    FINDPEAKS( ip_ch.join(input_ch) )
    /*FINDPEAKS.out.peaks.view { "FINDPEAKS output: $it" }

    FINDPEAKS.out.peaks.map { rep, ip_sample, peaks_file ->
        println "FINDPEAKS Peak File (${rep}): ${peaks_file}"
        println "Peak File Contents:"
        peaks_file.readLines().each { println it }
        [rep, ip_sample, peaks_file]
    }*/

    peaks_bed = POS2BED(FINDPEAKS.out.peaks)
    peaks_bed.view { "POS2BED output: $it" }

    POS2BED.out.bed.view { "OUT: $it (${it.getClass()})" }

    combined_peaks = peaks_bed
        .toList()
        .map { peaks -> 
            [
                peaks[1][2],  // rep2 bed file
                peaks[0][2]   // rep1 bed file
            ]
        }

    combined_peaks.view()

    BEDTOOLS_INTERSECT(combined_peaks)

    BEDTOOLS_REMOVE(BEDTOOLS_INTERSECT.out, params.blacklist)
    BEDTOOLS_REMOVE.out
        .map { bed ->
            def lineCount = bed.readLines().size()
            println "Number of peaks after blacklist removal: $lineCount"
            bed
        }
        .set { filtered_peaks }
    
    // Diagnostic printing
    /*filtered_peaks.view { "Filtered Peaks File: $it" }*/
    SAMTOOLS_GENOME(params.genome)

    
    EXTEND_PEAKS(BEDTOOLS_REMOVE.out, SAMTOOLS_GENOME.out.genome_idx)
    
    
    ANNOTATE(EXTEND_PEAKS.out, params.genome, params.gtf)
    FIND_MOTIFS_GENOME(EXTEND_PEAKS.out, params.genome)
    
    // View outputs
    
    FIND_MOTIFS_GENOME.out[0].view { "Motifs Output: $it" }

    ANNOTATE.out[0].view { "Annotation Output:\n" + it.text }
    ANNOTATE.out[1].view { "Annotation Log:\n" + it.text }
    
}