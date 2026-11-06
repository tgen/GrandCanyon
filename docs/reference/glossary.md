---
layout: default
title: Glossary
parent: Reference
nav_order: 4
---

# Glossary and Terminology

This glossary defines key terms used throughout the GrandCanyon pipeline documentation and helps clarify terminology consistency.

## Sample Terminology

| Term | Definition | Usage in GrandCanyon |
|------|------------|----------------|
| **Sample** | A processed sequencing library derived from a specimen | Primary concept; used in configuration (`sampleName` / `sampleMergeKey`) and output directories (`<glType>/<analysis>/<tool>/<sample>/`) |
| **Specimen** | The biological source material from which samples are derived | Used in TGen naming convention; one specimen may yield multiple samples |
| **Read Group (RG)** | A set of reads from a sequencing run, identified by `rgid` | SAM/BAM specification; in the config each `rgid` has one `R1` and one `R2` `dataFiles` entry |
| **Library** | A prepared sequencing library, typically corresponding to a read group | Derived from sample/assay; tracked via `limsLibraryRecordId` |

### Sample vs. Specimen

In the GrandCanyon pipeline, these terms have distinct meanings:

- **Specimen** = the biological sample (e.g., blood draw, tissue biopsy)
- **Sample** = the processed material sequenced (e.g., one exome library from one blood draw)

A single specimen may yield multiple samples:
- Different library preps (e.g., exome + RNA)
- Different sequencing lanes or flowcells
- Different time points (e.g., diagnosis, relapse)

The `sampleMergeKey` is used to link data from multiple sequencing runs belonging to the same specimen and assay.

## Analysis Type Terminology

| Term | Definition | Template Usage |
|------|------------|----------------|
| **Constitutional** | Germline analysis from non-tumor tissue | Primary term; set in config via `subGroup: constitutional`; results under `<glType>/constitutional_variant_calls/` |
| **Germline** | Inherited variants present in all cells | Synonym for constitutional; used interchangeably in documentation with "constitutional" as primary |
| **Somatic** | Acquired variants present only in tumor tissue | Used for paired tumor-normal analysis |
| **Tumor-only** | Analysis of tumor samples without matched normal | Indicates somatic callers run on tumor-only data; results cannot distinguish somatic from germline variants |

### Constitutional vs. Germline

The pipeline uses **"constitutional"** throughout the configuration and output structure. The term **"germline"** is used in documentation as a synonym for clarity.

```
Configuration:  subGroup: constitutional
Output:         <glType>/constitutional_variant_calls/
Documentation:  constitutional (primary), germline (synonym)
```

### Somatic Analysis Types

| Type | Description | Example |
|------|-------------|---------|
| **Paired Somatic** | Tumor sample with matched normal | Diagnosis exome + matched constitutional |
| **Tumor-Only** | Tumor sample without matched normal | Relapse-only exome |

For tumor-only analysis, the pipeline still runs somatic callers but results should be interpreted with caution: variants cannot be distinguished as somatic vs. germline without a matched normal.

## Sample Type Terminology

| Term | Config Value (`glType`) | Description |
|------|------------------------|-------------|
| **Genome** | `genome` | Whole genome sequencing |
| **Phased Genome** | `genomephased` | Whole genome (phased) sequencing |
| **Exome** | `exome` | Exome capture sequencing |
| **RNA** | `rna` | RNA sequencing |
| **Mate Pair** | `matepair` | Mate pair sequencing (rare) |

## Variant Calling Terminology

| Term | Definition |
|------|------------|
| **SNV** | Single Nucleotide Variant - a single base change |
| **INDEL** | Insertion or Deletion - a small sequence change (typically < 50bp) |
| **SV** | Structural Variant - large-scale rearrangement (deletion, duplication, inversion, translocation) |
| **CNV** | Copy Number Variant - gain or loss of genomic material |
| **VAF** | Variant Allele Frequency - proportion of reads supporting the variant |
| **PASS** | Filter status - variant passed all quality filters |
| **CC** | Caller Consensus - number of callers agreeing on a variant (VCFMerger2) |

## File Format Terminology

| Format | Full Name | Description |
|--------|-----------|-------------|
| **FASTQ** | Fastq | Raw sequencing reads (unaligned) |
| **BAM** | Binary Alignment Map | Aligned reads in binary format |
| **CRAM** | Compressed Read Alignment Map | Reference-compressed aligned reads |
| **VCF** | Variant Call Format | Variant calls (SNVs, indels, SVs) |
| **MAF** | Mutation Annotation Format | Cancer mutation data format |
| **BED** | Browser Extensible Data | Genomic intervals |

## Naming Convention

The TGen standardized naming convention follows this hierarchy:

```
STUDY_PATIENT_VISIT_SOURCE_FRACTION_SubgroupIncrement_ASSAY_LIBRARY
```

| Level | Concept | Example |
|-------|---------|---------|
| Study | Research study identifier | `GIAB` |
| Patient | Unique patient identifier | `NA12878` |
| Visit | Sequencing visit/session | `1` |
| Source | Tissue type | `CL` (cell line) |
| Fraction | Sample fraction | `Whole` |
| Subgroup Increment | Sample processing increment | `C1` |
| Assay | Sequencing assay | `TPFWG` (targeted panel WGS) |
| Library | Specific library | `K18088` |

---

## Terminology Consistency Guide

When writing or editing documentation, follow these consistency rules:

| Term | Preferred Usage | Avoid |
|------|----------------|-------|
| Analysis type | "Constitutional" | "Germline" (use "germline" in parentheses after first use: constitutional (germline)) |
| Tumor analysis | "Paired somatic" for matched pairs | "Paired-somatic", "somatic paired" |
| Tumor without normal | "Tumor-only" | "Tumor only", "pseudo-tumor-only" |
| Sample identifier | "Sample" | "Specimen" (unless referring to biological source) |
| Alignment output | "CRAM" (preferred), "BAM" | "cram" (always capitalize) |
| Filtering | "PASS" (all caps) | "pass", "Pass", "passed" |
| Variant type | "SNV" or "SNVs" | "SNP" (use SNV as it is more general) |
| Platform | "Illumina" (proper noun) | "illumina" |
| Reference genome | "GRCh38" (not "hg38") | "hg38" |
| Annotation tool | "VEP" (proper noun) | "VEP annotation tool" (unless clarifying) |

## See Also

- [Tools Index](../tools-index/)
- [Configuration Guide](../../getting-started/configuration/)
- [TGen Naming Convention](../../getting-started/configuration/#tgen-naming-convention)
