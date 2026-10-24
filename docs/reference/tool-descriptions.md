---
layout: default
title: Tool Descriptions
parent: Reference
nav_order: 3
---

# Tool Descriptions

A catalog of the bioinformatics tools used in the GrandCanyon pipeline, their roles, and the container versions they run from.

## Alignment Tools

### BWA-MEM2 {: #bwa-mem2 }

**Purpose:** DNA read alignment.

**Role in GrandCanyon:** The default DNA aligner for genome and exome samples. FASTQs are split into chunks, aligned with BWA-MEM2, marked for duplicates, and merged into a per-sample BAM/CRAM. Enabled with `*_alignment_dna_alignment_bwa`.

**Version:** 2.2.1 (`ghcr.io/tgen/containers/bwa_mem2_samtools:2.2.1-23080315`)

### MiniBWA {: #minibwa }

**Purpose:** Lightweight, fast DNA alignment.

**Role in GrandCanyon:** Alternative short-read aligner to BWA-MEM2, enabled with `*_alignment_dna_alignment_minibwa`. Produces the same per-sample BAM/CRAM outputs.

**Version:** 0.4 (`ghcr.io/tgen/containers/minibwa_samtools:0.4_1.21`)

### Minimap2 {: #minimap2 }

**Purpose:** Long-read alignment.

**Role in GrandCanyon:** Alignment tool for long-read data (e.g., PacBio, ONT). Minimap2 is the default aligner for long-read sequencing, enabled with `*_alignment_dna_alignment_minimap2` (DNA) or `RNA_alignment_rna_alignment_minimap2` (RNA), and supports specialized presets for different sequencing platforms (`-x map-hifi` for PacBio HiFi, `-x lr:hq` for Oxford Nanopore).

**Version:** 2.28 (`/home/tgenref/containers/minimap2-samtools_2.28_1.20.sif`)

### VG Giraffe {: #vg-giraffe }

**Purpose:** Pangenome-aware short-read aligner.

**Role in GrandCanyon:** Aligns short-read (Illumina) data to a pangenome graph reference using the Giraffe aligner from the VG toolkit. This produces alt-aware alignments that capture genetic variation in the reference graph. Enabled with `*_alignment_dna_alignment_vg_giraffe`.

**Version:** 1.76.1 (`ghcr.io/tgen/containers/vg_samtools:1.76.1_1.21`)

### STAR {: #star }

**Purpose:** Splice-aware RNA-seq alignment.

**Role in GrandCanyon:** Aligns RNA reads and produces gene-level counts (`quant/star`). The STAR index is selected from the read length. Enabled with `RNA_alignment_rna_alignment_STAR`.

**Version:** Provided by the pipeline STAR indexes; container-managed.

## Read Trimming

### FastP {: #fastp }

**Purpose:** FASTQ quality trimming and filtering.

**Role in GrandCanyon:** Optional input preprocessing enabled with `*_preprocessing_trim_reads`. Trims adapters and low-quality bases before alignment.

**Version:** 1.1.1 (`ghcr.io/tgen/fastp:1.1.1-tgen`)

## Constitutional Variant Callers

### GATK HaplotypeCaller {: #gatk-haplotypecaller }

**Purpose:** Germline SNV and indel calling.

**Role in GrandCanyon:** Constitutional calling via HaplotypeCaller (GVCF) followed by GenotypeGVCFs. Task keys: `*_variant_calling_snp_indel_caller_haplotypecaller` and `*_variant_calling_joint_variant_caller_gatk`.

**Version:** 4.5.0.0 (`broadinstitute/gatk:4.5.0.0`)

### DeepVariant {: #deepvariant }

**Purpose:** Deep-learning SNV and indel caller.

**Role in GrandCanyon:** Constitutional calling (and tumor-only calling). Enabled with `*_variant_calling_snp_indel_caller_deepvariant`. Uses the standard model for short-read data.

**Version:** 1.10.0 (`google/deepvariant:1.10.0-gpu`)

### DeepVariant (Pangenome) {: #deepvariant-pangenome }

**Purpose:** Deep-learning SNV and indel caller optimized for long-read data.

**Role in GrandCanyon:** Constitutional calling specifically for long-read data (e.g., PacBio HiFi, Oxford Nanopore). Enabled with `*_variant_calling_snp_indel_caller_deepvariant_pangenome`. The pangenome model improves accuracy for complex genomic regions.

**Version:** 1.10.0 (`google/deepvariant:pangenome_aware_deepvariant-1.10.0-gpu`)

### DeepSomatic {: #deepsomatic }

**Purpose:** Deep-learning somatic SNV and indel caller.

**Role in GrandCanyon:** Somatic calling for tumor-normal pairs, enabled with `*_variant_calling_snp_indel_caller_deepsomatic`.

**Version:** 1.10.0 (`google/deepvariant:deepsomatic-1.10.0-gpu`)

### DeepTrio {: #deeptrio }

**Purpose:** Deep-learning trio-aware germline variant caller.

**Role in GrandCanyon:** Joint germline calling from constitutional and parental samples, enabled with `*_variant_calling_joint_variant_caller_deeptrio`. Improves accuracy in low-confidence regions for trios.

**Version:** 1.10.0 (`google/deepvariant:deeptrio-1.10.0-gpu`)

### GLnexus {: #glnexus }

**Purpose:** Joint genotyping of gVCF cohorts.

**Role in GrandCanyon:** Joint genotyping across constitutional samples, enabled with `*_variant_calling_joint_variant_caller_glnexus`. producing one merged, cohort-level VCF with Somalier samples.

**Version:** 1.4.3 (`ghcr.io/dnanexus-rnd/glnexus:v1.4.3`)

### Somalier {: #somalier }

**Purpose:** Sample identity, relatedness, and ancestry QC.

**Role in GrandCanyon:** Joint variant calling QC across constitutional samples, enabled with `*_variant_calling_joint_variant_calling_somalier`, producing pairwise relatedness and identity checks.

**Version:** 0.3.1 (`brentp/somalier:v0.3.1`)

### Clair3 {: #clair3 }

**Purpose:** Deep-learning SNV and indel caller using neural networks.

**Role in GrandCanyon:** Constitutional and somatic calling. Enabled with `*_variant_calling_snp_indel_caller_clair3`. Clair3 excels at calling variants in difficult-to-sequence regions and supports both short-read and long-read data.

**Version:** 1.2.0 (`hkubal/clair3:v1.2.0`)

### ClairS {: #clairs }

**Purpose:** Deep-learning SNV and indel caller optimized for long-read sequencing.

**Role in GrandCanyon:** Constitutional and somatic calling specifically for long-read data (e.g., PacBio HiFi, Oxford Nanopore). Enabled with `*_variant_calling_snp_indel_caller_clairs`. ClairS is optimized to take advantage of the higher error rates and longer read lengths of long-read technologies.

**Version:** 0.4.3 (`hkubal/clairs:v0.4.3`)

### Strelka2 {: #strelka2 }

**Purpose:** SNV and indel caller.

**Role in GrandCanyon:** Runs in constitutional, somatic, and tumor-only modes. Enabled with `*_variant_calling_snp_indel_caller_strelka2`.

**Version:** 2.9.10 (`ghcr.io/tgen/containers/strelka:2.9.10-23080711`)

### VarDict {: #vardict }

**Purpose:** Sensitive variant caller for low-frequency variants and targeted regions.

**Role in GrandCanyon:** Constitutional, somatic, and tumor-only calling. Enabled with `*_variant_calling_snp_indel_caller_vardict`.

**Version:** 1.8.3 (`quay.io/biocontainers/vardict-java:1.8.3--hdfd78af_0`)

## Somatic Variant Callers

### Mutect2 {: #mutect2 }

**Purpose:** Somatic SNV and indel calling in tumor-normal pairs.

**Role in GrandCanyon:** Somatic calling (`*_variant_calling_snp_indel_caller_mutect2`) and tumor-only mode against panel-of-normals.

**Version:** 4.5.0.0 (`broadinstitute/gatk:4.5.0.0`)

### Lancet2 {: #lancet2 }

**Purpose:** Somatic joint SNV and indel caller.

**Role in GrandCanyon:** Somatic and tumor-only calling only (`*_variant_calling_snp_indel_caller_lancet2`). Not used for constitutional calling.

**Version:** 2.9.0 (`ghcr.io/tgen/containers/lancet2:2.9.0_main_7b33422eaa`)

### VcfMerger2 {: #vcfmerger2 }

**Purpose:** Merges VCFs from multiple callers into a unified, homogeneous format.

**Role in GrandCanyon:** Merges the enabled somatic (or tumor-only) callers and adds an `INFO/CC` field counting the callers that agree on each variant. Enabled with `*_variant_calling_merge_vcfs_vcfMerger2`.

**Version:** 0.10.3 (`ghcr.io/tgen/containers/vcfmerger2:0.10.3`)

## Structural Variant Tools

### Manta {: #manta }

**Purpose:** Structural variant and indel caller.

**Role in GrandCanyon:** Constitutional, somatic, and tumor-only SV calling, enabled with `*_variant_calling_structural_caller_manta`.

**Version:** 1.6.0 (`ghcr.io/tgen/containers/manta:1.6.0-23082819`)

### Sniffles {: #sniffles }

**Purpose:** Structural variant caller for long-read sequencing data.

**Role in GrandCanyon:** Detects SVs in constitutional, somatic, and tumor-only samples when long-read data (PacBio HiFi or ONT) is provided, enabled with `*_variant_calling_structural_caller_sniffles`. Particularly effective at detecting large insertions, inversions, and complex rearrangements.

**Version:** 2.8.0 (`quay.io/biocontainers/sniffles:2.8.0--pyhdfd78af_0`)

### cuteSV {: #cutesv }

**Purpose:** Structural variant caller optimized for long-read data.

**Role in GrandCanyon:** An alternative SV caller for constitutional and somatic analysis of long-read data, offering high sensitivity in low-coverage scenarios. Enabled with `*_variant_calling_structural_caller_cutesv`.

**Version:** 2.1.3 (`quay.io/biocontainers/cutesv:2.1.3--pyhdfd78af_0`)

### PBSV {: #pbsv }

**Purpose:** Structural variant caller for long-read sequencing data.

**Role in GrandCanyon:** Detects SVs in constitutional and somatic samples when long-read data (PacBio HiFi or ONT) is provided, enabled with `*_variant_calling_structural_caller_pbsv`. PBSV uses a pairwise aligner approach to identify structural variants from long reads.

**Version:** 2.11.0 (`quay.io/biocontainers/pbsv:2.11.0--h9ee0642_0`)

### Dysgu {: #dysgu }

**Purpose:** Structural variant caller optimized for long-read data.

**Role in GrandCanyon:** Constitutional and somatic SV calling for long-read data, enabled with `*_variant_calling_structural_caller_dysgu`. Dysgu is particularly effective at detecting complex and nested structural variants in long-read sequencing data.

**Version:** 1.8.8 (`quay.io/biocontainers/dysgu:1.8.8--py313h5d164f8_0`)

### Savana {: #savana }

**Purpose:** Somatic structural variant caller optimized for long-read data.

**Role in GrandCanyon:** Somatic SV calling specifically for long-read data (e.g., PacBio HiFi, Oxford Nanopore), enabled with `*_variant_calling_structural_caller_savana`. Savana is designed to leverage the longer read lengths and higher contiguity of long-read sequencing to detect structural variants with high precision.

**Version:** 1.3.7 (`quay.io/biocontainers/savana:1.3.7--pyhdfd78af_0`)

### Severus {: #severus }

**Purpose:** Somatic structural variant caller integrating multiple signals.

**Role in GrandCanyon:** Somatic SV calling for both short-read and long-read data, enabled with `*_variant_calling_structural_caller_severus`. Severus integrates multiple signals (split reads, discordant paired-end reads) to detect structural variants with high accuracy.

**Version:** 1.7 (`quay.io/biocontainers/severus:1.7--pyhdfd78af_0`)

### tRGT {: #trgt }

**Purpose:** Tandem repeat genotyper for long-read sequencing.

**Role in GrandCanyon:** Genotypes tandem repeat expansions using long-read data, enabled with `*_variant_calling_snp_indel_caller_trgt`. tRGT provides highly accurate genotyping of repetitive regions that are difficult to resolve with short-read data.

**Version:** 5.0.0 (`quay.io/biocontainers/trgt:5.0.0--h9ee0642_0`)

## Copy Number Analysis Tools

### GATK-CNV {: #gatk-cnv }

**Purpose:** Read-depth copy-number calling.

**Role in GrandCanyon:** Constitutional, somatic, and tumor-only CNV calling (requires panel-of-normals data for somatic/tumor-only modes). Enabled with `*_variant_calling_cna_caller_gatk_cnv`.

**Version:** 4.5.0.0 (`broadinstitute/gatk:4.5.0.0`)

### iChorCNA {: #ichorcna }

**Purpose:** Low-purity copy-number alteration and tumor-fraction estimation.

**Role in GrandCanyon:** Constitutional genome CNV analysis, enabled with `*_variant_calling_cna_caller_ichorcna`.

**Version:** 3.0.0 (`gavinhalab/ichorcna:3.0.0`)

### CNVkit {: #cnvkit }

**Purpose:** Copy-number calling from targeted sequencing data.

**Role in GrandCanyon:** Exome and targeted-panel CNV calling, enabled with `*_variant_calling_cna_caller_cnvkit`.

**Version:** 0.9.13 (`quay.io/biocontainers/cnvkit:0.9.13--pyhdfd78af_0`)

### ASCAT {: #ascat }

**Purpose:** Allele-specific copy number analysis of tumor data.

**Role in GrandCanyon:** Tumor CNV and purity/ploidy estimation, enabled with `*_variant_calling_cna_caller_ascat`.

**Version:** 3.2.0 (`quay.io/biocontainers/ascat:3.2.0--r44hdfd78af_1`)

### Spectre {: #spectre }

**Purpose:** Low-pass whole-genome sequencing CNV caller.

**Role in GrandCanyon:** CNV detection from low-pass genome data, enabled with `*_variant_calling_cna_caller_spectre`.

**Version:** 0.2.1 (`/home/tgenref/containers/spectre-cnv_0.2.1.sif`)

### Wakhan {: #wakhan }

**Purpose:** Maternal fetal fraction and fetal trisomy detection.

**Role in GrandCanyon:** Constitutional plasma/liquid biopsy analysis (cell-free DNA content) on genome data, enabled with `*_variant_calling_cna_caller_wakhan`.

**Version:** 0.4.3 (`quay.io/biocontainers/wakhan:0.4.3--pyhdfd78af_0`)

### HiFiCNV {: #hificnv }

**Purpose:** CNV calling for PacBio HiFi long-read data.

**Role in GrandCanyon:** Copy-number detection on long-read genome alignments, enabled with `*_variant_calling_cna_caller_hificnv`.

**Version:** 1.0.1 (`quay.io/biocontainers/hificnv:1.0.1--h9ee0642_0`)

### AmpliconArchitect {: #amplicon-architect }

**Purpose:** Amplicon and ecDNA reconstruction from whole-genome data.

**Role in GrandCanyon:** Characterization of focal amplifications and extrachromosomal DNA, enabled with `*_variant_calling_cna_caller_amplicon_architect`.

**Version:** 1.6.0-patched (`ghcr.io/tgen/containers/amplicon_suite:1.6.0-patched`)

### CNVear {: #cnvear }

**Purpose:** Annotates copy-number segments against gene intervals or myeloma FISH probe locations.

**Role in GrandCanyon:** Post-processes GATK-CNV `.seg` files into `.cnvear.tsv` and a `.cnvear.probes.bed` file.

**Version:** 0.4.1 (`ghcr.io/tgen/containers/cnvear:0.4.1`)

### b_pure {: #b-pure }

**Purpose:** B-cell purity estimation.

**Role in GrandCanyon:** Estimates B-cell purity from copy-number segments and the aligned BAM (myeloma samples).

**Version:** 1.2.0 (`ghcr.io/tgen/containers/b_pure:1.2.0`)

### tHReD {: #thred }

**Purpose:** Homologous recombination deficiency (HRD) scoring.

**Role in GrandCanyon:** Computes HRD scores and filtered segments from copy-number segments.

**Version:** 1.1.0 (`ghcr.io/tgen/containers/thred:1.1.0-23080712`)

## Structural Variant Post-Processing

### WhatsHap {: #whatshap }

**Purpose:** Read-backed phasing and haplotype tagging.

**Role in GrandCanyon:** Phases constitutional variants in long-read BAMs, enabled with `*_variant_calling_phasing_whatshap`.

**Version:** 2.8 (`quay.io/biocontainers/whatshap:2.8--py312hf731ba3_0`)

## Assembly Tools

### Flye {: #flye }

**Purpose:** De novo assembler for long-read sequencing data.

**Role in GrandCanyon:** Assembles long-read data (PacBio HiFi or Oxford Nanopore) into draft genome assemblies, enabled with `Genome_assembly_long_read_assembler_flye`.

**Version:** 2.9.6 (`quay.io/biocontainers/flye:2.9.6--py311h2de2dd3_0`)

### HiFiASM {: #hifiasm }

**Purpose:** Probabilistic de novo assembler for PacBio HiFi reads.

**Role in GrandCanyon:** High-quality haplotype-resolved genome assembly from PacBio HiFi data, enabled with `Genome_assembly_long_read_assembler_hifiasm`. HiFiASM produces primary and haplotype-specific contigs and can incorporate Hi-C scaffolding when available.

**Version:** 0.25.0 (`quay.io/biocontainers/hifiasm:0.25.0--h5ca1c30_0`)

### Verkko {: #verkko }

**Purpose:** De novo genome assembly with chromosome-scale scaffolding.

**Role in GrandCanyon:** Produces near-complete genome assemblies by integrating HiFi, ultra-long ONT, and Hi-C data, enabled with `Genome_assembly_long_read_assembler_verkko`. Verkko generates chromosome-scale scaffolds and is the preferred assembler for complete genome projects.

**Version:** 2.3.2 (`quay.io/biocontainers/verkko:2.3.2--hb0edd9e_0`)

### Shasta {: #shasta }

**Purpose:** Large genome assembler for Oxford Nanopore long reads.

**Role in GrandCanyon:** Assembles ultra-long Oxford Nanopore reads into draft genome assemblies, enabled with `Genome_assembly_long_read_assembler_shasta`. Shasta is the preferred assembler for projects relying on ONT data with high read lengths.

**Version:** 0.11.1 (`quay.io/biocontainers/shasta:0.11.1--h4ac6f70_2`)

## Assembly QC Tools

### assembly-stats {: #assembly-stats }

**Purpose:** Basic assembly statistics (contig counts, N50, total length).

**Role in GrandCanyon:** Part of the assembly QC pipeline run for every produced assembly.

**Version:** 1.0.1 (`quay.io/biocontainers/assembly-stats:1.0.1--h4ac6f70_7`)

### Compleasm {: #compleasm }

**Purpose:** Reference gene set completeness (BUSCO-based).

**Role in GrandCanyon:** Assesses assembly completeness against conserved single-copy genes as part of assembly QC.

**Version:** 0.2.7 (`quay.io/biocontainers/compleasm:0.2.7--pyh7e72e81_1`)

### Merqury {: #merqury }

**Purpose:** K-mer-based assembly consensus quality (QV) and completeness.

**Role in GrandCanyon:** Assembly accuracy assessment using read k-mers, together with its meryl k-mer counting prerequisite.

**Version:** 1.3 (`/home/tgenref/containers/merqury_1.3.sif`)

### Yak {: #yak }

**Purpose:** K-mer profiling for assembly QC.

**Role in GrandCanyon:** K-mer counting and analysis used alongside assembly (e.g., HiFiASM quality input).

**Version:** 0.1 (`quay.io/biocontainers/yak:0.1--h577a1d6_6`)

### QUAST {: #quast }

**Purpose:** Quality assessment tool for genome assemblies.

**Role in GrandCanyon:** Provides comprehensive assembly quality metrics including contiguity, completeness, and misassembly statistics.

**Version:** 5.3.0 (`quay.io/biocontainers/quast:5.3.0--py312pl5321hdcc493e_1`)

## RNA-seq Tools

### Salmon {: #salmon }

**Purpose:** Alignment-free transcript quantification.

**Role in GrandCanyon:** Transcript-level quantification from FASTQ (`quant/salmon`), enabled with `RNA_transcriptome_quantify_expression_salmon`.

**Version:** 2.3.2 (`quay.io/biocontainers/salmon:2.3.2--hfa8f182_0`)

### STAR-Fusion {: #star-fusion }

**Purpose:** Fusion transcript detection.

**Role in GrandCanyon:** Detects gene fusions from RNA-seq (`fusions/starfusion`), enabled with `RNA_transcriptome_fusion_caller_STAR_Fusion`.

**Version:** 1.14.0 (`trinityctat/starfusion:1.14.0`)

### CTAT-LR {: #ctat-lr }

**Purpose:** Long-read fusion transcript detection.

**Role in GrandCanyon:** Detects gene fusions from long-read RNA-seq data (`fusions/ctat_lr`).

**Version:** 1.4.0 (`trinityctat/ctat_lr_fusion:1.4.0`)

### Subread {: #subread }

**Purpose:** Read alignment and quantification utilities (featureCounts).

**Role in GrandCanyon:** Optional gene-level quantification via featureCounts.

**Version:** 2.0.6 (`quay.io/biocontainers/subread:2.0.6--he4a0461_0`)

### PacBio IsoSeq {: #isoseq }

**Purpose:** Isoform discovery and quantification from long-read RNA-seq data.

**Role in GrandCanyon:** Generates full-length transcript isoforms from PacBio Kinnex or Revio long-read RNA-seq data. IsoSeq is enabled with `RNA_transcriptome_isoform_discovery_isoseq` and is automatically selected when `rgpl` is set to `PACBIO` and `glprep` starts with `kinnex`.

**Version:** 26.2.0 (`quay.io/biocontainers/isoseq:26.2.0--h9ee0642_0`)

### Flair {: #flair }

**Purpose:** Isoform identification and alternative splicing analysis for long-read RNA-seq.

**Role in GrandCanyon:** Detects novel isoforms and performs differential splicing analysis from long-read RNA-seq data. Flair can be used with both PacBio and ONT data.

**Version:** 3.0.0 (`brookslab/flair:3.0.0`)

### IsoQuant {: #isoquant }

**Purpose:** Isoform detection and transcript quantification for long-read RNA-seq.

**Role in GrandCanyon:** Provides precise isoform-level expression estimates from long-read sequencing data.

**Version:** 4.0.0 (`quay.io/biocontainers/isoquant:4.0.0--pyh106432d_0`)

### Oarfish {: #oarfish }

**Purpose:** Alignment-free transcript quantification for long-read RNA-seq.

**Role in GrandCanyon:** Estimates transcript abundances directly from long-read sequences without requiring alignment to a reference. This can provide faster and more accurate quantification for long-read data.

**Version:** 0.10.0 (`quay.io/biocontainers/oarfish:0.10.0--hd727d2a_0`)

### Pigeon & Pbpigeon {: #pbpigeon }

**Purpose:** Isoform classification and analysis for long-read RNA-seq.

**Role in GrandCanyon:** Classifies transcripts generated by IsoSeq or Flair, providing isoform-level annotations and filtering. Pbpigeon extends pigeon for single-cell long-read RNA-seq data.

**Version:** 26.2.0 (`quay.io/biocontainers/pbpigeon:26.2.0--h9ee0642_0`)

### SQANTI3 {: #sqanti3 }

**Purpose:** Isoform sequence quality analysis for long-read transcriptomes.

**Role in GrandCanyon:** Provides comprehensive quality control and classification of long-read transcript isoforms, including identification of novel isoforms and artifact filtering.

**Version:** 6.0.2 (`ghcr.io/tgen/containers/sqanti3:6.0.2`)

## Quality Control Tools

### MultiQC {: #multiqc }

**Purpose:** Aggregates QC results into a single report.

**Role in GrandCanyon:** Finalization step that aggregates QC across the project.

**Version:** 1.31 (`quay.io/biocontainers/multiqc:1.31--pyhdfd78af_0`)

### Samtools stats {: #samtools }

**Purpose:** SAM/BAM/CRAM manipulation and alignment statistics.

**Role in GrandCanyon:** Alignment statistics, indexing, and BAM/CRAM conversion (stats, flagstat, idxstats, markdup stats). Enabled with `*_quality_control_stats_samtools_stats` and related toggles.

**Version:** 1.20 (`quay.io/biocontainers/samtools:1.20--h50ea8bc_1`)

### GATK CollectMultipleMetrics {: #gatk-collectmultiplemetrics }

**Purpose:** Collects alignment, insert-size, and quality metrics.

**Role in GrandCanyon:** Per-sample alignment QC metrics, enabled with `*_quality_control_stats_gatk_CollectMultipleMetrics` (plus WGS metrics for genome data and `gatk_CollectRnaSeqMetrics` for RNA).

**Version:** 4.5.0.0 (`broadinstitute/gatk:4.5.0.0`)

### VerifyBamID2 {: #verifybamid2 }

**Purpose:** Sample identity and contamination estimation.

**Role in GrandCanyon:** DNA sample QC, enabled with `*_quality_control_constitutional_contamination_check_VerifyBamID`.

**Version:** 2.0.3 (`quay.io/biocontainers/verifybamid2:2.0.3--hc004090_0`)

### FreeBayes {: #freebayes }

**Purpose:** Haplotype-based SNV, indel, and small CNV caller.

**Role in GrandCanyon:** Constitutional sex check via genotype calling, enabled with `*_quality_control_constitutional_sex_check_freebayes`.

**Version:** 1.3.10 (`quay.io/biocontainers/freebayes:1.3.10--hbefcdb2_0`)

### SnpSniffer {: #snpsniffer }

**Purpose:** Genotype concordance checking.

**Role in GrandCanyon:** Project-level genotype concordance across samples, enabled with `*_quality_control_genotype_concordance_snpSniffer`.

**Version:** 7.0.2 (`ghcr.io/tgen/containers/snpsniffer:7.0.2`)

### Riker {: #riker }

**Purpose:** Alignment QC statistics.

**Role in GrandCanyon:** Additional per-sample alignment QC, enabled with `*_quality_control_stats_riker`.

**Version:** 0.4.1 (`quay.io/biocontainers/riker:0.4.1--hec9b1f2_0`)

## Annotation Tools

### VEP {: #vep }

**Purpose:** Variant Effect Predictor annotation.

**Role in GrandCanyon:** Annotates variant calls with consequences, population frequencies, and clinical databases. Produces `*.vep.pick.vcf.gz` and `*.vep.full.vcf.gz`. Enabled with `*_variant_calling_annotate_vcfs_vep`.

**Version:** 113.4 (`ensemblorg/ensembl-vep:release_113.4`)

### bcftools annotate / csq {: #bcftools }

**Purpose:** Add or update VCF annotations; consequence calling from transcript data.

**Role in GrandCanyon:** Applies database annotations and contig updates prior to VEP (`*_variant_calling_annotate_vcfs_bcftools`) or calls consequences directly from a GTF (`*_variant_calling_annotate_vcfs_csq`).

**Version:** 1.20 (`quay.io/biocontainers/bcftools:1.20--h8b25389_1`)

## Somatic Metrics

### TGen Mutation Burden {: #tgen-mutation-burden }

**Purpose:** Tumor mutational burden (TMB) calculation.

**Role in GrandCanyon:** Computes TMB from annotated somatic VCFs, enabled with `*_sample_metrics_tgen_mutation_burden`.

**Version:** 1.2.4 (`ghcr.io/tgen/containers/mutation-burden:1.2.4_20260623`)

### MSISensor {: #msisensor }

**Purpose:** Microsatellite instability detection.

**Role in GrandCanyon:** Somatic MSI detection from tumor-normal BAMs, enabled with `*_sample_metrics_msisensor_pro`.

**Version:** 1.3.0 (`quay.io/biocontainers/msisensor-pro:1.3.0--hd979922_1`)

### SigProfilerAssignment {: #sigprofiler }

**Purpose:** Mutational signature assignment.

**Role in GrandCanyon:** Assigns COSMIC mutational signatures to somatic calls, enabled with `*_sample_metrics_sigprofiler`.

**Version:** 1.1.4 (`quay.io/biocontainers/sigprofilerassignment:1.1.4--pyh106432d_0`)

### tucon {: #tucon }

**Purpose:** Variant counting against a reference population.

**Role in GrandCanyon:** Counts total variants and TOPMed-overlapping variants in a filtered somatic VCF, enabled with `*_sample_metrics_tucon`.

**Version:** uses `bcftools` 1.20

## Utility Tools

### bedtools {: #bedtools }

**Purpose:** Genome interval arithmetic.

**Role in GrandCanyon:** Interval intersection and manipulation tasks.

**Version:** 2.29.0 (`ghcr.io/tgen/containers/bedtools:2.29.0-23080313`)

### samtools & bcftools {: #samtools-bcftools }

**Purpose:** BAM/CRAM and VCF/BCF manipulation.

**Role in GrandCanyon:** File manipulation, indexing, merging, and filtering throughout the pipeline.

**Version:** samtools 1.20, bcftools 1.20

## Methylation Analysis Tools

### ModKit {: #modkit }

**Purpose:** Methylation analysis from signal-level and basecalled data.

**Role in GrandCanyon:** Extracts and analyzes CpG methylation from long-read sequencing data, enabled with `*_methylation_methylation_caller_modkit`. ModKit works directly with modified base calls from PacBio or Oxford Nanopore data.

**Version:** 0.5.0 (`quay.io/biocontainers/ont-modkit:0.5.0--hcdda2d0_0`)

### RASTair {: #rastair }

**Purpose:** Read-backed phasing of methylation marks.

**Role in GrandCanyon:** Phased methylation extraction from long-read sequencing data, enabling allele-specific methylation analysis. Enabled with `*_methylation_methylation_caller_rastair`.

**Version:** 2.1.1 (`quay.io/biocontainers/rastair:2.1.1--h03e3cfe_0`)

### methbat {: #methbat }

**Purpose:** Methylation state analysis at CpG sites.

**Role in GrandCanyon:** Analyzes CpG methylation levels from long-read sequencing data to identify differentially methylated regions. Enabled with `*_methylation_methylation_caller_methbat`.

**Version:** 1.1.0 (`quay.io/biocontainers/methbat:1.1.0--h9ee0642_0`)

## Container Registry

All tools are containerized as OCI images available under the [TGen packages](https://github.com/orgs/tgen/packages). Container definitions and digests are maintained in `pipeline.yaml` under `constants.tools`.

## See Also

- [Tools Index](../tools-index/) - summary table of all tools
- [Quick Start Guide](../../getting-started/quick-start/) - pipeline overview
- [Pipeline Constants](https://github.com/tgen/GrandCanyon/blob/main/pipeline.yaml) - `constants.tools` container definitions
