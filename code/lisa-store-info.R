# Project:   mi-spcr
# Objective: Store the session information
# Author:    Edoardo Costantini
# Created:   2022-07-29
# Modified:  2022-08-19

# Output Directory from Terminal inputs
args <- commandArgs(trailingOnly = TRUE)

# Initialize the environment:
source("0-init-objects.R")
source("0-init-software.R")

# Change location of files
fs$out_dir <- args[1]

# Create Empty storing object
out <- list(parms = parms,
            cnds = cnds,
            session_info = devtools::session_info())

# Save it in the root
saveRDS(out,
        paste0(fs$out_dir,
               fs$file_name_res, ".rds")
)
