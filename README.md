# GrandCanyon
Jetstream workflow to support the T2T Consortium CHM13 reference genome, through both long and short read sequencing data. This 
currently in very early development stages, and contributions are greatly appreciated.

## Hackathon specifics
On August 16th and 17th of 2023, a hackathon will be (or currently is being) held to rapidly integrate many of the core components of the pipeline. We plan to utilize all of the contributions during and after this hackathon to build a Jetstream based workflow, as Jetstream is already heavily integrated into the TGen compute infrastructure. But early development can be in any language the community sees fit. Most workflows will likely be a simple set of shell commands, but we are happy to accept and are expecting submissions in other languages such as python, R, nextflow, snakemake. Whichever language you are able to work in the most efficiently.

### Contribution Guidelines
This is intended to be mashed together very quickly, as such, please create a fork of the repository, or create a new branch off of `development`. Following this, please place your script in specific and likely uniquely named directory. For example, if you plan to work on structural variant calling, this is my recommended start up template:
```bash
cd /to/wherever/you/keep/git/repos
git clone git@github.com:tgen/GrandCanyon.git # This clones via an ssh key, let me know if you need help setting one up
cd GrandCanyon
git checkout development # We want to branch off of development (I will likely set the default branch to development to avoid issues)
git checkout -b bturner-sv-calling # This creates a new branch from the branch you are currently on (development) and checks you into it immediately
mkdir bturner_sv_caller_sniffles # Example of unique directory path
cd bturner_sv_caller_sniffles
# Start creating your workflow
vim sniffles.sh
```

Here is an example on gemini:
```console
[bturner@gemini-login1:~]$ cd git_repos/
[bturner@gemini-login1:~/git_repos]$ git clone git@github.com:tgen/GrandCanyon.git
Cloning into 'GrandCanyon'...
remote: Enumerating objects: 7, done.
remote: Total 7 (delta 0), reused 0 (delta 0), pack-reused 7
Receiving objects: 100% (7/7), done.
Resolving deltas: 100% (1/1), done.
[bturner@gemini-login1:~/git_repos]$ cd GrandCanyon/
[bturner@gemini-login1:~/git_repos/GrandCanyon]$ git branch
* main
[bturner@gemini-login1:~/git_repos/GrandCanyon]$ git checkout development
Branch 'development' set up to track remote branch 'development' from 'origin'.
Switched to a new branch 'development'
[bturner@gemini-login1:~/git_repos/GrandCanyon]$ git checkout -b bturner-sv-calling
Switched to a new branch 'bturner-sv-calling'
[bturner@gemini-login1:~/git_repos/GrandCanyon]$ mkdir bturner_sv_caller_sniffles
[bturner@gemini-login1:~/git_repos/GrandCanyon]$ cd bturner_sv_caller_sniffles/
[bturner@gemini-login1:~/git_repos/GrandCanyon/bturner_sv_caller_sniffles]$ vim sniffles.sh
```

From here I would be ready to run `git add bturner_sv_caller_sniffles/sniffles.sh` and then `git commit -m "created a sniffles sv caller script on the first try"`, and finally `git push -u origin bturner-sv-calling`. Note that subsequent commits and pushes would only require `git push`, that initial push is publishing the branch and setting your local git to use the origin as the upstream.

It's also highly recommended for you to either ensure that comments are detailed enough that a Helios Scholar could pick up the script and use it effectively, or create a readme.md within your uniquely named directory.

### Resources
To save time both computationally and for development, we have precompiled a set of likely resources. But feel free to create your own and detail to us how you did it. We have placed these resources on both gemini and dback to make sure everyone has access to them and also to distribute some of the compute load that will be happening over these few days.

__Example data__
- Oxford Nanopore
  - Public CHM13 (120X depth): `/scratch/bturner/grandcanyon/oxford_nano_data/rel3.fastq.gz`
  - HG002 NA24385(~30X depth?): `/scratch/bturner/grandcanyon/oxford_nano_data/ultra-long-ont.fastq.gz`
  - `/scratch/bturner/grandcanyon/oxford_nano_data/tumor_KMS11/KMS11_JCRBsus_p19_CL_Whole_T1_OGL14_L72205.fastq`
  - `/scratch/bturner/grandcanyon/oxford_nano_data/tumor_KMS11/duplex_updated.ubam`
  - `/scratch/bturner/grandcanyon/oxford_nano_data/tumor_KMS11/KMS11_JPN.FGFR3_Read_short.fa.sorted.bam`
  - `/scratch/bturner/grandcanyon/oxford_nano_data/tumor_KMS11/KMS11_JPN.sorted.ont.chm13.bam`

- PacBio
  - COLO829 (~20X depth): `/scratch/bturner/grandcanyon/pacbio_revio_data/estimated_20X_depth/COLO829BL_ATCCJJK_p1_CL_C2_mm_rg_sort.cram`
  - SRR9087600: `/scratch/bturner/grandcanyon/pacbio_revio_data/SRX5633451/SRR9087600.fastq.gz`

CHM13 v2 resources:  
The marbl/CHM13 repo has most if not all resources that could be needed for utilizing CHM13 https://github.com/marbl/CHM13

__Paths to resources (on both dback and gemini)__  
Reference fasta: `/home/tgenref/homo_sapiens/t2t_chm13/chm13_v2/genome_reference/chm13v2.0_maskedY_rCRS.fa`  
Reference fasta index: `/home/tgenref/homo_sapiens/t2t_chm13/chm13_v2/genome_reference/chm13v2.0_maskedY_rCRS.fa.fai`  
Reference dictionary: `/home/tgenref/homo_sapiens/t2t_chm13/chm13_v2/genome_reference/chm13v2.0_maskedY_rCRS.dict`  

Ensembl rapid release gtf: `/home/tgenref/homo_sapiens/t2t_chm13/chm13_v2/gene_model/Homo_sapiens-GCA_009914755.4-2022_06-genes.gtf.gz`  
Ensembl vep cache: `/home/tgenref/homo_sapiens/t2t_chm13/chm13_v2/gene_model/indexed_vep_cache`  

### Inspirations
Here is a list of potential inspirations on how to run specific workflows - in other words, PacBio and ONT have some recommended workflows that are written in different formats. For example, PacBio has written a lot of workflows in wdl format and it looks like ONT has written workflows in Nextflow (Vince will be happy to see these). I'd potentially take these workflows with a grain of salt though, as most will likely be biased to using their internal tools, while other open-source tools might be faster, more accurate, or feature rich.
 - https://github.com/PacificBiosciences
 - https://github.com/PacificBiosciences/wdl-humanwgs
 - https://github.com/nanoporetech
 - https://github.com/epi2me-labs
 - https://github.com/epi2me-labs/wf-human-variation
 - https://nf-co.re/nanoseq/3.1.0
 - https://github.com/nf-core/nanoseq


### Containers
As we are limited to singularity on both clusters, we have prepared a set of container images that we expected people will need. They have all been placed under `/home/tgenref/containers/grandcanyon/`. But if you can't find what you are looking for, it probably is available somewhere publically as a docker image. I'd recommend checking out hub.docker.com or there is a great set of tools available on quay.io (Bryce's "pro" tip, bioconda has a fantastic set of community built images and they have an easy to navigate index [here](https://bioconda.github.io/conda-package_index.html))

__Paths to containers (on both dback and gemini)__
| Tool Name | Path |
| --- | --- |
| __Common Tools__ ||
| bcftools | /home/tgenref/containers/grandcanyon/common_tools/bcftools_1.17--h3cc50cf_1.sif |
| samtools | /home/tgenref/containers/grandcanyon/common_tools/samtools_1.17--hd87286a_1.sif |
| gatk | /home/tgenref/containers/grandcanyon/common_tools/gatk_4.4.0.0.sif |
| __Assembly Tools__ ||
| canu | /home/tgenref/containers/grandcanyon/assembly_tools/canu_2.2--ha47f30e_0.sif |
| flye | /home/tgenref/containers/grandcanyon/assembly_tools/flye_2.9.2--py310h2b6aa90_2.sif |
| hifiasm | /home/tgenref/containers/grandcanyon/assembly_tools/hifiasm_0.19.5--h43eeafb_2.sif |
| shasta | /home/tgenref/containers/grandcanyon/assembly_tools/shasta_0.11.1--h4ac6f70_2.sif |
| verkko | /home/tgenref/containers/grandcanyon/assembly_tools/verkko_1.4.1--h48217b1_0.sif |
| __Alignment Tools__ | _also check the platform specific directories_ |
| minimap2 | /home/tgenref/containers/grandcanyon/alignment/minimap2_2.26--he4a0461_1.sif |
|||
| __PacBio Tools__ ||
| pbbam | /home/tgenref/containers/grandcanyon/pacbio/pbbam_2.1.0--h8db2425_5.sif |
| pbccs | /home/tgenref/containers/grandcanyon/pacbio/pbccs_6.4.0--h9ee0642_0.sif |
| pbfusion | /home/tgenref/containers/grandcanyon/pacbio/pbfusion_0.3.0--hdfd78af_0.sif |
| pbh5tools | /home/tgenref/containers/grandcanyon/pacbio/pbh5tools_0.8.0--py27h9801fc8_6.sif |
| pbhoover | /home/tgenref/containers/grandcanyon/pacbio/pbhoover_1.1.0--pyhdfd78af_1.sif |
| pbiotools | /home/tgenref/containers/grandcanyon/pacbio/pbiotools_4.0.1--pyh7cba7a3_1.sif |
| pbipa | /home/tgenref/containers/grandcanyon/pacbio/pbipa_1.8.0--h6ead514_2.sif |
| pbjasmine | /home/tgenref/containers/grandcanyon/pacbio/pbjasmine_2.0.0--h9ee0642_0.sif |
| pbmarkdup | /home/tgenref/containers/grandcanyon/pacbio/pbmarkdup_1.0.3--h9ee0642_0.sif |
| pbmm2 | /home/tgenref/containers/grandcanyon/pacbio/pbmm2_1.12.0--h9ee0642_0.sif |
| pbpigeon | /home/tgenref/containers/grandcanyon/pacbio/pbpigeon_1.1.0--h4ac6f70_0.sif |
| pbsim2 | /home/tgenref/containers/grandcanyon/pacbio/pbsim2_2.0.1--h4ac6f70_3.sif |
| pbskera | /home/tgenref/containers/grandcanyon/pacbio/pbskera_1.1.0--hdfd78af_0.sif |
| pbsv | /home/tgenref/containers/grandcanyon/pacbio/pbsv_2.9.0--h9ee0642_0.sif |
| pbtk | /home/tgenref/containers/grandcanyon/pacbio/pbtk_3.1.0--h9ee0642_0.sif |
| pbwt | /home/tgenref/containers/grandcanyon/pacbio/pbwt_3.0--h6141fd1_9.sif |
|||
| __Oxford Nanopore Tools__ ||
| medaka | /home/tgenref/containers/grandcanyon/oxford_nanopore/medaka_1.8.0--py38hdaa7744_0.sif |
| dorado | /home/tgenref/containers/grandcanyon/oxford_nanopore/dorado_0.3.4.sif |
|||
| __Copy Number Tools__ ||
| hificnv | /home/tgenref/containers/grandcanyon/copy_number/hificnv_0.1.6b--h9ee0642_0.sif |
| RNA tools | _I'm sure there's more to add here @Elizabeth_ |
| flair | /home/tgenref/containers/grandcanyon/rna_tools/flair_2.0.0--pyhdfd78af_1.sif |
| isoseq3 | /home/tgenref/containers/grandcanyon/rna_tools/isoseq3_4.0.0--h9ee0642_0.sif |
|||
| __Structural Variant Callers__ ||
| cuteSV | /home/tgenref/containers/grandcanyon/structural_variant_calling/cutesv_2.0.3--pyhdfd78af_0.sif |
| dysgu | /home/tgenref/containers/grandcanyon/structural_variant_calling/dysgu_1.5.0--py310h770aed0_1.sif |
| sniffles | /home/tgenref/containers/grandcanyon/structural_variant_calling/sniffles_2.2--pyhdfd78af_0.sif |
|||
| __SNV Calling Tools__ ||
| deepvariant | /home/tgenref/containers/grandcanyon/variant_calling/deepvariant_1.5.0-gpu.sif |
