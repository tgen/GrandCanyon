---
layout: default
title: Interpreting Outputs
parent: Analysis
nav_order: 1
---

# Interpreting Outputs

{: .note }
> This guide maps GrandCanyon's output directories to biological questions. For the directory layout itself, see the [Output Structure](../../outputs/) documentation.

## Overview

GrandCanyon writes results under the project directory in `<glType>/<AnalysisType>/<Tool>/<SampleName_or_PairName>/` folders. This guide helps you:

1. **Find** specific output files by analysis type
2. **Interpret** what each file contains
3. **Filter** results for downstream analysis
4. **Validate** results through quality checks

## Directory Structure

```
Project
├── genome/  (or exome/)
│   ├── alignment/bwa/<sample>/        (short-read)
│   │   └── stats/
│   ├── alignment/minimap2/<sample>/   (long-read)
│   │   └── stats/
│   ├── alignment/vg_giraffe/<sample>/ (pangenome)
│   │   └── stats/
│   ├── assembly/<tool>/<sample>/      (long-read de novo)
│   │   └── stats/
│   ├── constitutional_variant_calls/<caller>/<sample>_<aligner>/
│   ├── constitutional_structural_calls/<tool>/<sample>_<aligner>/
│   ├── constitutional_copy_number/<tool>/<sample>_<aligner>/
│   ├── copy_number_analysis/ichorCNA/<sample>_<aligner>/   (genome only)
│   ├── somatic_variant_calls/<caller>/<normal>-<tumor>_<aligner>/
│   ├── somatic_structural_calls/<tool>/<normal>-<tumor>_<aligner>/
│   ├── somatic_copy_number/gatk/<normal>-<tumor>_<aligner>/
│   ├── methylation/<tool>/<sample>_<aligner>/
│   ├── tumor_only_variant_calls/<caller>/<...>/
│   ├── tumor_only_structural_calls/<tool>/<...>/
│   ├── tumor_only_copy_number/gatk/<...>/
│   └── metrics/<tool>/<...>/
├── rna/
│   ├── alignment/star/<sample>/       (short-read)
│   ├── alignment/minimap2/<sample>/   (long-read)
│   │   └── stats/
│   ├── quant/star/<sample>/
│   ├── quant/salmon/<sample>/
│   ├── quant/isoquant/<sample>/       (long-read)
│   ├── quant/oarfish/<sample>/        (long-read)
│   ├── fusions/starfusion/<sample>/   (short-read)
│   ├── fusions/ctat_lr/<sample>/      (long-read)
│   └── isoforms/isoseq/<sample>/      (long-read)
├── qc/
│   └── multiqc_data/
├── assembly/
│   └── <tool>/<project>/
├── methylation/
│   └── <tool>/<sample>/
└── jetstream/
    ├── history/
    └── logs/
```

## Quick File Locator

### DNA

| Question | File pattern | Location |
|----------|-------------|----------|
| Aligned reads | `<sample>.<aligner>.cram` | `<glType>/alignment/<aligner>/<sample>/` |
| Alignment QC | `<sample>_<library>.<aligner>.cram.*` (metrics/stats) | `<glType>/alignment/<aligner>/<sample>/stats/` |
| Constitutional calls | `<sample>.<aligner>.<caller>.all.vcf.gz` / `.pass.vcf.gz` | `<glType>/constitutional_variant_calls/<caller>/<sample>_<aligner>/` |
| Somatic calls (per caller) | `<pair>.<aligner>.<caller>.pass.vcf.gz` | `<glType>/somatic_variant_calls/<caller>/<sample_or_pair>_<aligner>/` |
| Somatic consensus | `<pair>.<aligner>.merged.vcf.gz` | `<glType>/somatic_variant_calls/vcfmerger2/<sample_or_pair>_<aligner>/` |
| Annotated variants | `*.vep.pick.vcf.gz` and `*.vep.full.vcf.gz` | alongside the caller's output directory |
| Constitutional structrual variants | `<sample>.<aligner>.<caller>.all.vcf.gz` / `.pass.vcf.gz` | `<glType>/constitutional_structural_calls/<caller>/<sample>_<aligner>/` |
| Somatic structrual variants | `<sample>.<aligner>.<caller>.all.vcf.gz` / `.pass.vcf.gz` | `<glType>/somatic_structural_calls/<caller>/<sample_or_pair>_<aligner>/` |
| Copy number | GATK-CNV `*.called.seg` / iChorCNA `*.cna.seg` | `<glType>/somatic_copy_number/gatk/...` or `copy_number_analysis/ichorCNA/...` |
| Somatic metrics | TMB, MSI, signatures, tucon | `<glType>/metrics/<tool>/<...>/` |

### RNA

**Short-read (Illumina):**

| Question | File pattern | Location |
|----------|-------------|----------|
| Aligned reads | `<sample>.star.bam` | `rna/alignment/star/<sample>/` |
| Gene counts | STAR gene counts files | `rna/quant/star/<sample>/` |
| Salmon quantification | `<sample>.transcripts.sf` (and `quant.sf`) | `rna/quant/salmon/<sample>/` |
| Fusions | `<sample>_star_fusion.fusion_predictions.abridged.coding_effect.tsv` (and related TSVs) | `rna/fusions/starfusion/<sample>/` |

**Long-read (PacBio, ONT):**

| Question | File pattern | Location |
|----------|-------------|----------|
| Minimap2 alignment | `<sample>.minimap2.cram` | `rna/alignment/minimap2/<sample>/` |
| ISO-Seq isoforms | `<sample>.transcriptset.fa` | `rna/isoforms/isoseq/<sample>/` |
| Flair isoforms | `<sample>_isoforms.filtered.flair.bed12` | `rna/isoforms/flair/<sample>/` |
| IsoQuant quantification | `<sample>_txn_log2tpm_filtered.tsv` | `rna/quant/isoquant/<sample>/` |
| Oarfish quantification | `<sample>_quant.tsv` | `rna/quant/oarfish/<sample>/` |
| Long-read fusions | CTAT-LR fusion calls | `rna/fusions/ctat_lr/<sample>/` |

## Understanding VCF Outputs

All VCF files follow the VCF format. Key columns:

| Column | Description |
|--------|-------------|
| `CHROM` / `POS` | Genomic location (1-based) |
| `ID` | Variant identifier (dbSNP rsID when known) |
| `REF` / `ALT` | Reference and alternate alleles |
| `QUAL` | Phred-scaled quality score |
| `FILTER` | `PASS` or the reason the variant was filtered |
| `INFO` | Semicolon-separated annotations |
| `FORMAT` / sample columns | Per-sample fields (e.g., `GT:AD:DP:GQ`) |

### Somatic consensus (`INFO/CC`)

VcfMerger2 merges the enabled somatic callers into a single VCF and adds an `INFO/CC` field counting how many callers agree on each variant:

| Scenario | Recommended filter | Rationale |
|----------|-------------------|-----------|
| Standard use | `CC >= 2` | At least 2 callers agree |
| All 5 callers used | `CC >= 3` | Majority agreement |
| High-confidence set | `CC >= 4` | Very stringent |
| Exploration set | `CC >= 1` | Include all calls |

```bash
bcftools filter -e 'INFO/CC < 3' merged.vcf.gz -Oz -o filtered_cc3.vcf.gz
```

(Replace `merged.vcf.gz` with the actual merged file, e.g. `<pair>.<aligner>.merged.vcf.gz`.)

### VEP annotation

Annotated variants end with `*.vep.pick.vcf.gz` (recommended, one consequence per variant) and `*.vep.full.vcf.gz` (all transcripts). Key `INFO` field: `CSQ` (consequence, impact, gene symbol, and population/clinical annotations).

## CRAM vs BAM

GrandCanyon writes CRAM when `cram: true` is set in the configuration.

| Aspect | CRAM | BAM |
|--------|------|-----|
| Storage | Much smaller (reference-compressed) | Full size |
| Requires | Reference FASTA for decode | Standalone |
| Random access | Via `.crai` | Via `.bai` |
| Archive | Preferred | Not recommended for long-term storage |

**Recommendation:** archive in CRAM; convert to BAM when needed for tools that do not support CRAM.

## QC Checks

| QC Type | Where | What it tells you |
|---------|-------|-------------------|
| Aggregate QC | `qc/multiqc_data/` (MultiQC report) | Combined QC across the project |
| Alignment stats | `<glType>/alignment/<aligner>/<sample>/stats/` | Mapping rate, insert size, coverage |
| Identity/contamination | VerifyBamID2 output | Sample identity and contamination |
| Sex check | `*sexCheck*` in alignment stats | Reported vs. inferred sex |
| Genotype concordance | SnpSniffer output | Cross-sample concordance (project-level) |
| Methylation QC | `methylation/<tool>/<sample>/` | Methylation levels and coverage |

QC thresholds are project- and assay-specific; use the MultiQC report and the alignment metrics to identify outliers rather than relying on fixed cutoffs.

## Somatic Multi-Caller Consensus

GrandCanyon's somatic module runs up to five SNV/indel callers - **Mutect2, DeepSomatic, Strelka2, Lancet2, VarDict** - and merges them with **VcfMerger2**. Interpret the merged VCF using the `INFO/CC` field as described above.

### What is filtered to produce PASS VCFs

Two filtering layers are applied after caller output (see the [Configuration Guide's](../../getting-started/configuration/) `task_variables` section for the underlying settings):

1. **Merge-time exclusion (`task_variables.*.vcfmerger_exclude_filter`)** - during VcfMerger2 merging, variants are excluded with `(FMT/DP<10 | FMT/AR[0]>=0.02 | FMT/AR[1]<0.05)`: depth below 10 in a sample, an artifact ratio above 2% in the normal, or a tumor allelic ratio below 5%.
2. **Post-merge variant filtering (`variant_filtering_*` tasks)** - a bcftools `view --include` filter produces the filtered VCFs. For paired somatic projects this is a caller-consensus cutoff of `INFO/CC >= N-1` (normally) or `INFO/CC >= N-2` when more than three callers ran (overridable via `task_variables.somatic_variant_filtering.<glType>.CC_filter`). For tumor-only projects an additional database filter keeps variants absent from TOPMed/gnomAD or passing a COSMIC-ratio threshold (`COSMIC_Ratio_Threshold`). Germline candidate reports additionally drop variants with `GNOMAD_AF/TOPMED_AF > 0.001` and variants predicted benign/low-impact (SIFT "tolerated", PolyPhen "benign", IMPACT LOW/MODIFIER).

This filter behavior is derived from the workflow templates; confirm project-specific expectations with the TGen team.

## Next Steps

- [Downstream Recommendations](../downstream-recommendations/) - filtering and prioritization
- [Tools Index](../../reference/tools-index/) - tools that produced each result
- [Configuration Guide](../../getting-started/configuration/) - enable/disable stages
