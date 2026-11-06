---
layout: default
title: Execution Guide
parent: Getting Started
nav_order: 3
---

# Execution Guide

{: .note }
> Covers `jetstream init` and `jetstream pipelines` as used by GrandCanyon. For the shortest path, see the [Quick Start Guide](../quick-start/).

## Overview

Running GrandCanyon is a two-step process:

1. **`jetstream init`** - create a JetStream project and load your configuration.
2. **`jetstream pipelines grandcanyon`** - render the GrandCanyon template and execute it against the project.

## Step 1: Initialize the project

`jetstream init` creates a project directory and stores the configuration that the pipeline template reads at render time.

```console
$ jetstream init -h
usage: jetstream init [-h] [-l] [-p PROJECT] [-f] [--project-id PROJECT_ID]
                      [-c TYPE:KEY VALUE] [-C PATH]
                      [path]

Create or reinitialize a project. This command is used to create a new
Jetstream project directory. If no path is given, the current directory will
be initialized. If config data options are given (-c/--config/--config-file),
they will be added to the project config file.
```

### Key options

| Option | Description |
|--------|-------------|
| `path` | Directory to initialize (default: current directory) |
| `-C PATH, --config-file PATH` | Load template variables from a JSON file |
| `-c TYPE:KEY VALUE, --config TYPE:KEY VALUE` | Add a single template variable (repeatable) |
| `-p PROJECT, --project PROJECT` | Path to an existing JetStream project directory |
| `-f, --force` | Overwrite `project.yaml` |
| `--project-id PROJECT_ID` | Force a project ID instead of auto-generating one |
| `-l, --logging` | Set the logging profile |

### Example

```bash
jetstream init GIAB -C GIAB_NA12878_config.json
```

## Step 2: Run the pipeline

`jetstream pipelines` runs a named pipeline (`grandcanyon`) against a project.

```console
$ jetstream pipelines -h
usage: jetstream pipelines [-h] [-l] [-p PROJECT] [-o OUT] [-b] [-r]
                           [--backend {local,slurm}]
                           [--format {template,module,workflow}]
                           [--reset-method {retry,resume,reset}]
                           [--existing-workflow EXISTING_WORKFLOW]
                           [--template-dir [SEARCH_PATH]] [-c TYPE:KEY VALUE]
                           [-C PATH] [--pipelines-home PIPELINES_HOME] [-L]
                           [path]
```

### Key options

| Option | Description |
|--------|-------------|
| `path` | Pipeline name (e.g., `grandcanyon`) or path to a template/module/workflow |
| `-p PROJECT, --project PROJECT` | Path to the JetStream project directory |
| `-b, --build-only` | Render and build the workflow, then stop |
| `-r, --render-only` | Render the template and stop |
| `--backend {local,local_docker,local_singularity,slurm,slurm_singularity,dnanexus}` | Execution backend (default `slurm`) |
| `--reset-method {retry,resume,reset}` | Which tasks to reset before starting (`retry` pending+failed, `resume` pending, `reset` all) |
| `-C PATH, --config-file PATH` / `-c TYPE:KEY VALUE` | Template variables |
| `-o OUT, --out OUT` | Where to save workflow progress |
| `--existing-workflow EXISTING_WORKFLOW` | Merge into an existing workflow file |
| `--template-dir [SEARCH_PATH]` | Add a directory to the template search path (repeatable) |
| `--pipelines-home PIPELINES_HOME` | Override the pipelines install path |
| `-L, --list` | List installed pipelines |

### Examples

```bash
jetstream pipelines grandcanyon -p GIAB      # render, build, and run
jetstream pipelines grandcanyon -p GIAB -b   # render + build, do not run
jetstream pipelines grandcanyon -p GIAB -r   # render only
```

## Monitoring and logs

JetStream writes progress and logs under the project's `jetstream/` directory (for example `jetstream/history/` and `jetstream/logs/`). Use `-o OUT` to control where workflow progress is saved.

## What GrandCanyon renders

GrandCanyon's `main.j2` copies the input FASTQs into the project, then renders tasks for:

1. DNA alignment (BWA-MEM2, MiniBWA, Minimap2 for long reads, or VG Giraffe for pangenomes) with QC
2. RNA alignment/quantification (`star`, `salmon`) and fusion calling (`star_fusion`)
3. Constitutional variant calling - HaplotypeCaller, DeepVariant, DeepVariant (Pangenome), Clair3, ClairS, Strelka2, VarDict, plus Manta structural calls and CNV (iChorCNA, GATK-CNV)
4. Somatic variant calling - Mutect2, DeepSomatic, Strelka2, Lancet2, VarDict merged by VcfMerger2, plus Manta and long-read SV callers (Sniffles, cuteSV, PBSV, Dysgu, Savana, Severus) and GATK-CNV
5. Tumor-only variant calling - a parallel set of callers for tumors without a matched normal
6. Annotation (bcftools annotate + VEP) and somatic metrics (mutation burden, MSISensor, SigProfiler, tucon)
7. Finalization (MultiQC)

Most optional callers are controlled by `tasks` toggles in the configuration and are disabled unless enabled. See the [Configuration Guide](../configuration/).

## Troubleshooting

| Issue | Check |
|-------|-------|
| Container pull fails | Confirm Docker/Singularity is installed and the registry is reachable |
| Task fails immediately | Verify FASTQ paths and that each `rgid` has both `R1` and `R2` entries |
| Insufficient memory | Adjust task resource requests or reduce the number of samples |
| Expected output missing | Confirm the relevant `tasks` toggle is enabled in the configuration |

## Next Steps

- [Configuration Guide](../configuration/) - schema and task toggles
- [Interpreting Outputs](../../analysis/interpreting-outputs/) - find and understand results
- [Tools Index](../../reference/tools-index/) - tools used at each stage
