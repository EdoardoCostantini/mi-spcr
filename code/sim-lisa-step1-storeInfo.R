# Project:   mi-spcr
# Objective: Store the session information
# Author:    Edoardo Costantini
# Created:   2022-07-29
# Modified:  2022-07-29

## Prepare Environment
rm(list = ls())

## Initialize the environment:
source("./init.R")

## Prepare storing results
source("./fs.R")

# Output Directory from Terminal inputs
args <- commandArgs(trailingOnly = TRUE)
fs$out_dir <- args[1]

# Create Empty storing object
out <- list(parms = parms,
            cnds = cnds,
            session_info = devtools::session_info())

# Save it in the root
saveRDS(out,
        paste0(fs$out_dir,
               fs$fileName_res, ".rds")
)
