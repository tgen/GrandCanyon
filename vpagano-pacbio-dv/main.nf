include { PACBIO_DEEPVARIANT } from './modules/deepvariant'

workflow {
    PACBIO_DEEPVARIANT(Channel.fromPath('/scratch/vpagano/grandcanyon/COLO829BL_chm13_chr13.bam'), Channel.fromPath('/scratch/vpagano/grandcanyon/COLO829BL_chm13_chr13.bam.bai'))
}