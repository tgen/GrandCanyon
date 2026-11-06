---
layout: default
title: Tools Index
parent: Reference
nav_order: 2
---

# Tools Index

An index of the bioinformatics tools used in the GrandCanyon pipeline, organized by workflow stage. Most optional stages are enabled via the `tasks` configuration object — no stage is installed with a fixed "default" recommendation; which tools run for a project is fully determined by the `tasks` keys supplied in the configuration JSON (see the [Configuration Guide](../../getting-started/configuration/)).

## Table of Contents

- [Read Trimming](#read-trimming)
- [Alignment](#alignment)
- [Constitutional Variant Calling](#constitutional-variant-calling)
- [Joint Calling and Phasing](#joint-calling-and-phasing)
- [Somatic Variant Calling](#somatic-variant-calling)
- [Tumor-Only Variant Calling](#tumor-only-variant-calling)
- [Structural Variants](#structural-variants)
- [Copy Number Analysis](#copy-number-analysis)
- [Assembly](#assembly)
- [Assembly QC](#assembly-qc)
- [RNA-seq](#rna-seq)
- [Quality Control](#quality-control)
- [Annotation](#annotation)
- [Somatic Metrics](#somatic-metrics)
- [Utility](#utility)
- [Methylation](#methylation)

## Read Trimming

| Tool | Purpose | Applies To |
|------|---------|------------|
| [FastP](../tool-descriptions/#fastp) | Adapter and quality trimming of FASTQ input | DNA, RNA |

## Alignment

| Tool | Purpose | Applies To |
|------|---------|------------|
| [BWA-MEM2](../tool-descriptions/#bwa-mem2) | DNA read alignment | Genome, exome |
| [MiniBWA](../tool-descriptions/#minibwa) | Fast alternative DNA alignment | Genome, exome |
| [STAR](../tool-descriptions/#star) | Splice-aware RNA alignment and quantification | RNA |
| [Minimap2](../tool-descriptions/#minimap2) | Long-read alignment (PacBio HiFi, ONT) | Genome, RNA (long-read) |
| [VG Giraffe](../tool-descriptions/#vg-giraffe) | Pangenome-aware short-read alignment | Genome (pangenome) |

## Constitutional Variant Calling

Runs on `subGroup: constitutional` DNA samples. SNV/indel callers:

| Tool | Purpose | Applies To |
|------|---------|------------|
| [GATK HaplotypeCaller](../tool-descriptions/#gatk-haplotypecaller) | Germline SNV/indel calling (GVCF + GenotypeGVCFs) | Genome, exome |
| [DeepVariant](../tool-descriptions/#deepvariant) | Deep-learning SNV/indel caller | Short-read |
| [DeepVariant (Pangenome)](../tool-descriptions/#deepvariant-pangenome) | Long-read optimized SNV/indel caller | Long-read |
| [Clair3](../tool-descriptions/#clair3) | Neural network SNV/indel caller | Short-read and long-read |
| [ClairS](../tool-descriptions/#clairs) | Long-read optimized SNV/indel caller | Long-read |
| [Strelka2](../tool-descriptions/#strelka2) | Constitutional SNV/indel caller |
| [VarDict](../tool-descriptions/#vardict) | Low-frequency / targeted variant caller |

## Joint Calling and Phasing

| Tool | Purpose |
|------|---------|
| [DeepTrio](../tool-descriptions/#deeptrio) | Trio-aware deep-learning joint calling |
| [GLnexus](../tool-descriptions/#glnexus) | Cohort-level joint genotyping of gVCFs |
| [Somalier](../tool-descriptions/#somalier) | Relatedness and sample-identity QC for joint calling |
| [WhatsHap](../tool-descriptions/#whatshap) | Read-backed phasing (long-read) |

## Somatic Variant Calling

Runs on tumor-normal pairs. SNV/indel callers merged by VcfMerger2:

| Tool | Purpose |
|------|---------|
| [Mutect2](../tool-descriptions/#mutect2) | GATK somatic SNV/indel caller |
| [DeepSomatic](../tool-descriptions/#deepsomatic) | Deep-learning somatic SNV/indel caller |
| [Strelka2](../tool-descriptions/#strelka2) | Somatic SNV/indel caller |
| [Lancet2](../tool-descriptions/#lancet2) | Somatic joint SNV/indel caller |
| [VarDict](../tool-descriptions/#vardict) | Low-VAF somatic caller |
| [VcfMerger2](../tool-descriptions/#vcfmerger2) | Multi-caller consensus merging (INFO/CC) |

## Tumor-Only Variant Calling

Runs on `subGroup: tumor` samples without a matched constitutional sample in the project:

| Tool | Purpose |
|------|---------|
| [DeepVariant](../tool-descriptions/#deepvariant) | Tumor-only SNV/indel caller |
| [Mutect2](../tool-descriptions/#mutect2) | Tumor-only mode against panel-of-normals |
| [Strelka2](../tool-descriptions/#strelka2) | Tumor-only SNV/indel caller |
| [Lancet2](../tool-descriptions/#lancet2) | Tumor-only SNV/indel caller |
| [VarDict](../tool-descriptions/#vardict) | Tumor-only SNV/indel caller |
| [VcfMerger2](../tool-descriptions/#vcfmerger2) | Multi-caller consensus merging |

## Structural Variants

| Tool | Purpose | Context |
|------|---------|---------|
| [Manta](../tool-descriptions/#manta) | Deletions, duplications, inversions, translocations | Constitutional, somatic, tumor-only |
| [Sniffles](../tool-descriptions/#sniffles) | SV caller optimized for long-read data | Long-read |
| [cuteSV](../tool-descriptions/#cutesv) | Long-read SV caller | Long-read |
| [PBSV](../tool-descriptions/#pbsv) | Long-read SV caller | Long-read |
| [Dysgu](../tool-descriptions/#dysgu) | Long-read SV caller | Long-read |
| [Savana](../tool-descriptions/#savana) | Long-read somatic SV caller | Long-read |
| [Severus](../tool-descriptions/#severus) | Somatic SV caller (short- and long-read) | Somatic |
| [tRGT](../tool-descriptions/#trgt) | Tandem repeat genotyper | Long-read |

## Copy Number Analysis

| Tool | Purpose | Context |
|------|---------|---------|
| [GATK-CNV](../tool-descriptions/#gatk-cnv) | Read-depth CNV calling | Constitutional, somatic, tumor-only |
| [CNVkit](../tool-descriptions/#cnvkit) | CNV calling from targeted data | Exome, panels |
| [ASCAT](../tool-descriptions/#ascat) | Allele-specific CNV, purity and ploidy | Somatic |
| [iChorCNA](../tool-descriptions/#ichorcna) | Low-purity CNV and tumor fraction | Constitutional genome |
| [Spectre](../tool-descriptions/#spectre) | Low-pass genome CNV calling | Genome (low-pass) |
| [Wakhan](../tool-descriptions/#wakhan) | Maternal fetal fraction and fetal trisomy | Genome |
| [HiFiCNV](../tool-descriptions/#hificnv) | CNV calling from PacBio HiFi data | Genome (long-read) |
| [AmpliconArchitect](../tool-descriptions/#amplicon-architect) | Amplicon and ecDNA reconstruction | Genome |
| [CNVear](../tool-descriptions/#cnvear) | CNV segment annotation (gene/FISH probe overlap) | Runs on GATK-CNV segments |
| [b_pure](../tool-descriptions/#b-pure) | B-cell purity estimation from segments | Myeloma |
| [tHReD](../tool-descriptions/#thred) | Homologous recombination deficiency (HRD) scoring | On segments |

## Assembly

| Tool | Purpose |
|------|---------|
| [Flye](../tool-descriptions/#flye) | Long-read de novo assembly |
| [HiFiASM](../tool-descriptions/#hifiasm) | Haplotype-resolved HiFi assembly |
| [Verkko](../tool-descriptions/#verkko) | Chromosome-scale assembly (HiFi + ONT + Hi-C) |
| [Shasta](../tool-descriptions/#shasta) | Ultra-long ONT assembly |
| [Yak](../tool-descriptions/#yak) | K-mer profiling for assembly QC |

## Assembly QC

| Tool | Purpose |
|------|---------|
| [assembly-stats](../tool-descriptions/#assembly-stats) | Contig counts, N50, total length |
| [Compleasm](../tool-descriptions/#compleasm) | Gene completeness (BUSCO-based) |
| [Merqury](../tool-descriptions/#merqury) | K-mer consensus QV and completeness |
| [QUAST](../tool-descriptions/#quast) | Assembly quality assessment |

## RNA-seq

| Tool | Purpose | Applies To |
|------|---------|------------|
| [STAR](../tool-descriptions/#star) | Alignment and gene counts | RNA |
| [Salmon](../tool-descriptions/#salmon) | Alignment-free transcript quantification |
| [STAR-Fusion](../tool-descriptions/#star-fusion) | Fusion transcript detection |
| [CTAT-LR](../tool-descriptions/#ctat-lr) | Long-read fusion detection |
| [Subread](../tool-descriptions/#subread) | featureCounts gene quantification (optional) |
| [IsoSeq](../tool-descriptions/#isoseq) | Full-length transcript isoform discovery | Long-read RNA |
| [Flair](../tool-descriptions/#flair) | Isoform identification and AS analysis | Long-read RNA |
| [IsoQuant](../tool-descriptions/#isoquant) | Isoform detection and quantification | Long-read RNA |
| [Oarfish](../tool-descriptions/#oarfish) | Alignment-free long-read quantification | Long-read RNA |
| [Pbpigeon](../tool-descriptions/#pbpigeon) | Isoform classification | Long-read RNA |
| [SQANTI3](../tool-descriptions/#sqanti3) | Isoform quality analysis | Long-read RNA |

## Quality Control

| Tool | Purpose |
|------|---------|
| [MultiQC](../tool-descriptions/#multiqc) | Aggregated QC report |
| [Samtools stats](../tool-descriptions/#samtools) | Alignment statistics |
| [GATK CollectMultipleMetrics](../tool-descriptions/#gatk-collectmultiplemetrics) | Alignment/insert/quality metrics |
| [VerifyBamID2](../tool-descriptions/#verifybamid2) | Sample identity and contamination |
| [FreeBayes](../tool-descriptions/#freebayes) | Constitutional sex check via genotyping |
| [SnpSniffer](../tool-descriptions/#snpsniffer) | Genotype concordance (project-level) |
| [Riker](../tool-descriptions/#riker) | Alignment QC statistics |

## Annotation

| Tool | Purpose |
|------|---------|
| [VEP](../tool-descriptions/#vep) | Variant annotation (consequences, population databases) |
| [bcftools annotate](../tool-descriptions/#bcftools) | Add/update annotations (IDs, contig mapping) |

## Somatic Metrics

| Tool | Purpose |
|------|---------|
| [TGen Mutation Burden](../tool-descriptions/#tgen-mutation-burden) | Tumor mutational burden (TMB) |
| [MSISensor](../tool-descriptions/#msisensor) | Microsatellite instability (MSI) |
| [SigProfilerAssignment](../tool-descriptions/#sigprofiler) | Mutational signature assignment |
| [tucon](../tool-descriptions/#tucon) | Variant and TOPMed-overlap counts |

## Utility

| Tool | Purpose |
|------|---------|
| [bcftools](../tool-descriptions/#bcftools) | VCF/BCF manipulation and filtering |
| [bedtools](../tool-descriptions/#bedtools) | Genome interval arithmetic |
| [samtools](../tool-descriptions/#samtools-bcftools) | BAM/CRAM manipulation |

## Methylation

| Tool | Purpose |
|------|---------|
| [ModKit](../tool-descriptions/#modkit) | CpG methylation from long-read data |
| [RASTair](../tool-descriptions/#rastair) | Phased methylation extraction |
| [methbat](../tool-descriptions/#methbat) | CpG methylation analysis |

## See Also

- [Tool Descriptions](../tool-descriptions/) - detailed catalog
- [Configuration Guide](../../getting-started/configuration/) - task toggles
- [Output Structure](../../outputs/) - where results are written
