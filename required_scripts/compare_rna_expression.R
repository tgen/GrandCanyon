#!/usr/bin/env Rscript --vanilla

suppressPackageStartupMessages(require(ggplot2))
suppressPackageStartupMessages(require(dplyr))
suppressPackageStartupMessages(require(tibble))
suppressPackageStartupMessages(require(readr))
suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(tidyr))

option_list <- list(
  make_option(c("--quant-1"), type="character", default=NULL,
              help="path to RNA quantification file 1", metavar="character"),
  make_option(c("--quant-1-source"), type="character", default=NULL,
              help="source of RNA quantification file 1", metavar="character"),
  make_option(c("--assay-1"), type="character", default=NULL,
              help="assay code for RNA quantification file 1", metavar="character"),
  make_option(c("--quant-2"), type="character", default=NULL,
              help="path to RNA quantification file 2", metavar="character"),
  make_option(c("--quant-2-source"), type="character", default=NULL,
              help="source of RNA quantification file 2", metavar="character"),
  make_option(c("--assay-2"), type="character", default=NULL,
              help="assay code for RNA quantification file 2", metavar="character"),
  make_option(c("-s", "--sample-name"), type="character", default=NULL,
              help="name of the sample being compared", metavar="character"),
  make_option(c("-g", "--output-graph"), type="character", default="quant_graph.pdf",
              help="path to output graphical output", metavar="character"),
  make_option(c("-r", "--output-correlation"), type="character", default="cor.tsv",
              help="path to output correlation values in tsv format", metavar="character")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args2(opt_parser)
opt <- opt$options

####################################
## Validate Required Options are Provided
####################################

required_options <- c("quant_1", "assay_1", "quant_1_source", "quant_2", "quant_2_source", "assay_2", "sample_name")
missing_options <- required_options[!sapply(required_options, function(x) !is.null(opt[[x]]))]
if (length(missing_options) > 0) {
  print_help(opt_parser)
  stop(paste("Required options not provided:", paste(missing_options, collapse=", ")))
}

# Verify q1 and q2 exist
if (!file.exists(opt$quant_1)) {
  stop(paste("File provided to argument '--quant-1'", opt$quant_1, "does not exist"))
}

if (!file.exists(opt$quant_2)) {
  stop(paste("File provided to argument '--quant-2'", opt$quant_2, "does not exist"))
}


f1 <- opt$quant_1
assay1 <- opt$assay_1
quant_1_source <- opt$quant_1_source
f2 <- opt$quant_2
assay2 <- opt$assay_2
quant_2_source <- opt$quant_2_source
sample_name <- opt$s

output_graph <- opt$output_graph
output_correlation <- opt$output_correlation


if (quant_1_source == "oarfish") {
  Name_i <- "tname"
} else if (quant_1_source == "salmon") {
  Name_i <- "Name"
} else {
  stop(paste("Unsupported source for quantification file 1", quant_1_source))
}

if (quant_2_source == "oarfish") {
  Name_j <- "tname"
} else if (quant_2_source == "salmon") {
  Name_j <- "Name"
} else {
  stop(paste("Unsupported source for quantification file 2", quant_2_source))
}



df1 <- read_tsv(f1, show_col_types = FALSE)
df2 <- read_tsv(f2, show_col_types = FALSE)


all_names <- union(df1[[Name_i]], df2[[Name_j]])

if (quant_1_source == "oarfish") {
  df1 <- df1 %>%
    right_join(tibble(Name = all_names), by = setNames("Name", Name_i)) %>%
    mutate(num_reads = replace_na(num_reads, 0))
  names(df1)[names(df1) == "Name"] <- Name_i
} else if (quant_1_source == "salmon") {
  df1 <- df1 %>%
    right_join(tibble(Name = all_names), by = setNames("Name", Name_i)) %>%
    mutate(TPM = replace_na(TPM, 0))
}

if (quant_2_source == "oarfish") {
  df2 <- df2 %>%
    right_join(tibble(Name = all_names), by = setNames("Name", Name_j)) %>%
    mutate(num_reads = replace_na(num_reads, 0))
  names(df2)[names(df2) == "Name"] <- Name_j
} else if (quant_2_source == "salmon") {
  df2 <- df2 %>%
    right_join(tibble(Name = all_names), by = setNames("Name", Name_j)) %>%
    mutate(TPM = replace_na(TPM, 0))
}


df1 <- df1[order(df1[[Name_i]]),]
df2 <- df2[order(df2[[Name_j]]),]

stopifnot(all.equal(df1[[Name_i]], df2[[Name_j]]))

r_1 <- tibble(Name = df1[[Name_i]])

if (quant_1_source == "oarfish") {
  r_1$log2q <- log2(((df1$num_reads / sum(df1$num_reads)) * 1e6) + 1)
  xlabel <- paste(assay1, "log2 CPM")
} else if (quant_1_source == "salmon") {
  r_1$log2q <- log2(df1$TPM + 1)
  xlabel <- paste(assay1, "log2 TPM")
}

r_2 <- tibble(Name = df2[[Name_j]])

if (quant_2_source == "oarfish") {
  r_2$log2q <- log2(((df2$num_reads / sum(df2$num_reads)) * 1e6) + 1)
  ylabel <- paste(assay2, "log2 CPM")
} else if (quant_2_source == "salmon") {
  r_2$log2q <- log2(df2$TPM + 1)
  ylabel <- paste(assay2, "log2 TPM")
}

counts <- tibble(Assay1 = r_1$log2q, Assay2 = r_2$log2q)
counts.pearson <- cor(counts$Assay2, counts$Assay1, method = "pearson")
counts.spearman <- cor(counts$Assay2, counts$Assay1, method = "spearman")
counts.r2 <- counts.pearson ^ 2

g1 <- ggplot(data = counts, aes(x = Assay1, y = Assay2)) +
  geom_bin2d(bins=120) +
  geom_smooth(
    method = "lm",
    se = FALSE,
    formula = y ~ x,
    aes(color = "LS Regression Line")
  ) +
  xlab(xlabel) +
  ylab(ylabel) +
  scale_fill_gradientn(
    name = "Log10 Read Count\n",
    colors = c("darkblue", "lightblue", "green", "yellow", "red", "darkred"),
    breaks = 10 ^ (0:5),
    labels = scales::trans_format("log10", scales::math_format(10 ^ .x)),
    trans = "log"
  ) +
  scale_color_manual(
    name = paste(
      "Regression Line\nPearson R:",
      round(counts.pearson, digits = 2),
      "\nPearson R^2:",
      round(counts.r2, digits = 2),
      "\nSpearman rho:",
      round(counts.spearman, digits = 2)
    ),
    values = c("LS Regression Line" = "red"),
    guide = guide_legend(order = 98)
  ) +
  ggtitle(paste("RNA Expression Comparison of", assay1, "and", assay2, "for", sample_name)) +
  theme(
    axis.title = element_text(size = 20),
    axis.text = element_text(size = 20),
    plot.title = element_text(size = 20),
    legend.title = element_text(size = 18),
    legend.text = element_text(size = 18)
  ) 

ggsave(output_graph, g1, width = 11, height = 8)

tsv_out <- tibble(Source1 = quant_1_source, Assay1 = assay1, Source2 = quant_2_source, Assay2 = assay2, SampleName = sample_name, R2 = counts.r2, Pearson = counts.pearson, Spearman = counts.spearman)
write_tsv(tsv_out, output_correlation)

