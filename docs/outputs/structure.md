---
title: Output
nav_order: 5
permalink: outputs/
---

## Output Structure

Final output files are written under the project directory in a standardized layout that reflects the analysis type, tool, and sample:

```
Project
|--<glType>
|  |--<AnalysisType>
|  |  |--<Tool>
|  |  |  |--<SampleName_or_PairName>
|  |  |     |--<ResultFiles>
|  |--<AnalysisType>
|--<glType>
```

`<glType>` is one of `genome`, `exome`, or `rna`. `AnalysisType` is a descriptive folder such as `alignment`, `somatic_variant_calls`, or `quant`; `Tool` is the specific program (for example `bwa`, `mutect2`, or `salmon`); and `SampleName`/`PairName` follows the TGen naming convention.

### Example (directories only)

```
Project
├── exome
│   ├── alignment
│   │   └── bwa
│   │       └── SAMPLE_ID
│   │           └── stats
│   ├── constitutional_variant_calls
│   │   ├── deepvariant
│   │   │   └── SAMPLE_ID_bwa
│   │   └── haplotypecaller
│   │       └── SAMPLE_ID_bwa
│   ├── somatic_variant_calls
│   │   ├── mutect2
│   │   │   └── NORMAL_ID-TUMOR_ID_bwa
│   │   ├── vardict
│   │   │   └── NORMAL_ID-TUMOR_ID_bwa
│   │   └── vcfmerger2
│   │       └── NORMAL_ID-TUMOR_ID_bwa
│   ├── somatic_structural_calls
│   │   ├── manta
│   │   │   └── NORMAL_ID-TUMOR_ID_bwa
│   │   └── severus
│   │       └── NORMAL_ID-TUMOR_ID_bwa
│   └── somatic_copy_number
│       └── gatk
│           └── NORMAL_ID-TUMOR_ID_bwa
├── genome
│   ├── alignment
│   │   └── bwa
│   │       └── SAMPLE_ID
│   │           └── stats
│   ├── constitutional_variant_calls
│   │   ├── deepvariant
│   │   │   └── SAMPLE_ID_bwa
│   │   └── haplotypecaller
│   │       └── SAMPLE_ID_bwa
│   ├── constitutional_structural_calls
│   │   └── manta
│   │       └── SAMPLE_ID_bwa
│   ├── copy_number_analysis
│   │   └── ichorCNA
│   │       └── SAMPLE_ID_bwa
│   └── somatic_variant_calls
│       ├── mutect2
│       │   └── NORMAL_ID-TUMOR_ID_bwa
│       └── vcfmerger2
│           └── NORMAL_ID-TUMOR_ID_bwa
├── rna
│   ├── alignment
│   │   └── star
│   │       └── SAMPLE_ID
│   │           └── stats
│   ├── quant
│   │   ├── salmon
│   │   │   └── SAMPLE_ID
│   │   └── star
│   │       └── SAMPLE_ID
│   └── fusions
│       └── starfusion
│           └── SAMPLE_ID
├── qc
│   └── multiqc_data
└── jetstream
    ├── history
    └── logs
```

See [Interpreting Outputs](../analysis/interpreting-outputs/) for a guide to specific files within each directory.
