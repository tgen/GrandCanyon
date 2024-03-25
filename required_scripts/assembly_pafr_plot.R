#!/usr/bin/env Rscript --vanilla

# Load required modules
library(ggplot2)
library(ggpubr)
library(pafr)
library(optparse)

# Define Options
option_list = list(
  make_option(c("-i", "--input"),
              type="character",
              default=NULL,
              help="input paf file",
              metavar="filename"),
  make_option(c("-t", "--target"),
              type="character",
              default='chr3',
              help="target contig")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

####################################
## Validate Required Options are Provided
####################################

if (is.null(opt$input)){
  print_help(opt_parser)
}

####################################
## Define Functions
####################################

process_paf <- function(input, target) {
  ali <- read_paf(input)

  # Graph
  ggplot(ali, aes(alen)) +
    geom_histogram(colour="black", fill="steelblue", bins=20) +
    theme_bw(base_size=16) +
    ggtitle("Distribution of alignment lengths") +
    scale_x_log10("Alignment-length")
  ggsave(paste(input, "pafr_alignment_length_hist.png", sep = "_"))

  ggplot(ali, aes(alen, de)) +
    geom_point(alpha=0.6, colour="steelblue", size=2) +
    scale_x_continuous("Alignment length (kb)", label =  function(x) x/ 1e3) +
    scale_y_continuous("Per base divergence") +
    theme_pubr()
  ggsave(paste(input, "pafr_alignment_divergence.png", sep = "_"))

  dotplot(ali, order_by="qstart") + theme_bw()
  ggsave(paste(input, "pafr_dotplot.png", sep = "_"))

  plot_coverage(ali)
  ggsave(paste(input, "pafr_coverage_target.png", sep = "_"))

  target_only <- ali[ali$tname == target,]
  dotplot(target_only, label_seqs=FALSE, dashes=FALSE, order_by="qstart") + theme_bw()
  ggsave(paste(input, target, "pafr_dotplot.png", sep = "_"))

  plot_coverage(target_only)
  ggsave(paste(input, target, "pafr_coverage_target.png", sep = "_"))
}

process_paf(opt$input, opt$target)

