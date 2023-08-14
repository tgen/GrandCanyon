# GrandCanyon
Jetstream workflow to support the T2T Consortium CHM13 reference genome, through both long and short read sequencing data. This currently in very early 
development stages, and contributions are greatly appreciated.

## Hackathon specifics
On August 16th and 17th of 2023, a hackathon will be (or currently is being) held to rapidly integrate many of the core components of the pipeline. We 
plan to utilize all of the contributions during and after this hackathon to build a Jetstream based workflow, as Jetstream is already heavily integrated 
into the TGen compute infrastructure. But early development can be in any language the community sees fit. Most workflows will likely be a simple set of 
shell commands, but we are happy to accept and are expecting submissions in other languages such as python, R, nextflow, snakemake. Whichever language you 
are able to work in the most efficiently.

### Contribution Guidelines
This is intended to be mashed together very quickly, as such, please create a fork of the repository, or create a new branch off of `development`. 
Following this, please place your script in specific and likely uniquely
named directory. For example, if you plan to work on structural variant calling, this is my recommended start up template:
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

From here I would be ready to run `git add bturner_sv_caller_sniffles/sniffles.sh` and then `git commit -m "created a sniffles sv caller script on 
the first try"`, and finally `git push -u origin bturner-sv-calling`. Note that subsequent commits and pushes would only require `git push`, that 
initial push is publishing the branch and setting your local git to use the origin as the upstream.

It's also highly recommended for you to either ensure that comments are detailed enough that a Helios Scholar could pick up the script and use it 
effectively, or create a readme.md within your uniquely named directory.

### Resources
To save time both computationally and for development, we have precompiled a set of likely resources. But feel free to create your own and detail to 
us how you did it. We have placed these resources on both gemini and dback to make sure everyone has access to them and also to distribute some of the
compute load that will be happening over these few days.

Example data:  
/path/to/small/ont/data  
/path/to/small/pacbio/data  

CHM13 v2 resources:  
The marbl/CHM13 repo has most if not all resources that could be needed for utilizing CHM13 https://github.com/marbl/CHM13

__Paths to resources (on both dback and gemini)__  
Reference fasta: `/home/tgenref/homo_sapiens/t2t_chm13/chm13_v2/chm13v2.0_maskedY_rCRS.fa`  
Reference fasta index: `/home/tgenref/homo_sapiens/t2t_chm13/chm13_v2/chm13v2.0_maskedY_rCRS.fa.fai`  
Reference dictionary: `/home/tgenref/homo_sapiens/t2t_chm13/chm13_v2/chm13v2.0_maskedY_rCRS.dict`  

### Inspirations
Here is a list of potential inspirations on how to run specific workflows - in other words, PacBio and ONT have some recommended workflows that are written
in different formats. For example, PacBio has written a lot of workflows in wdl format and it looks like ONT has written workflows in Nextflow (Vince will 
be happy to see these)
 - https://github.com/PacificBiosciences
 - https://github.com/PacificBiosciences/wdl-humanwgs
 - https://github.com/nanoporetech
 - https://github.com/epi2me-labs
 - https://github.com/epi2me-labs/wf-human-variation
 - https://nf-co.re/nanoseq/3.1.0
 - https://github.com/nf-core/nanoseq


### Containers
As we are limited to singularity on both clusters, we have prepared a set of container images that we expected people will need. They have all been placed 
under `/home/tgenref/containers/grandcanyon/`. But if you can't find what you are looking for, it probably is available somewhere publically as a docker 
image. I'd recommend checking out hub.docker.com or there is a great set of tools available on quay.io (Bryce's "pro" tip, bioconda has a fantastic set of 
community built images and they have an easy to navigate index [here](https://bioconda.github.io/conda-package_index.html))

__Paths to containers (on both dback and gemini)__
- Common tools:
  - samtools
  - bcftools
  - gatk  
- Aligners:
  - minimap2
- Variant Callers:
  - sniffles
  - cutesv
  - dysgu
- Assemblers:
  - flye
  - shasta
  - verkko
- Oxford Nanopore Tools:
  - dorado
  - medaka
- PacBio Tools:
  - pbmm2
  - pbsv
  - trgt
  - slivar
- RNA Tools:
  - isoquant
  - pychopper
  - flair
