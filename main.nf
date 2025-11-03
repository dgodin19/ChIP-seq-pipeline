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

workflow {

    
    //Here we construct the initial channels we need
    
    Channel.fromPath(params.subsampled_samplesheet)
    | splitCsv( header: true )
    | map{ row -> tuple(row.name, file(row.path)) }
    | set { read_ch }
    /*read_ch.view()*/

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
    .flatten()
    .unique()
    .collect()
    /*multiqc_ch.view()*/
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

    ip_ch = TAGDIR.out.tags
        .filter { it[0].startsWith("IP") }
        .map { sample, name, path ->
            def rep = sample.find(/rep\d+/)
            [rep, sample, name, path]
        }

    input_ch = TAGDIR.out.tags
        .filter { it[0].startsWith("INPUT") }
        .map { sample, name, path ->
            def rep = sample.find(/rep\d+/)
            [rep, sample, name, path]
        }

   
    FINDPEAKS( ip_ch.join(input_ch) )

    POS2BED(FINDPEAKS.out.peaks)

     /*find_peaks_input = ip_ch
        .join(input_ch)
        .map { rep, ip, ctrl ->
            [rep, ip[1], ip[2], ip[3], ctrl[1], ctrl[2], ctrl[3]]
        }

    find_peaks_input.view { it }
    */

}