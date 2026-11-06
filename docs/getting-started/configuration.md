---
layout: default
title: Configuration Guide
parent: Getting Started
nav_order: 2
---

# Configuration Guide

{: .note }
> This guide describes the JSON configuration that drives GrandCanyon. For a minimal working example, see the [Quick Start Guide](../quick-start/).

{: .warning }
> **LIMS-Generated Configurations**: For most internal TGen users, this JSON file is generated automatically by the TGen LIMS. This guide is primarily useful for external users or for understanding the schema.

## Overview

The configuration is a JSON file that describes your samples and their FASTQ files. GrandCanyon's `main.j2` template reads this data, groups the FASTQs into read groups and samples, and renders the analysis tasks.

The key concept is that `dataFiles` is a **flat array with one entry per FASTQ file**. Each read group (`rgid`) must contain both an `R1` and an `R2` entry (identified by `fastqCode`), and samples are grouped by `sampleMergeKey` (or `sampleName`).

## Top-Level Structure

```json
{
  "project": "Project_Name",
  "study": "Study_Name",
  "pipeline": "grandcanyon",
  "dataFiles": [],
  "cram": true,
  "email": "somebody@tgen.org",
  "submitter": "somebody",
  "hpcAccount": "",
  "isilonPath": "",
  "tasks": {}
}
```

### Top-Level Fields

| Field | Type | Description |
|-------|------|-------------|
| `project` | string | Project name identifier |
| `study` | string | Study name |
| `pipeline` | string | Pipeline identifier - set to `grandcanyon` |
| `dataFiles` | array | One entry per input FASTQ file (see below) |
| `cram` | boolean | Write alignment output as CRAM instead of BAM |
| `email` | string | Notification email |
| `submitter` | string | Submitter name |
| `hpcAccount` | string | HPC account for job submission |
| `isilonPath` | string | Network storage path for outputs |
| `tasks` | object | Feature/caller toggles (see [Task Toggles](#task-toggles)) |
| `sex` | string | `Male` or `Female`; used for CNV and sex-check tasks (defaults vary by task) |
| `strict` | boolean | When pairing tumor/normal, require matching `assayCode` (default `false`) |
| `somatic_variant_calling_pairs` | array | Explicit list of `{"tumor": ..., "normal": ...}` pairs (overrides auto-pairing) |
| `controlDataFiles` | array | Panel-of-normals / control samples used by GATK-CNV and tumor-only calling |
| `task_variables` | object | Advanced per-task overrides (e.g., UMI alignment and variant filtering options) |
| `submissionSource` | string | Submission source; used to toggle specific tasks |
| `debug` | boolean | Keep intermediate files and log the parsed sample table |

Additional LIMS/JetStream metadata fields that may appear in generated configs include `ethnicity`, `familyCode`, `holdConfig`, `matchedNormal`, `matchedNormalToUse`, `maternalID`, `paternalID`, `patCode`, and `varDB`.

## The `dataFiles` Array

Each entry describes one FASTQ file. Entries with the same `rgid` form a read group, and read groups with the same `sampleMergeKey` (or `sampleName`) form a sample.

```json
{
  "sampleMergeKey": "GIAB_NA12878_1_CL_Whole_C1_TPFWG",
  "sampleName": "GIAB_NA12878_1_CL_Whole_C1_TPFWG_K18088",
  "glType": "genome",
  "glPrep": "genome",
  "subGroup": "constitutional",
  "fastqCode": "R1",
  "fastqPath": "/path/to/sample_R1.fastq.gz",
  "rgid": "RG001",
  "rgsm": "GIAB_NA12878_1_CL_Whole_C1",
  "rgpl": "ILLUMINA",
  "rglb": "K18088",
  "rgpu": "FLOWCELL_LANE"
}
```

### Data File Attributes

| Attribute | Values / Notes |
|-----------|----------------|
| `fastqCode` | `R1` or `R2` - read number of the FASTQ |
| `fastqPath` | Path to the FASTQ file |
| `sampleMergeKey` | Preferred sample grouping key; used as the BAM filename and ensures different assays are not merged together |
| `sampleName` | Base FASTQ/sample identifier; used when `sampleMergeKey` is absent |
| `rgid` | Read group identifier; groups the R1/R2 pair |
| `glType` | Sample type: `genome`, `genomephased`, `exome`, `rna`, or `matepair` |
| `glPrep` | Library prep: `genome`, `capture`, `rna`, or `matepair` |
| `subGroup` | `constitutional` or `tumor` (defaults to `constitutional` when omitted) |
| `assayCode` | Assay code; used to classify the sample and select the exome capture kit |
| `dnaRnaMergeKey` | Links DNA and RNA samples for integrated analysis |
| `fileType` | File type (e.g., `fastq`) |
| `fraction` | Sample fraction (TGen naming convention) |
| `numberOfReads` | Expected number of reads; used to validate alignment chunking |
| `read1Length` / `read2Length` | Read lengths; used to select the STAR index for RNA |
| `readOrientation` | `inward` or `outward` (RNA) |
| `rnaStrandDirection` | `notapplicable`, `forward`, or `reverse` (RNA) |
| `rnaStrandType` | `unstranded` or `stranded` (RNA) |
| `umiType` | UMI chemistry assigned to the sample; affects duplicate-marking QC behavior (e.g., samtools markdup stats are not run for `Inline_Duplex` libraries) |
| `limsLibraryRecordId` | LIMS library record ID for result upload |

#### SAM/BAM Read Group Fields (`rg*`)

These follow the [SAM/BAM Format Specification](https://samtools.github.io/hts-specs/SAMv1.pdf):

| Field | Description |
|-------|-------------|
| `rgid` | Read group identifier (required to pair R1/R2) |
| `rgsm` | Sample name (used as the genotype column header in VCFs) |
| `rgcn` | Name of sequencing center producing the read |
| `rgbc` | Barcode sequence identifying the sample or library |
| `rglb` | Library identifier |
| `rgpl` | Platform/technology used to produce the reads (e.g., `ILLUMINA`) |
| `rgpm` | Platform model (e.g., `HiSeq2500`) |
| `rgpu` | Platform unit (e.g., flowcell-barcode.lane) |

### `glType` and `glPrep`

`glType` determines which analyses run:

| `glType` | Analysis |
|----------|----------|
| `genome` | Whole-genome DNA alignment and variant calling |
| `genomephased` | Whole-genome (phased) DNA |
| `exome` | Exome capture DNA alignment and variant calling |
| `rna` | RNA alignment, quantification, and fusion calling |
| `matepair` | Mate-pair library |

`glPrep` describes the library preparation (`genome`, `capture`, `rna`, `matepair`). For projects involving long-read sequencing (e.g., PacBio HiFi or Oxford Nanopore), `glPrep` can be set to `LongRead` to enable optimized alignment (Minimap2) and variant calling strategies.

### Long-Read Sequencing Support

GrandCanyon supports both short-read (Illumina) and long-read (PacBio HiFi, Oxford Nanopore) sequencing data. Long-read data is particularly valuable for detecting structural variants and resolving complex genomic regions.

When long-read data is provided, the pipeline automatically:

1. Selects appropriate aligners: `minimap2` for long reads instead of `BWA-MEM2`.
2. Adjusts structural variant calling to use long-read-aware callers (e.g., `Sniffles`, `cuteSV`).
3. Optimizes memory and CPU allocation to handle longer read lengths.

To specify long-read data, set the platform field (`rgpl`) to `PACBIO` or `ONT` in the `dataFiles` entry, and optionally set `glPrep` to `LongRead`.

```json
{
  "rgpl": "ONT",
  "glPrep": "LongRead"
}
```

### `subGroup`

- `constitutional` - non-tumor sample; runs constitutional callers (default when omitted).
- `tumor` - tumor sample; drives somatic and tumor-only pairing.

For a matched pair, provide one sample with `subGroup: constitutional` and one with `subGroup: tumor` (both with the same `glType`). Use `strict: true` to require matching `assayCode`, or supply explicit `somatic_variant_calling_pairs`.

### `assayCode` and Exome Capture Kits

For exome samples, the capture kit is selected automatically from `assayCode` (mapped to target/baits interval files under `constants.grandcanyon` in `pipeline.yaml`). Recognized exome codes include:

`AG2`, `E61`, `S5U`, `S5X`, `S6U`, `S6X`, `S7X`, `ST2`, `STL`, `STX`, `TS1`, `V6C`

For genomes, `assayCode` is not used to select a capture kit.

### `sampleMergeKey` vs `sampleName`

- **`sampleMergeKey`** - expected BAM filename; merges data from multiple sequencing lanes/flowcells for the same specimen and assay. Prevents different assays from being merged.
- **`sampleName`** - expected base FASTQ filename; used as the grouping key when `sampleMergeKey` is absent.

## Task Toggles

Most callers and analyses are optional and enabled through the `tasks` object. Keys follow the pattern:

```
<Genome|Exome|RNA>_<analysis>_<module>_<tool>
```

For example:

```json
{
  "tasks": {
    "Genome_constitutional_snp_indel_caller_deepvariant": true,
    "Genome_constitutional_snp_indel_caller_freebayes": true,
    "Genome_somatic_snp_indel_caller_gatk_mutect2": true,
    "Genome_somatic_merge_vcfs_vcfMerger2": true,
    "RNA_transcriptome_quantify_expression_salmon_fastqs": true,
    "RNA_transcriptome_fusion_caller_STAR_Fusion": true
  }
}
```

If no tasks are enabled, only the project setup/QC groundwork renders; the aligner and each caller must be enabled explicitly via `tasks`. Consult `pipeline.yaml` and the module templates under `modules/` for the full set of available task keys.

## LIMS-Generated Example

Here is a complete example as generated by the TGen LIMS (some data anonymized):

<details><summary>Show LIMS Example</summary>

```json
{
  "cram": true,
  "dataFiles": [
    {
      "assayCode": "TPFWG",
      "dnaRnaMergeKey": "GIAB_NA12878_1_CL_Whole",
      "fastqCode": "R1",
      "fastqPath": "/path/to/GIAB_NA12878_1_CL_Whole_C1_TPFWG_K18088_NOINDEX_L001_R1_001.fastq.gz",
      "fileType": "fastq",
      "fraction": "Whole",
      "glPrep": "Genome",
      "glType": "Genome",
      "index1Length": 6,
      "index2Length": 0,
      "limsLibraryRecordId": 64391,
      "numberOfReads": 228228468,
      "read1Length": 148,
      "read2Length": 148,
      "readOrientation": "Inward",
      "rgcn": "TGen",
      "rgid": "SUPERFQS01_1_K18088",
      "rgbc": "ATCACG",
      "rglb": "K18088",
      "rgpl": "ILLUMINA",
      "rgpm": "HiSeq2500",
      "rgpu": "SUPERFQS01_1",
      "rgsm": "GIAB_NA12878_1_CL_Whole_C1",
      "rnaStrandDirection": "NotApplicable",
      "rnaStrandType": "NotApplicable",
      "sampleMergeKey": "GIAB_NA12878_1_CL_Whole_C1_TPFWG",
      "sampleName": "GIAB_NA12878_1_CL_Whole_C1_TPFWG_K18088",
      "subGroup": "Constitutional",
      "umiInLine": "false",
      "umiLength": 0,
      "umiRead": false
    },
    {
      "assayCode": "TPFWG",
      "dnaRnaMergeKey": "GIAB_NA12878_1_CL_Whole",
      "fastqCode": "R2",
      "fastqPath": "/path/to/GIAB_NA12878_1_CL_Whole_C1_TPFWG_K18088_NOINDEX_L001_R2_001.fastq.gz",
      "fileType": "fastq",
      "fraction": "Whole",
      "glPrep": "Genome",
      "glType": "Genome",
      "index1Length": 6,
      "index2Length": 0,
      "limsLibraryRecordId": 64391,
      "numberOfReads": 228228468,
      "read1Length": 148,
      "read2Length": 148,
      "readOrientation": "Inward",
      "rgcn": "TGen",
      "rgid": "SUPERFQS01_1_K18088",
      "rgbc": "ATCACG",
      "rglb": "K18088",
      "rgpl": "ILLUMINA",
      "rgpm": "HiSeq2500",
      "rgpu": "SUPERFQS01_1",
      "rgsm": "GIAB_NA12878_1_CL_Whole_C1",
      "rnaStrandDirection": "NotApplicable",
      "rnaStrandType": "NotApplicable",
      "sampleMergeKey": "GIAB_NA12878_1_CL_Whole_C1_TPFWG",
      "sampleName": "GIAB_NA12878_1_CL_Whole_C1_TPFWG_K18088",
      "subGroup": "Constitutional",
      "umiInLine": "false",
      "umiLength": 0,
      "umiRead": false
    }
  ],
  "email": "user@tgen.org",
  "ethnicity": "Caucasian",
  "familyCode": "",
  "holdConfig": false,
  "hpcAccount": "tgen-#####",
  "isilonPath": "/example/giab/",
  "matchedNormal": true,
  "matchedNormalToUse": "",
  "maternalID": "",
  "patCode": "NA12878",
  "paternalID": "",
  "pipeline": "grandcanyon",
  "project": "GIAB_NA12878",
  "sex": "Female",
  "study": "GIAB",
  "submitter": "user",
  "submitterEmail": "user@tgen.org",
  "varDB": false
}
```

</details>

## TGen Naming Convention

GrandCanyon uses the TGen standardized naming convention to ensure every file has a unique but descriptive name:

```
STUDY_PATIENT_VISIT_SOURCE_FRACTION_SubgroupIncrement_ASSAY_LIBRARY
```

| Level | Format | Example |
|-------|--------|---------|
| Patient_ID | STUDY_PATIENT | `GIAB_NA12878` |
| Visit_ID | STUDY_PATIENT_VISIT | `GIAB_NA12878_1` |
| Specimen_ID | STUDY_PATIENT_VISIT_SOURCE | `GIAB_NA12878_1_CL` |
| Sample_ID | STUDY_PATIENT_VISIT_SOURCE_FRACTION | `GIAB_NA12878_1_CL_Whole` |
| RG.SM | ...SubgroupIncrement | `GIAB_NA12878_1_CL_Whole_C1` (VCF genotype column header) |
| sampleMergeKey | ...SubgroupIncrement_ASSAY | `GIAB_NA12878_1_CL_Whole_C1_TPFWG` (BAM filename) |

This design supports serial collection and multiple collections from different sources on a single day, with processing methods encoded in the name.

## Next Steps

- [Execution Guide](../execution-guide/) - how to initialize and run the pipeline
- [Tools Index](../../reference/tools-index/) - tools and task toggles by stage
- [Output Structure](../../outputs/) - where results are written
