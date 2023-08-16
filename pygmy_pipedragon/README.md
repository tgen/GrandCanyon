# pygmy-pipedragon
ONT cDNA processing jetstream workflow

![pygmy pipedragon](https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Kyonemichthys_rumengani.jpg/783px-Kyonemichthys_rumengani.jpg)

## Authors

* Elizabeth Hutchins (@e-hutchins | ehutchins@tgen.org)

## Programs Run

- [pychopper](https://github.com/nanoporetech/pychopper) : trims, aligns, and rescues reads
- [minimap2](https://github.com/lh3/minimap2#install) : genome alignment
- featureCounts : gene quantification
- [flair](https://github.com/BrooksLabUCSC/flair#condaenv) : isoform analysis and quantification
- [isoquant](https://github.com/ablab/IsoQuant) : transcript discovery and quantification
- salmon : transcript quantification (in development)

## Requirements

- [jetstream](https://github.com/tgen/jetstream)

## Inputs

- config.yaml
- fastqs.tsv

### config file
The config file can be edited to match attributes for your existing dataset.

### tab-delimited fastq file
Can be generated as follows:

```
realpath fastqs/*R1*fastq.gz > fq1.txt
ls fastqs/*R1*fastq.gz | awk -F'/' '{print $NF}' | sed 's/_R1_001.fastq.gz//g' > samples.txt

paste samples.txt fq1.txt > fastqs.tsv
sed -i '1isample\tfq1' fastqs.tsv
```

## To Run
```
#0: initiate workflow
jetstream init jetstream-out
cd jetstream-out

#optional: render pipeline first to see all commands that will be run, can output to text file
jetstream render pygmy-pipedragon/main.jst -c file:yaml:config config.yaml -c file:tsv:fastqs fastqs.tsv > render.log

#1: build workflow
jetstream build pygmy-pipedragon/main.jst -c file:yaml:config config.yaml -c file:tsv:fastqs fastqs.tsv

#2: run workflow
#make sure you add the backend slurm option here in order to submit jobs to the dback cluster with slurm
nohup jetstream run pygmy-pipedragon/main.jst -c file:yaml:config config.yaml -c file:tsv:fastqs fastqs.tsv --backend slurm > jetstream.log&
```
