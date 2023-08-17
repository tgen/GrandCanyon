# pygmy-pipedragon
ONT cDNA processing jetstream workflow

![pygmy pipedragon](https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Kyonemichthys_rumengani.jpg/783px-Kyonemichthys_rumengani.jpg)

## Authors

* Elizabeth Hutchins (@e-hutchins | ehutchins@tgen.org)

## Programs Run

- [pychopper](https://github.com/nanoporetech/pychopper) : trims, orients, and rescues reads
- [minimap2](https://github.com/lh3/minimap2#install) : genome and transcriptome alignment
- also outputs read lengths for histogram
- [salmon](https://salmon.readthedocs.io/en/latest/salmon.html) : transcript quantification
- [featureCounts](https://subread.sourceforge.net/) : gene quantification
- [flair](https://github.com/BrooksLabUCSC/flair#condaenv) : isoform analysis and quantification (in development)
- [isoquant](https://github.com/ablab/IsoQuant) : transcript discovery and quantification (in development)

## Requirements

- [jetstream](https://github.com/tgen/jetstream)

## Inputs

- config.yaml
- ubams.tsv

### config file
The config file can be edited to match attributes for your existing dataset.

### tab-delimited fastq file
Can be generated as follows:

```
realpath ubams/*.bam > bams.txt
realpath ubams/*.bam | awk -F'/' '{print $4}' > samples.txt

paste samples.txt bams.txt > ubams.tsv
sed -i '1isample\tubam' ubams.tsv
```

## To Run
```
#0: initiate workflow
jetstream init jetstream-out
cd jetstream-out

#optional: render pipeline first to see all commands that will be run, can output to text file
jetstream render pygmy-pipedragon/main.jst -c file:yaml:config config.yaml -c file:tsv:ubams ubams.tsv > render.log

#1: build workflow
jetstream build pygmy-pipedragon/main.jst -c file:yaml:config config.yaml -c file:tsv:ubams ubams.tsv
