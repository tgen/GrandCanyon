#!/usr/bin/env Rscript --vanilla

suppressPackageStartupMessages(require(ggplot2))
suppressPackageStartupMessages(require(dplyr))
suppressPackageStartupMessages(require(tibble))
suppressPackageStartupMessages(require(readr))
suppressPackageStartupMessages(require(optparse))

option_list <- list(
  make_option(c("--quant-1"), type="character", default=NULL,
              help="path to RNA quantification file 1", metavar="character"),
  make_option(c("--assay-1"), type="character", default=NULL,
              help="assay code for RNA quantification file 1", metavar="character"),
  make_option(c("--quant-2"), type="character", default=NULL,
              help="path to RNA quantification file 2", metavar="character"),
  make_option(c("--assay-2"), type="character", default=NULL,
              help="assay code for RNA quantification file 2", metavar="character"),
  make_option(c("-c", "--cell-line"), type="character", default=NULL,
              help="name of the cell line being compared", metavar="character"),
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

required_options <- c("quant_1", "assay_1", "quant_2", "assay_2", "cell_line")
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
f2 <- opt$quant_2
assay2 <- opt$assay_2
cl <- opt$c

output_graph <- opt$output_graph
output_correlation <- opt$output_correlation


if (assay1 == "PKFLR") {
  Name_i <- "tname"
} else {
  Name_i <- "Name"
}

if (assay2 == "PKFLR") {
  Name_j <- "tname"
} else {
  Name_j <- "Name"
}


df1 <- read_tsv(f1, show_col_types = FALSE)
df2 <- read_tsv(f2, show_col_types = FALSE)

# filter out transcript names unique to either dataset
df1 <- df1[df1[[Name_i]] %in% df2[[Name_j]],]
df2 <- df2[df2[[Name_j]] %in% df1[[Name_i]],]

df1 <- df1[order(df1[[Name_i]]),]
df2 <- df2[order(df2[[Name_j]]),]

stopifnot(all.equal(df1[[Name_i]], df2[[Name_j]]))

r_1 <- tibble(Name = df1[[Name_i]])

if (assay1 == "PKFLR") {
  r_1$log2q <- log2(((df1$num_reads / sum(df1$num_reads)) * 1e6) + 1)
  xlabel <- paste(assay1, "log2 CPM")
} else {
  r_1$log2q <- log2(df1$TPM + 1)
  xlabel <- paste(assay1, "log2 TPM")
}

r_2 <- tibble(Name = df2[[Name_j]])

if (assay2 == "PKFLR") {
  r_2$log2q <- log2(((df2$num_reads / sum(df2$num_reads)) * 1e6) + 1)
  ylabel <- paste(assay2, "log2 CPM")
} else {
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
    name = "Log10 Read Count",
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
    values = c("LS Regression Line" = "red")
  ) +
  ggtitle(paste("RNA Expression Comparison of", assay1, "and", assay2, "for", cl))

ggsave(output_graph, g1, width = 10, height = 8)

tsv_out <- tibble(Assay1 = assay1, Assay2 = assay2, CellLine = cl, R2 = counts.r2, Pearson = counts.pearson, Spearman = counts.spearman)
write_tsv(tsv_out, output_correlation)

