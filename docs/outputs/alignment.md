---
title: Alignment
parent: Output
nav_order: 1
permalink: outputs/alignment/
---

We highly encourage the use of CRAM files over BAM as in most cases the return
on space efficiency is worth the time spent on CRAM encode/decode.

### Short-Read Alignment

GrandCanyon uses `BWA-MEM2` for aligning short-read (Illumina) data. This is the
default aligner and is optimized for high accuracy with shorter read lengths.
Reads are split into chunks, aligned, marked for duplicates, and merged into a
per-sample BAM/CRAM. For long-read data or a pangenome, alternatives are enabled
through `tasks`: Minimap2 (long-read) and VG Giraffe (pangenome).

### Long-Read Alignment

For long-read sequencing data (PacBio HiFi or Oxford Nanopore), GrandCanyon
uses `Minimap2`, which is optimized for aligning longer read lengths and
detecting structural variants. The aligner is automatically selected based on
the `rgpl` value in the `dataFiles` configuration.

| Platform | Aligner |
|----------|---------|
| Illumina (short-read) | BWA-MEM2 |
| PacBio HiFi / ONT (long-read) | Minimap2 |
