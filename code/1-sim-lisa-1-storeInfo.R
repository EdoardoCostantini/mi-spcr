# Project:   mi-spcr
# Objective: Store the session information
# Author:    Edoardo Costantini
# Created:   2022-07-29
# Modified:  2022-08-18

# Output Directory from Terminal inputs
args <- commandArgs(trailingOnly = TRUE)

# Initialize the environment:
source("0-init-objects.R")
source("0-init-software.R")

# Change location of files
fs$out_dir <- args[1]

# Subset conditions?
subset_cond <- FALSE
if(subset_cond == TRUE){
  cnds <- cnds %>%
    filter(pm %in% c(.25),
           nla %in% c(2),
           npcs %in% c(0, 1),
           mech %in% "MAR",
           method %in% c("pcr", "spcr", "plsr", "pcovr", "fo"))
  parms$mice_iters <- 2
}

# Create Empty storing object
out <- list(parms = parms,
            cnds = cnds,
            session_info = devtools::session_info())

# Save it in the root
saveRDS(out,
        paste0(fs$out_dir,
               fs$file_name_res, ".rds")
)
