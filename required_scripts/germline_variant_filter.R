#!/usr/bin/env Rscript --vanilla

library(dplyr)
library(stringi)

args = commandArgs(trailingOnly=TRUE)
locale <- list(locale = "en_US", numeric = TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).", call. = FALSE)
} else if (length(args)==1) {
  # default output file
  if (grepl('.tsv$', args[1])) {
    args[2] = sub('tsv', 'filtered.tsv', args[1])
  } else {
    stop("The input does not appear to be a tsv (file name extension != .tsv). A tsv input is required!", call. = FALSE)
  }
}

candidate_events <- read.table(args[1], header = TRUE, na.strings = c("."))

unphased_events <- candidate_events %>% filter(is.na(PS))
phased_events <- candidate_events %>% 
  filter(!is.na(PS)) %>% 
  mutate(n=n(), .by = Gene) %>% 
  filter(n>1) %>% 
  group_by(Gene) %>% 
  # We can use pick(everything()) with dplyr 1.1.0+, using across for compatibility
  mutate(num_gt = n_distinct(unlist(select(across(everything()), GT)))) %>% 
  ungroup() %>% 
  filter(num_gt>1) %>% 
  select(-n, -num_gt)

candidate_df <- bind_rows(phased_events, unphased_events) %>% 
  arrange(stri_rank(CHROM, opts_collator = locale), POS)

write.table(candidate_df, file = args[2], sep = "\t", quote = FALSE, row.names = FALSE, na = ".")

