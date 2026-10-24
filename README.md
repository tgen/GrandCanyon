![TGEN](images/TGen_Color_LOGO_medium.png)

# GrandCanyon

Jetstream workflow to support multiple genome references using long and short
read sequencing data. This is currently in early development stages, and
contributions are greatly appreciated.

<!--toc:start-->

- [GrandCanyon](#grandcanyon)
  - [Current Workflow Overview](#current-workflow-overview)
  - [Using GrandCanyon](#using-grandcanyon)
    - [JSON Structure](#json-structure)
      - [dataFiles](#datafiles)
        - [Data file attributes](#data-file-attributes)
        - [TGen Naming Convention](#tgen-naming-convention)
      - [Tasks](#tasks)
      - [Study and Pipeline Parameters](#study-and-pipeline-parameters)
    - [Advanced JSON Structure](#advanced-json-structure)
      - [Enable tumor only always](#enable-tumor-only-always)
      - [Input pre-aligned dataFiles](#input-pre-aligned-datafiles)
      - [Custom reference](#custom-reference)
  - [Output Folder Structure](#output-folder-structure)
  <!--toc:end-->

## Current Workflow Overview

![GrandCanyon](images/GrandCanyonOverview.png)

## Using GrandCanyon

For most internal users, we recommend using the internal LIMS system to
initiate the workflow, this will generate and submit a json that meets the
requirements for the pipeline. By default the GRCh38 reference will be used.
For advanced and/or non-LIMS usage, the json input can be described in 3 parts:
dataFiles, tasks, and study/pipeline parameters. The most detailed being the
dataFiles, we will start with a description of these.

### JSON Structure

#### dataFiles

For each of our data files/fastqs we have some required data, many of which are
self explained, but we will explain the more unique variables. Here is an
example:

```json
"dataFiles": [
                {
                        "assayCode" : "OUL14",
                        "fastqCode" : "duplex",
                        "fastqPath" : "/path/to/COLO829BL_ATCCJJK_p27_CL_1_C3_OUL14_L81167_PAO93303_NNNNNNNN_L001.duplex.u.bam",
                        "fileType" : "ubam",
                        "fraction" : "1",
                        "glPrep" : "LongRead",
                        "glType" : "Genome",
                        "rgbc" : "NNNNNNNN",
                        "rgcn" : "TGen",
                        "rgid" : "PAO93303_1_NNNNNNNN-NNNNNNNN",
                        "rglb" : "L81167",
                        "rgpl" : "ONT",
                        "rgpm" : "PromethION",
                        "rgpu" : "PAO93303_1",
                        "rgsm" : "COLO829BL_ATCCJJK_p27_CL_1_C3",
                        "rnaStrandDirection" : "NotApplicable",
                        "rnaStrandType" : "NotApplicable",
                        "sampleMergeKey" : "COLO829BL_ATCCJJK_p27_CL_1_C3_OUL14",
                        "sampleName" : "COLO829BL_ATCCJJK_p27_CL_1_C3_OUL14_L81167",
                        "subGroup" : "Constitutional"
                },
                {
                        "assayCode" : "PSB3G",
                        "fastqCode" : "hifi",
                        "fastqPath" : "/path/to/COLO829BL_ATCCJJK_p27_CL_1_C3_PSB3G_L82718_a484042d_ACGCACGT_L001.hifi.u.bam",
                        "fileType" : "ubam",
                        "fraction" : "1",
                        "glPrep" : "LongRead",
                        "glType" : "Genome",
                        "rgbc" : "ACGCACGTCCGAGCAC",
                        "rgcn" : "TGen",
                        "rgid" : "a484042d_1_ACGCACGTCCGAGCAC",
                        "rglb" : "L82718",
                        "rgpl" : "PACBIO",
                        "rgpm" : "REVIO",
                        "rgpu" : "a484042d_1",
                        "rgsm" : "COLO829BL_ATCCJJK_p27_CL_1_C3",
                        "rnaStrandDirection" : "NotApplicable",
                        "rnaStrandType" : "NotApplicable",
                        "sampleMergeKey" : "COLO829BL_ATCCJJK_p27_CL_1_C3_PSB3G",
                        "sampleName" : "COLO829BL_ATCCJJK_p27_CL_1_C3_PSB3G_L82718",
                        "subGroup" : "Constitutional"
                }
```

##### Data file attributes

There are restrictions on what some of these variables can be assigned to,
these will be denoted in the [ ]'s. If the attribute isn't strictly required
then it is not included in this list.

- _assayCode_
  Used for determining if the sample is DNA/RNA/etc. and adding the
  corresponding tasks to the final workflow. Each sample discovered will take
  this attribute from the first file encountered for that sample in the config
  file.

- _fastqCode_ [simplex,duplex,hifi]  
   Assigns the format/code for the input data.

- _fastqPath_
  Assigns the path to the fastq.

- _fileType_  
   Assigns the file type.

- _glPrep_ [genome|capture|rna]  
   Used for determining the prep used to create the sample and then modifying
  how the pipeline runs depending on the prep. This is used to configure single
  cell.

- _glType_ [genome|exome|rna]  
   Used for determining if the sample is DNA/RNA/etc. and adding the
  corresponding tasks to the final workflow. Each sample discovered will take
  this attribute from the first file encountered for that sample in the config
  file.

- _rg values_  
   These are standards set in the [SAM/BAM Format
  Specification](https://samtools.github.io/hts-specs/SAMv1.pdf):  
   rgcn - Name of sequencing center producing the read  
   rgid - Read group identifier.  
   rgbc - Barcode sequence identifying the sample or library.  
   rglb - Unique identifier for the library.  
   rgpl - Platform/technology used to produce the reads.  
   rgpm - Platform model. Used to configure platform duplicate marking
  thresholds. Free-form text providing further details of the platform/technology
  used.  
   rgpu - Platform unit (e.g., flowcell-barcode.lane for Illumina or slide for
  SOLiD). Unique identifier.  
   rgsm - Sample. Use pool name where a pool is being sequenced.

- _fraction_  
   Relevant to the TGen naming scheme. See TGen Naming Convention.

- _sampleMergeKey_
  This is the expected BAM filename and is used to merge data from multiple
  sequencing lanes or flowcells for data from the same specimen (rgsm) tested
  with the same assay

- _sampleName_  
   This is the expected base FASTQ filename.

- _subGroup_
  Sets where the data file is for tumour or constitutional, changes the
  analysis of the data file as well as sets the distinction of files during
  somatic analysis.

##### TGen Naming Convention

Many of the naming structures used are defined by the standardize naming
structure used at TGen that ensures all files have a unique but descriptive
name. It is designed to support serial collection and multiple collections from
difference sources on a single day. Furthermore, sample processing methods can
be encoded.

STUDY_PATIENT_VISIT_SOURCE_FRACTION_SubgroupIncrement_ASSAY_LIBRARY

Patient_ID = STUDY_PATIENT  
Visit_ID = STUDY_PATIENT_VISIT  
Specimen_ID = STUDY_PATIENT_VISIT_SOURCE  
Sample_ID = STUDY_PATIENT_VISIT_SOURCE_FRACTION  
RGSM = STUDY_PATIENT_VISIT_SOURCE_FRACTION_SubgroupIncrement (VCF file
genotype column header)  
sampleMergeKey = STUDY_PATIENT_VISIT_SOURCE_FRACTION_SubgroupIncrement_ASSAY
(BAM filename, ensures different assays are not merged together)

#### Tasks

The tasks object allows us to enable and disable certain portions of the
workflow. E.g. if you are only interested in alignment results, we can enable
only the alignment task. A typical set of tasks looks like the following:

```json
    "tasks": {
        "Exome_quality_control_stats_gatk_CollectMultipleMetrics": true,
        "Exome_quality_control_stats_samtools_idxstats": true,
        "Exome_quality_control_stats_samtools_stats": true,
        "Exome_variant_calling_annotate_vcfs_bcftools_clinvar": true,
        "Exome_variant_calling_annotate_vcfs_bcftools_dbsnp": true,
        "Exome_variant_calling_annotate_vcfs_bcftools_gnomad": true,
        "Exome_variant_calling_annotate_vcfs_vep": true,
        "Exome_variant_calling_cna_caller_cytocad": false,
        "Exome_variant_calling_cna_caller_hificnv": false,
        "Exome_variant_calling_snp_indel_caller_clair3": true,
        "Exome_variant_calling_snp_indel_caller_clairs": true,
        "Exome_variant_calling_snp_indel_caller_deepsomatic": true,
        "Exome_variant_calling_snp_indel_caller_deepvariant": true,
        "Exome_variant_calling_snp_indel_caller_longshot": false,
        "Exome_variant_calling_structural_caller_cutesv": false,
        "Exome_variant_calling_structural_caller_dysgu": false,
        "Exome_variant_calling_structural_caller_severus": true,
        "Exome_variant_calling_structural_caller_sniffles": false,
        "Genome_assembly_long_read_assembler_flye": false,
        "Genome_assembly_long_read_assembler_hifiasm": false,
        "Genome_assembly_long_read_assembler_shasta": false,
        "Genome_assembly_long_read_assembler_verkko": false,
        "Genome_quality_control_stats_gatk_CollectMultipleMetrics": true,
        "Genome_quality_control_stats_samtools_idxstats": true,
        "Genome_quality_control_stats_samtools_stats": true,
        "Genome_variant_calling_annotate_vcfs_bcftools_clinvar": true,
        "Genome_variant_calling_annotate_vcfs_bcftools_dbsnp": true,
        "Genome_variant_calling_annotate_vcfs_bcftools_gnomad": true,
        "Genome_variant_calling_annotate_vcfs_vep": true,
        "Genome_variant_calling_cna_caller_cytocad": false,
        "Genome_variant_calling_cna_caller_hificnv": false,
        "Genome_variant_calling_snp_indel_caller_clair3": true,
        "Genome_variant_calling_snp_indel_caller_clairs": true,
        "Genome_variant_calling_snp_indel_caller_deepsomatic": true,
        "Genome_variant_calling_snp_indel_caller_deepvariant": true,
        "Genome_variant_calling_snp_indel_caller_longshot": false,
        "Genome_variant_calling_structural_caller_cutesv": false,
        "Genome_variant_calling_structural_caller_dysgu": false,
        "Genome_variant_calling_structural_caller_severus": true,
        "Genome_variant_calling_structural_caller_sniffles": true,
        "RNA_quality_control_stats_gatk_CollectRnaSeqMetrics": true,
        "RNA_sirvome_enable_processing_sirvome": false,
        "RNA_transcriptome_quantify_expression_featureCounts": true,
        "RNA_transcriptome_quantify_expression_flair": false,
        "RNA_transcriptome_quantify_expression_isoquant": true,
        "RNA_transcriptome_quantify_expression_salmon": true
    },
```

It should be noted that some tasks are dependant on others, a perfect example
of this is the relationship between Illumina Manta and Strelka2. The candidate
events from Manta are provided to Strelka2 as an input. Therefore, if we want
Strelka2 results, then we will need to enable Manta. Users with experience
using previous Jetstream pipelines will notice that this list is much shorter,
as we previously enabled tasks independently for constitutional, somatic, and
tumor_only configurations. This has now been simplified. For example again with
Manta, if the dataFiles only contain constitutional/germline/normal/control
samples, then Manta will run in a constitutional mode; if only a tumor/case
sample is provided then Manta will run in a tumor only mode; if both a normal
and tumor are provided, then Manta will run constitutional mode for the normal,
and a paired tumor-normal somatic mode for the tumor-normal pair. If you have a
question about your configuration, please feel free to open a GitHub discussion
or reach out to <jetstream@tgen.org>

#### Study and Pipeline Parameters

This is a catch-all category for all non-dataFiles and non-tasks configuration.
The variables here are mostly self explanatory. Here is an example:

```json
    "email": "bturner@tgen.org,example@tgen.org",
    "ethnicity": "Unknown",
    "hpcAccount": "tgen-524000",
    "isilonPath": "/path/to/store/grandcanyon/results/",
    "pipeline": "grandcanyon@development",
    "project": "KMS27_JCRB",
    "sex": "Male",
    "study": "MMCL",
    "studyDisease": "Multiple Myeloma",
    "submitter": "bturner",
```

The only required variable for running the pipeline by hand is `project`. For
submissions to the Jetstream Centro server `email`, `hpcAccount`, `isilonPath`,
`pipeline`, and `project` are required.

The json does not have a required order, and only the expected values will be used for analysis. This means one could, for example, add a time stamp to the json if they want to note the date the json was created. Additionally, notes can be added as long as they don't override the previously set json value. However this override behavior can be very powerful and use cases are described in the [advanced usage](#advanced-json-structure) section.

### Advanced JSON Structure

The [JSON Structure](#json-structure) section describes typical usage, but there are some non-standard configuration that might be better suited for your analysis. Here are some examples of advanced usage:

- Enabling tumor only analysis in addition to paired tumor-normal
- Input pre-aligned dataFiles - Currently only supports BAM as an input type
- Custom reference - A reference fasta is required; A gtf is required for RNAseq

#### Enable tumor only always

This is a simple edit to the json which modifies the variant calling pairing
behavior to still perform tumor only somatic analysis despite also providing
the normal. In most cases, the paired somatic variant calling will have
significantly less false positive calls, and this output should be preferred.
However, it may also make sense to output tumor only variant calling data if
your cohort is asymmetrical in terms of tumor and normal, e.g. you want to be
able to compare tumor only results across the entire study cohort because a
significant portion of samples do not have a normal to pair with. This edit is
as simple as adding the following line to the JSON [pipeline
parameters](#study-and-pipeline-parameters):

```json
"allow_tumor_only": true,
```

#### Input pre-aligned dataFiles

If the data you are analyzing is from a collaborator or downloaded from an external source, you are more likely to have a BAM or CRAM file instead of fastq data. GrandCanyon has some basic support for pre-aligned file inputs, but there are some limitations to be aware of.

- If a BAM/CRAM is supplied along with fastq data, the BAM/CRAM will be ignored
- The supplied BAM/CRAM MUST match the reference fasta used by the pipeline,
  otherwise it will fail (de)compression
- Multiple BAM/CRAM inputs can be supplied for the same sample, but they will
  be merged together for analysis
- We will NOT attempt to pull RG tags from the BAM/CRAM header
- We will assume the BAM/CRAM is aligned with the aligner defined in the task configuration
  - This also means the output directories will use this aligner definition
  - The pipeline will NOT attempt to realign the input files, if you are
    looking to realign the reads please convert the BAM/CRAM back to fastq files
- Some analyses are only possible when given fastq inputs, for example many
  RNAseq tasks like salmon, STAR, and STAR-Fusion require fastq inputs

Given the above limitations, using a BAM/CRAM is as simple as changing the
fileType definition, for example:

```json
{
  "dataFiles": [
    {
      "assayCode": "OUL14",
      "path": "/path/to/input.bam",
      "fileType": "bam",
      "glPrep": "LongRead",
      "glType": "Genome",
      "rgid": "SOME_RGID",
      "rglb": "L12345",
      "rgpl": "ONT",
      "rgpm": "PromethION",
      "rgsm": "INPUT_EXAMPLE",
      "sampleMergeKey": "INPUT_EXAMPLE",
      "sampleName": "INPUT_EXAMPLE",
      "subGroup": "Constitutional"
    }
  ]
}
```

#### Custom reference

This use case leverages the override behavior mentioned earlier, and it can be
very powerful. Since the render order is GrandCanyon definition, then user
defined input, the user can override the definition for a reference. Here is an
example for using a mouse reference:

```json
{
  "constants": {
    "grandcanyon": {
      "grcm39": {
        "reference_fasta": "/path/to/Mus_musculus.GRCm39.dna.toplevel.fa",
        "gtf": "/path/to/Mus_musculus.GRCm39.114.gtf"
      }
    }
  },
  "dataFiles": [
      {
      ...
      },
  ],
  "reference": "grcm39",
  "isilonPath": "/path/to/store/grandcanyon/results/",
  "pipeline": "grandcanyon@development",
  "project": "MUS_0001",
  "sex": "Male",
  "study": "MUS",
  "submitter": "example",
}
```

First we defined what `grcm39` means for the pipeline. Then later we told the
pipeline to use `grcm39` as the reference. Note that this order does not have
an impact on the pipeline render. GrandCanyon will check for which files are
defined for a reference, and if all other necessary inputs are provided, then
it will create all resources it needs for processing the data against the given
reference. Resource creation will write files to the same directory as the
input reference files, therefore these paths **MUST** be writable. For this
reason it also recommended to only run GrandCanyon for a single project first,
and then larger batches can be submitted.

## Output Folder Structure

All final output files are placed in a standardized folder structure that
generally reflects the relationship of files or the processing order.

```
Project
|--GeneralLibaryType
|  |--AnalysisType
|  |  |--Tool
|  |  |  |--SampleName
|  |  |     |--ResultFiles
|  |  |--Tool
|  |--AnalysisType
|--GeneralLibaryType
```

<details>
  <summary><b>Project Folder Example</b></summary>

```
# Only Directories are Shown
COLO829
├── genome
│   ├── alignment
│   │   └── minimap2
│   │       ├── COLO829BL_ATCCJJK_p27_CL_1_C3_OUL14
│   │       │   └── stats
│   │       └── COLO829BL_ATCCJJK_p27_CL_1_C3_PSB3G
│   │           └── stats
│   ├── constitutional_variant_calls
│   │   ├── cutesv
│   │   │   └── COLO829BL_ATCCJJK_p27_CL_1_C3_OUL14_minimap2
│   │   │   └── COLO829BL_ATCCJJK_p27_CL_1_C3_PSB3G_minimap2
│   │   ├── deepvariant
│   │   │   └── COLO829BL_ATCCJJK_p27_CL_1_C3_OUL14_minimap2
│   │   │   └── COLO829BL_ATCCJJK_p27_CL_1_C3_PSB3G_minimap2
│   │   ├── dysgu
│   │   │   └── COLO829BL_ATCCJJK_p27_CL_1_C3_OUL14_minimap2
│   │   │   └── COLO829BL_ATCCJJK_p27_CL_1_C3_PSB3G_minimap2
│   │   ├── severus
│   │   │   └── COLO829BL_ATCCJJK_p27_CL_1_C3_OUL14_minimap2
│   │   │   └── COLO829BL_ATCCJJK_p27_CL_1_C3_PSB3G_minimap2
│   │   └── sniffles
│   │       └── COLO829BL_ATCCJJK_p27_CL_1_C3_OUL14_minimap2
│   │       └── COLO829BL_ATCCJJK_p27_CL_1_C3_PSB3G_minimap2
│   ├── constitutional_copy_number
│   │   ├── cytocad
│   │   │   └── COLO829BL_ATCCJJK_p27_CL_1_C3_OUL14_minimap2
│   │   │   └── COLO829BL_ATCCJJK_p27_CL_1_C3_PSB3G_minimap2
│   │   └── hifi_cnv
│   │       └── COLO829BL_ATCCJJK_p27_CL_1_C3_PSB3G_minimap2
│   ├── history
│   └── logs
└── rna
    ├── alignment
    │   └── minimap2
    │       └── COLO829BL_ATCCJJK_p27_CL_1_C3_ORPC9
    │           └── stats
    └── quant
        ├── featureCounts
        │   └── COLO829BL_ATCCJJK_p27_CL_1_C3_ORPC9
        ├── flair
        │   └── COLO829BL_ATCCJJK_p27_CL_1_C3_ORPC9
        ├── isoquant
        │   └── COLO829BL_ATCCJJK_p27_CL_1_C3_ORPC9
        └── salmon
            └── COLO829BL_ATCCJJK_p27_CL_1_C3_ORPC9
```

</details>
