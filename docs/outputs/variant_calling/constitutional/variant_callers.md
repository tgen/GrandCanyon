---
title: Constitutional Variant Callers
parent: Variant Calling
nav_order: 2
permalink: outputs/variant_calling/constitutional/
---

## Constitutional Variant Callers

GrandCanyon supports both short-read (Illumina) and long-read (PacBio HiFi, Oxford Nanopore) sequencing data for constitutional variant calling.

### Short-Read Callers (Illumina)

GrandCanyon can run up to four constitutional SNV/indel callers on `subGroup: constitutional` short-read DNA samples. Each is enabled individually through the `tasks` configuration object:

- GATK HaplotypeCaller (GVCF + GenotypeGVCFs)
- DeepVariant
- Strelka2
- VarDict

### Long-Read Callers (PacBio HiFi, Oxford Nanopore)

When long-read data is provided (`rgpl` set to `PACBIO` or `ONT`), GrandCanyon can use specialized callers that are optimized for the characteristics of long reads:

- **DeepVariant (Pangenome)**: Optimized for long-read data using the pangenome model.
- **Clair3**: Neural network-based caller effective in complex genomic regions.
- **ClairS**: Deep learning caller optimized specifically for long-read sequencing.

Additionally, long-read SV callers provide superior detection of structural variants in complex regions:

- **Sniffles2**: A structural variant caller designed for long-read data.
- **cuteSV**: Another SV caller tuned for long-read sequencing.
- **tRGT**: Specialized for tandem repeat genotyping using long reads.

Based on benchmarking results, we typically recommend DeepVariant over HaplotypeCaller when a single constitutional caller is desired; when possible, running multiple callers and comparing them is preferable. Long-read callers (DeepVariant Pangenome, Clair3, ClairS) are recommended when high accuracy in complex genomic regions is critical.

Constitutional results are written to `<glType>/constitutional_variant_calls/<caller>/<sample>_<aligner>/`, with per-caller files such as `<sample>.<aligner>.<caller>.all.vcf.gz` and `<sample>.<aligner>.<caller>.pass.vcf.gz`. The appropriate caller is selected based on the `tasks` configuration, the `rgpl` value, and the aligner used.
