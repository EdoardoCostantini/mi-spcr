# Project:   mi-spcr
# Objective: TODO
# Author:    Edoardo Costantini
# Created:   2022-08-03
# Modified:  2022-08-03

# Output Directory from Terminal inputs
args <- commandArgs(trailingOnly = TRUE)
out_dir <- args[1]

# Extract commandline arguments
args        <- commandArgs(trailingOnly = TRUE)
out_dir  <- args[1]   # overwrite output directory defined
rp          <- as.numeric(args[2]) # replication rp = 1 to desired

# Load some objects
source("init-objects.R")

# Create an empty object
res <- list(is = getwd(),
            out_dir = out_dir,
            fs = fs,
            rp = 3)

# write a file
saveRDS(res, file = paste0(out_dir, "rep", rp, ".rds"))

# # Output Directory from Terminal inputs
# args <- commandArgs(trailingOnly = TRUE)
# out_dir <- args[1]
#
# # write a file
# fileConn <- file(paste0(out_dir, "R-output.txt"))
# writeLines(c("Hello", "World"), fileConn)
# close(fileConn)
