---
title: Somatic Variant Callers
parent: Variant Calling
nav_order: 1
permalink: outputs/variant_calling/somatic/
---

## Somatic Variant Callers

In the GrandCanyon workflow we offer five somatic SNV/INDEL callers. These are:

- Mutect2
- Strelka2
- VarDict
- Lancet2
- DeepSomatic

These variant callers have a combination of strengths and weaknesses, and as
such it is recommended to use the output of VcfMerger2. VcfMerger2 homogenizes
many of the FORMAT fields such that variant calls can be merged into a single
line with no loss of information. These are additionally annotated with the
count of variant callers in agreement for a given variant. This count in stored
in INFO/CC and a minimum users should filter this file to CC>=2, and if all
five callers are used, then the CC>=3 is recommended. We're effectively looking
to filter to variants that _most_ of the variant callers agree on.

### Long-Read Somatic Variant Calling

For somatic analysis with long-read data, GrandCanyon supports specialized variant callers that can leverage the extended read lengths. When long-read sequencing data is detected, these callers provide better sensitivity for structural variants and complex rearrangements:

- **Sniffles2**: Detects somatic structural variants in long-read data with high precision.
- **cuteSV**: A long-read SV caller that excels in low-coverage scenarios.
- **Severus**: Integrates multiple signals from long reads for somatic SV detection.

These tools are conditionally enabled via the `tasks` configuration and are designed to capture large-scale genomic alterations that may be missed by short-read callers.
