---
layout: default
title: Downstream Recommendations
parent: Analysis
nav_order: 2
---

# Downstream Recommendations

{: .note }
> The GrandCanyon pipeline produces high-quality variant calls and quantifications. These recommendations cover filtering, prioritization, and visualization for next-step analysis.

## Overview

This guide is a **work in progress** to provide task-specific advice on how to interpret and extend your results. Each section will includes:

- **Variant filtering** - Thresholds and rationale
- **Prioritization workflows** - Step-by-step from raw calls to candidates
- **Visualization** - Tools and recommended inputs
- **Code examples** - Copy-paste commands for common tasks

---

## Somatic Analysis

### Variant Filtering

The GrandCanyon pipeline applies built-in filtering to each caller, but downstream filtering ensures high-confidence results.

#### Single-Caller Filters (Per-Caller)

Apply these filters to each caller's filtered VCF before merging:

| Filter | Mutect2 | DeepSomatic | Strelka2 | Lancet2 | VarDict |
|--------|---------|-------------|----------|---------|---------|
| VAF (tumor) | ≥ 5% | ≥ 5% | ≥ 5% | ≥ 5% | ≥ 5% |
| VAF (normal) | ≤ 2% | ≤ 2% | ≤ 2% | ≤ 5% | ≤ 5% |

> [!NOTE]
> GrandCanyon does not apply a dedicated strand-bias filter in the post-merge filtering steps;
> callers apply their own internal strand checks while calling (e.g., VarDict's `teststrandbias.R`).
> For downstream review, we currently recommend visually inspecting candidate variants with IGV and
> reviewing caller-specific tag outputs (e.g., Mutect2's `FS`) individually. Dedicated recommendations
> for strand-bias thresholds are still pending team review.

#### Multi-Caller Consensus Filters

After VCFMerger2 merging:

| Scenario | Filter | Rationale |
|----------|--------|-----------|
| Standard | `CC >= 2` | At least 2 callers agree |
| All 5 callers | `CC >= 3` | Majority agreement |
| High-confidence | `CC >= 4` | Very stringent |
| Exploration | `CC >= 1` | All calls included |

#### bcftools Filtering Examples

```bash
# Filter multi-caller consensus for CC >= 3
bcftools filter -e 'INFO/CC < 3' merged.vcf.gz -Oz -o consensus_cc3.vcf.gz

# Filter a caller for tumor VAF >= 5% (adjust the field to your caller's VAF annotation)
bcftools filter -e 'FORMAT/AF < 0.05' caller.pass.vcf.gz -Oz -o filtered.vcf.gz

# Extract SNVs only (no indels)
bcftools view -v snps caller.pass.vcf.gz -Oz -o snvs_only.vcf.gz

# Extract indels only
bcftools view -v indels caller.pass.vcf.gz -Oz -o indels_only.vcf.gz
```

<!-- ### Prioritization Workflow -->
<!---->
<!-- #### Step 1: Filter to High-Confidence Variants -->
<!---->
<!-- ```bash -->
<!-- # Start with multi-caller consensus (CC >= 3) -->
<!-- bcftools filter -e 'INFO/CC < 3' merged.vcf.gz -Oz -o step1.vcf.gz -->
<!---->
<!-- # Keep only SNVs -->
<!-- bcftools view -v snps step1.vcf.gz -Oz -o step2_snvs.vcf.gz -->
<!---->
<!-- # Require PASS filter -->
<!-- bcftools filter -e 'FILTER != "PASS"' step2_snvs.vcf.gz -Oz -o step3_pass.vcf.gz -->
<!-- ``` -->
<!---->
<!-- #### Step 3: Filter for Protein-Altering Variants -->
<!---->
<!-- Using VEP's `--pick` flag, select the most consequential transcript per variant: -->
<!---->
<!-- ```bash -->
<!-- # Extract only high-impact consequences -->
<!-- bcftools grep -e 'CSQ.*HIGH' annotated.vcf.gz -Oz -o high_impact.vcf.gz -->
<!---->
<!-- # Or use VEP's --pick to get canonical transcript -->
<!-- vep --pick --filter "IMPACT=HIGH" annotated.vcf.gz -o pick_high.vcf.gz -->
<!-- ``` -->
<!---->
<!-- #### Step 4: Filter by Population Frequency -->
<!---->
<!-- ```bash -->
<!-- # Rare variants only (gnomAD AF < 0.1%; adjust to your annotation's AF field) -->
<!-- bcftools view -e 'INFO/AF < 0.001' high_impact.vcf.gz -Oz -o rare.vcf.gz -->
<!---->
<!-- # Somatic-specific: exclude variants with meaningful normal allele fraction -->
<!-- bcftools view -e 'FORMAT/AF > 0.02' rare.vcf.gz -Oz -o tumor_specific.vcf.gz -->
<!-- ``` -->
<!---->
<!-- #### Step 5: Cross-Reference Databases -->
<!---->
<!-- ```bash -->
<!-- # Check ClinVar status (requires ClinVar annotation) -->
<!-- bcftools view -i 'INFO/CLNDN!="."' tumor_specific.vcf.gz -Oz -o clinvar.vcf.gz -->
<!---->
<!-- # Check COSMIC (requires annotation with a COSMIC field) -->
<!-- bcftools view -i 'INFO/COSMIC!="."' tumor_specific.vcf.gz -Oz -o cosmic.vcf.gz -->
<!-- ``` -->
<!---->
<!-- ### Somatic Variant Prioritization Checklist -->
<!---->
<!-- | Priority Level | Criteria | Examples | -->
<!-- |---------------|----------|----------| -->
<!-- | **Tier 1** | HIGH impact, ClinVar pathogenic, tumor-specific | Known driver mutations | -->
<!-- | **Tier 2** | HIGH impact, COSMIC recurrent, tumor-specific | Known cancer mutations | -->
<!-- | **Tier 3** | HIGH impact, gnomAD rare, tumor-specific | Novel potential drivers | -->
<!-- | **Tier 4** | MODERATE impact, tumor-specific | Need functional validation | -->
<!-- | **Tier 5** | ALL tumor-specific | Broad exploration | -->
<!---->
<!-- ### Somatic Copy Number Analysis -->
<!---->
<!-- #### iChorCNA Interpretation -->
<!---->
<!-- iChorCNA output includes: -->
<!---->
<!-- | File | Purpose | -->
<!-- |------|---------| -->
<!-- | `<sample>.<aligner>.ichorCNA.params.txt` | Estimated tumor fraction and ploidy | -->
<!-- | `<sample>.<aligner>.ichorCNA.cna.seg` | Copy-number segments | -->
<!---->
<!-- **Key metrics:** -->
<!---->
<!-- | Metric | Interpretation | -->
<!-- |--------|---------------| -->
<!-- | Tumor purity | Higher = more reliable CN calls (target: > 0.1) | -->
<!-- | Log2 ratio | > 0: amplification, < 0: deletion, ≈ 0: diploid | -->
<!-- | CN segment | Integer copy number estimate | -->
<!---->
<!-- **Interpreting segments:** -->
<!---->
<!-- ```R -->
<!-- # R code to visualize iChorCNA segments -->
<!-- library(ggplot2) -->
<!-- segments <- read.table("<sample>.<aligner>.ichorCNA.cna.seg", header=TRUE)  # adjust columns to the file header -->
<!-- ggplot(segments, aes(x=pos, y=log2ratio, color=purity)) + -->
<!--   geom_point(alpha=0.6) + -->
<!--   geom_hline(yintercept=c(-1, -0.5, 0, 0.5, 1), linetype="dashed") + -->
<!--   theme_minimal() + -->
<!--   labs(y="Log2 Ratio", x="Position") -->
<!-- ``` -->
<!---->
<!-- #### GATK-CNV Interpretation -->
<!---->
<!-- GATK-CNV produces segmented copy number calls. Key outputs: -->
<!---->
<!-- | File | Description | -->
<!-- |------|-------------| -->
<!-- | `<sample>.<aligner>.called.seg` | Copy-number segments per sample | -->
<!-- | `<sample>.<aligner>.denoisedCR.tsv` | Denoised copy ratios | -->
<!---->
<!-- **Interpreting CN calls:** -->
<!---->
<!-- | CN Value | Interpretation | -->
<!-- |----------|---------------| -->
<!-- | 0 | Homozygous deletion | -->
<!-- | 1 | Hemizygous deletion | -->
<!-- | 2 | Diploid (normal) | -->
<!-- | 3 | Low-level amplification | -->
<!-- | ≥ 4 | High-level amplification | -->
<!---->
<!-- ### Somatic Mutational Burden & Signatures -->
<!---->
<!-- #### Tumor Mutational Burden (TMB) -->
<!---->
<!-- TMB is calculated by the `tgen_mutation_burden` tool. Key considerations: -->
<!---->
<!-- | TMB Range | Interpretation | -->
<!-- |-----------|---------------| -->
<!-- | < 5 mut/Mb | TMB-low | -->
<!-- | 5-10 mut/Mb | Intermediate | -->
<!-- | > 10 mut/Mb | TMB-high | -->
<!---->
<!-- #### Mutational Signatures -->
<!---->
<!-- SigProfilerAssignment identifies exposure to known COSMIC mutational signatures: -->
<!---->
<!-- | Signature | Associated With | -->
<!-- |-----------|----------------| -->
<!-- | SBS1 | Aging (clock-like) | -->
<!-- | SBS5 | Clock-like universal | -->
<!-- | SBS2/SBS13 | APOBEC activity | -->
<!-- | SBS4 | Tobacco smoking | -->
<!-- | SBS7a-d | UV exposure | -->
<!-- | SBS9 | Somatic hypermutation | -->
<!-- | SBS17a-b | UNG-related (uncertain) | -->
<!---->
<!-- ### Somatic Visualization Tools -->
<!---->
<!-- | Tool | Purpose | Input | Example Command | -->
<!-- |------|---------|-------|----------------| -->
<!-- | **IGV** | Visual inspection at variants | BAM + VCF | `igv -b aligned.cram -l variants.vcf.gz` | -->
<!-- | **VarInfoPlots** | VAF distribution plots | VCF | R script on VCF | -->
<!-- | **Oncoplot** (maftools) | Top mutated genes | Annotated VCF | `oncoplot(maf = maf)` | -->
<!-- | **Circos** | Chromosomal aberrations | SV + CNV calls | `circosplot(...)` | -->
<!-- | **Maftools** | Comprehensive cancer analysis | Annotated VCF → MAF | `readMaf("annotated.maf")` | -->
<!---->
<!-- **Converting VCF to MAF for maftools:** -->
<!-- ```bash -->
<!-- vcf2maf --ref-fasta /path/to/GRCh38.fa \ -->
<!--         --input-vcf annotated.vcf.gz \ -->
<!--         --output-maf output.maf -->
<!-- ``` -->
<!---->
<!-- --- -->
<!---->
<!-- ## Constitutional (Germline) Analysis -->
<!---->
<!-- {: .note } -->
<!-- > The pipeline uses "constitutional" throughout the configuration and output structure. "Germline" is used as a synonym in documentation. See the [Glossary](../../reference/glossary/) for full terminology. -->
<!---->
<!-- ### Variant Filtering -->
<!---->
<!-- #### Recommended Filters for Constitutional (Germline) Calls -->
<!---->
<!-- | Filter | Recommended Threshold | Tool-Specific Notes | -->
<!-- |--------|----------------------|-------------------| -->
<!-- | Quality by depth | QD ≥ 2.0 | GATK VQSR or hard filter | -->
<!-- | Read position bias | FS < 60 | GATK StrandFold or Fisher | -->
<!-- | Mapping quality | MQ ≥ 40 | GATK MQRankSum | -->
<!-- | Homopolymer region | Filter | Particularly for DeepVariant | -->
<!-- | Genotype quality | GQ ≥ 20 | Applied per genotype | -->
<!-- | Variant depth | DP ≥ 10 | Minimum depth for calling | -->
<!-- | Allele balance (het) | 0.25-0.75 | Expected for heterozygotes | -->
<!---->
<!-- #### GATK Hard Filter Example -->
<!---->
<!-- ```bash -->
<!-- # GATK-style hard filters -->
<!-- bcftools filter -e 'QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0' \ -->
<!--     haplotypecaller.vcf.gz -Oz -o filtered.vcf.gz -->
<!-- ``` -->
<!---->
<!-- #### DeepVariant Filtering -->
<!---->
<!-- DeepVariant applies internal quality filters. Recommended downstream: -->
<!---->
<!-- ```bash -->
<!-- # DeepVariant OUTPUT_GENERATION → PASS filter -->
<!-- bcftools filter -e 'FILTER != "PASS"' deepvariant.filtered.vcf.gz -Oz -o pass_only.vcf.gz -->
<!---->
<!-- # Additional depth and quality filters -->
<!-- bcftools filter -e 'DP < 10 || GQ < 20' pass_only.vcf.gz -Oz -o final_pass.vcf.gz -->
<!-- ``` -->
<!---->
<!-- ### Variant Interpretation -->
<!---->
<!-- #### Inheritance Pattern Filtering -->
<!---->
<!-- | Inheritance | Criteria | Example | -->
<!-- |-------------|----------|---------| -->
<!-- | **Autosomal dominant** | Heterozygous, affected status | Parent → child transmission | -->
<!-- | **Autosomal recessive** | Homozygous or compound heterozygous | Both parents carriers | -->
<!-- | **X-linked** | Hemi/male or het/female (X chromosome) | Carrier mother → affected son | -->
<!-- | **De novo** | Absent in parents, present in proband | Trio analysis required | -->
<!---->
<!-- #### Rare Variant Filtering Workflow -->
<!---->
<!-- ```bash -->
<!-- # Step 1: Extract rare variants (gnomAD AF < 0.1%) -->
<!-- bcftools view -e 'INFO/AF > 0.001' annotated.vcf.gz -Oz -o rare.vcf.gz -->
<!---->
<!-- # Step 2: Filter for high-impact consequences -->
<!-- bcftools grep -e 'CSQ.*HIGH' rare.vcf.gz -Oz -o high_impact_rare.vcf.gz -->
<!---->
<!-- # Step 3: Filter for ClinVar pathogenic/likely pathogenic -->
<!-- bcftools grep -e 'CLNDSN.*pathogenic\|CLNDSN.*likely.*pathogenic' high_impact_rare.vcf.gz -Oz -o clinvar_path.vcf.gz -i -->
<!-- ``` -->
<!---->
<!-- ### CNV Assessment -->
<!---->
<!-- #### iChorCNA Interpretation -->
<!---->
<!-- For constitutional samples, iChorCNA identifies large-scale CNAs: -->
<!---->
<!-- | Log2 Ratio | Likely CN | Interpretation | -->
<!-- |------------|-----------|---------------| -->
<!-- | -1.0 | 0 | Homozygous deletion | -->
<!-- | -0.5 | 1 | Hemizygous deletion | -->
<!-- | 0.0 | 2 | Diploid | -->
<!-- | 0.58 | 3 | Gain (trisomy) | -->
<!-- | 1.0 | 4 | Duplication | -->
<!---->
<!-- **Key outputs:** -->
<!---->
<!-- | File | Description | -->
<!-- |------|-------------| -->
<!-- | `<sample>.<aligner>.ichorCNA.cna.seg` | Copy-number segments | -->
<!-- | `<sample>.<aligner>.ichorCNA.params.txt` | Estimated tumor fraction/ploidy (expect low for constitutional) | -->
<!---->
<!-- #### GATK-CNV for Constitutional -->
<!---->
<!-- GATK-CNV uses a cohort approach for improved CNV detection: -->
<!---->
<!-- ```R -->
<!-- # R workflow for GATK-CNV -->
<!-- library(GATKCNVExplorer) -->
<!-- library(ggplot2) -->
<!---->
<!-- # Load segmented output -->
<!-- segments <- read.table("<sample>.<aligner>.called.seg", header=TRUE) -->
<!---->
<!-- # Plot copy number profile -->
<!-- plot(segments$pos, segments$cn, type="l", col="steelblue", -->
<!--      xlab="Chromosome Position", ylab="Copy Number") -->
<!-- abline(h=2, lty=2, col="red")  # Diploid line -->
<!-- ``` -->
<!---->
<!-- ### Constitutional Visualization Tools -->
<!---->
<!-- | Tool | Purpose | Input | -->
<!-- |------|---------|-------| -->
<!-- | **IGV** | Visual inspection of genotypes | BAM + VCF | -->
<!-- | **Hail Browser** | Large cohort visualization | VCF + metadata | -->
<!-- | **PLINK** | Association analysis, PCA | Genotype calls | -->
<!-- | **GatkCNVExplorer** | CNV visualization | CNV segments | -->
<!-- | **JBrowse** | Genome browser | BAM + VCF | -->
<!---->
<!-- ### Constitutional Quality Checks -->
<!---->
<!-- | Check | Method | Expected Result | -->
<!-- |-------|--------|----------------| -->
<!-- | Sample identity | VerifyBamID2 | Match expected genotype | -->
<!-- | Sex check | X/Y chromosome coverage | Matches reported sex | -->
<!-- | Relatedness | IBD estimation | Expected relationships | -->
<!-- | Contamination | VerifyBamID2 | < 2% contamination | -->
<!-- | Heterozygosity rate | VCF stats | ~1 in 1000 bp (human) | -->
<!---->
<!-- --- -->
<!---->
<!-- ## RNA-seq Analysis -->
<!---->
<!-- ### Differential Expression -->
<!---->
<!-- #### DESeq2 Workflow -->
<!---->
<!-- ```R -->
<!-- # Step 1: Load count data and metadata -->
<!-- library(DESeq2) -->
<!---->
<!-- # Load gene counts from GrandCanyon pipeline -->
<!-- counts <- read.table("gene_counts.tsv", header=TRUE, row.names=1, check.names=FALSE) -->
<!---->
<!-- # Sample metadata -->
<!-- colData <- data.frame( -->
<!--   row.names=colnames(counts), -->
<!--   condition=c("control", "control", "treatment", "treatment"), -->
<!--   batch=c("batch1", "batch1", "batch2", "batch2") -->
<!-- ) -->
<!---->
<!-- # Step 2: Create DESeqDataSet -->
<!-- dds <- DESeqDataSetFromMatrix(countData=counts, colData=colData, design=~batch+condition) -->
<!---->
<!-- # Step 3: Run DESeq -->
<!-- dds <- DESeq(dds) -->
<!---->
<!-- # Step 4: Extract results -->
<!-- res <- results(dds, contrast=c("condition","treatment","control")) -->
<!---->
<!-- # Step 5: Filter significant genes -->
<!-- sig <- subset(res, padj < 0.05 & abs(log2FoldChange) > 1) -->
<!---->
<!-- # Step 6: Export results -->
<!-- write.csv(as.data.frame(sig), "significant_genes.csv") -->
<!-- ``` -->
<!---->
<!-- #### edgeR Alternative -->
<!---->
<!-- ```R -->
<!-- library(edgeR) -->
<!---->
<!-- # Create DGEList -->
<!-- dge <- DGEList(counts=counts, group=colData$condition) -->
<!---->
<!-- # Normalize (TMM) -->
<!-- dge <- calcNormFactors(dge) -->
<!---->
<!-- # Estimate dispersion -->
<!-- dge <- estimateDisp(dge, design=model.matrix(~condition, data=colData)) -->
<!---->
<!-- # Exact test -->
<!-- et <- exactTest(dge, pair=c("control","treatment")) -->
<!---->
<!-- # Get significant genes -->
<!-- topTags(et, n=Inf, p.value=0.05) -->
<!-- ``` -->
<!---->
<!-- ### Filtering DE Results -->
<!---->
<!-- | Filter | Threshold | Rationale | -->
<!-- |--------|-----------|-----------| -->
<!-- | Adjusted p-value (FDR) | < 0.05 | 5% false discovery rate | -->
<!-- | \|log2FoldChange\| | > 1 | 2-fold change minimum | -->
<!-- | Mean count | > 10 | Low-count genes unreliable | -->
<!-- | Counts per million (CPM) | > 1 in ≥ N samples | Detectable expression | -->
<!---->
<!-- ### Fusion Gene Interpretation -->
<!---->
<!-- #### STAR-Fusion Output -->
<!---->
<!-- | Field | Description | -->
<!-- |-------|-------------| -->
<!-- | `FusionName` | Fusion gene identifier | -->
<!-- | `LeftGene` | 5' fusion partner | -->
<!-- | `RightGene` | 3' fusion partner | -->
<!-- | `FusionType` | Coding/non-coding | -->
<!-- | `SpanningReads` | Number of reads supporting fusion | -->
<!-- | `SplitReads` | Number of split reads | -->
<!-- | `CodingEffect` | Predicted coding impact | -->
<!---->
<!-- #### Filtering Fusion Calls -->
<!---->
<!-- | Filter | Recommended Value | Rationale | -->
<!-- |--------|------------------|-----------| -->
<!-- | Spanning reads | ≥ 5 | Sufficient evidence | -->
<!-- | Split reads | ≥ 1 | At least one supporting | -->
<!-- | Known fusions | Filter first | Clinically relevant | -->
<!-- | Novel fusions | Requires validation | Investigational | -->
<!---->
<!-- **Known fusion databases:** -->
<!-- - **ChimerDB** - Database of RNA fusions -->
<!-- - **FuZE** - Fusion catalog for leukemia -->
<!-- - **TCGA Fusion Portal** - Cancer-specific fusions -->
<!-- - **Clinical significance** - e.g., EML4-ALK, BCR-ABL, PML-RARA -->
<!---->
<!-- ### RNA-seq Quality Assessment -->
<!---->
<!-- #### Expected Ranges -->
<!---->
<!-- | Metric | Expected | Action if Out of Range | -->
<!-- |--------|----------|----------------------| -->
<!-- | % ribosomal RNA | < 20% | Review rRNA depletion | -->
<!-- | % mitochondrial | < 5% | Check cell health | -->
<!-- | 3'/5' bias | < 10% | Check RNA integrity (RIN) | -->
<!-- | Unique mapping | > 70% | Check contamination | -->
<!-- | Gene detection | > 15,000 | Check sequencing depth | -->
<!-- | Sample clustering | PC1 explains > 25% | Check batch effects | -->
<!-- | Properly paired | > 80% | Check library prep | -->
<!---->
<!-- #### Batch Effect Correction -->
<!---->
<!-- ```R -->
<!-- # ComBat for batch correction (sva package) -->
<!-- library(sva) -->
<!---->
<!-- # Normalize counts first -->
<!-- library(limma) -->
<!-- logCPM <- cpm(counts, log=TRUE, prior.count=2) -->
<!---->
<!-- # Apply ComBat -->
<!-- corrected <- ComBat(dat=logCPM, batch=colData$batch, mod=colData$condition) -->
<!---->
<!-- # Visualize before/after -->
<!-- pca_before <- prcomp(t(logCPM)) -->
<!-- pca_after <- prcomp(t(corrected)) -->
<!-- ``` -->
<!---->
<!-- --- -->
<!---->
<!-- ## Exome-Specific Recommendations -->
<!---->
<!-- ### Target Region Analysis -->
<!---->
<!-- 1. **Coverage uniformity** - Check % bases at ≥ 20× (exome targets) -->
<!-- 2. **Off-target rate** - Typically 1-5% for exome captures -->
<!-- 3. **Capture efficiency** - Compare observed vs. expected coverage -->
<!-- 4. **Depth distribution** - Look for uniform coverage across targets -->
<!---->
<!-- ### Additional Variant Filtering for Exome -->
<!---->
<!-- | Filter | Rationale | -->
<!-- |--------|-----------| -->
<!-- | Exclude low-complexity regions | Alignment artifacts in repetitive regions | -->
<!-- | Exclude segmental duplications | Mis-mapping between paralogs | -->
<!-- | Adjust for GC bias | GC-rich regions often under-covered | -->
<!---->
<!-- ### Exome Depth Analysis -->
<!---->
<!-- For CNV calling from exome data: -->
<!---->
<!-- | Tool | Purpose | Recommended Use | -->
<!-- |------|---------|----------------| -->
<!-- | **ExomeDepth** | Exome-specific CNV detection | Small cohorts | -->
<!-- | **Control-FREEC** | CNV from exome or WGS | Any depth | -->
<!-- | **GATK-CNV** | Reference-based CNV | Cohort with ≥ 10 samples | -->
<!---->
<!-- --- -->
<!---->
<!-- ## General Best Practices -->
<!---->
<!-- ### Data Validation -->
<!---->
<!-- | Check | Tool | Method | -->
<!-- |-------|------|--------| -->
<!-- | Sample identity | VerifyBamID2 | Cross-check genotype against reference | -->
<!-- | Gender check | GATK/BCFtools | X/Y chromosome coverage ratio | -->
<!-- | Contamination | VerifyBamID2 | Estimate contamination from heterozygosity | -->
<!-- | Relatedness | PLINK | IBD estimation between samples | -->
<!-- | Cross-contamination | CONTEST | Check for sample swaps | -->
<!---->
<!-- ### Reproducibility -->
<!---->
<!-- 1. **Record all filtering thresholds and scripts** - Version control them -->
<!-- 2. **Use version-controlled analysis pipelines** - Nextflow, Snakemake, or WDL -->
<!-- 3. **Containerize downstream analysis** - Docker/Singularity for tools -->
<!-- 4. **Track software versions** - Record exact tool versions used -->
<!-- 5. **Use standardized formats** - VCF v4.3+, MAF 1.0 -->
<!---->
<!-- ### Output Sharing -->
<!---->
<!-- | Practice | Method | -->
<!-- |----------|--------| -->
<!-- | VCF headers | Track filter steps in header | -->
<!-- | Metadata | Keep alongside results in structured format | -->
<!-- | Format standardization | VCF → MAF for publications | -->
<!-- | Data release | Use GA4GH-compliant formats | -->
<!---->
<!-- --- -->
<!---->
<!-- ## Analysis Workflow Summary -->
<!---->
<!-- ``` -->
<!-- ┌─────────────┐ -->
<!-- │   Raw VCF   │  (pipeline output) -->
<!-- └──────┬──────┘ -->
<!--        │ -->
<!--        ▼ -->
<!-- ┌──────────────────┐ -->
<!-- │  Filter          │  PASS, VAF, DP, quality scores -->
<!-- │  (bcftools)      │ -->
<!-- └──────┬───────────┘ -->
<!--        │ -->
<!--        ▼ -->
<!-- ┌──────────────────┐ -->
<!-- │  Annotate        │  VEP → CSQ, gnomAD, ClinVar -->
<!-- │  (VEP)           │ -->
<!-- └──────┬───────────┘ -->
<!--        │ -->
<!--        ▼ -->
<!-- ┌──────────────────┐ -->
<!-- │  Filter Rare     │  gnomAD AF < 0.1% -->
<!-- │  (bcftools)      │ -->
<!-- └──────┬───────────┘ -->
<!--        │ -->
<!--        ▼ -->
<!-- ┌──────────────────┐ -->
<!-- │  Filter Impact   │  HIGH or MODERATE CSQ -->
<!-- │  (bcftools)      │ -->
<!-- └──────┬───────────┘ -->
<!--        │ -->
<!--        ▼ -->
<!-- ┌──────────────────┐ -->
<!-- │  Cross-Reference │  ClinVar, COSMIC, OMIM -->
<!-- │  (manual/script) │ -->
<!-- └──────┬───────────┘ -->
<!--        │ -->
<!--        ▼ -->
<!-- ┌──────────────────┐ -->
<!-- │  Prioritize      │  Tier classification -->
<!-- │  (manual/script) │ -->
<!-- └──────┬───────────┘ -->
<!--        │ -->
<!--        ▼ -->
<!-- ┌──────────────────┐ -->
<!-- │  Visualize       │  IGV, maftools, custom plots -->
<!-- │  (IGV/R)         │ -->
<!-- └──────┬───────────┘ -->
<!--        │ -->
<!--        ▼ -->
<!-- ┌──────────────────┐ -->
<!-- │  Report          │  Summary table + figures -->
<!-- │  (R/Python)      │ -->
<!-- └──────────────────┘ -->
<!-- ``` -->

## See Also

- [Interpreting Outputs](../interpreting-outputs/) - Finding your results
- [Tool Descriptions](../../reference/tool-descriptions/) - Understanding pipeline tools
- [Configuration Guide](../../getting-started/configuration/) - Adjusting pipeline parameters
