nextflow.enable.dsl=2

workflow METADATA {
    
    take:
        f
        
    main:
        fileTuple = f.map{ [ [ id: it.simpleName, baseName: it.baseName, size: it.size(), folder: it.parent, fileType: it.extension, fullFile: it ], it ] }

    emit:
        fileTuple

}

process readCount {
    input:
        path fastq
    
    output:
        stdout

    script:
    """
        zcat ${fastq} | awk 'END {print NR/4}'
    """
}

workflow moduleTest {
    // METADATA(Channel.fromPath('README.md')).view()
    readCount('/scratch/vpagano/play/GIAB_NA12878_1_CL_Whole_C1_TPFWG_Y_1.fastq.gz').splitCsv(sep: ' ').view()
}