include { METADATA } from '../metadata'

workflow PACBIO_DEEPVARIANT {

    take:
        bam
        bamIndex

    main:
        bam = METADATA(bam)
        make_examples(bam, bamIndex, params.reference, params.referenceIndex, Channel.of(0..params.make_examplesInstances - 1))
        call_variants(bam, make_examples.out.collect())
}

process make_examples {

    input:
        tuple val(meta), path(bam)
        path bamIndex
        val ref
        val refIndex
        each instance

    output:
        path "*.gz"

    cpus 1
    time '2h'
    container params.dvContainer
    
    script:
    """
    /opt/deepvariant/bin/make_examples \
        --norealign_reads \
        --vsc_min_fraction_indels 0.12 \
        --pileup_image_width 199 \
        --track_ref_reads \
        --phase_reads \
        --partition_size=25000 \
        --max_reads_per_partition=600 \
        --alt_aligned_pileup=diff_channels \
        --add_hp_channel \
        --sort_by_haplotypes \
        --parse_sam_aux_fields \
        --min_mapping_quality=1 \
        --mode calling \
        --ref ${ref} \
        --reads ${bam} \
        --examples ${meta.id}.examples.tfrecord@${params.make_examplesInstances}.gz \
        --gvcf ${meta.id}.gvcf.tfrecord@${params.make_examplesInstances}.gz \
        --task ${instance}
    """
}

process call_variants {

    input:
        tuple val(meta), path(bam)
        path exampleFiles

    output:
        file "*.gz"


    cpus 8
    queue 'gpu-scavenge'
    time '4h'
    memory '200GB'
    clusterOptions '--gres gpu:1 -N 1 --tasks-per-node 1'
    container params.dvContainer

    script:
    println(meta)
    """
    /opt/deepvariant/bin/call_variants \
        --outfile ${meta.id}.cvo.tfrecord.gz \
        --examples "${meta.id}.examples.tfrecord@${params.make_examplesInstances}.gz" \
        --checkpoint "${params.deepvariantModel}"
    """
}