# Project:   mi-spcr
# Objective: Store the session information
# Author:    Edoardo Costantini
# Created:   2022-07-29
# Modified:  2022-08-03

# Prepare Environment
rm(list = ls())

# Initialize the environment:
source("./init-objects.R")
source("./init-software.R")

# Subset conditions?
# cnds <- cnds[1:2, ]
# subset_cond <- TRUE
# if(subset_cond == TRUE){
#   cnds <- cnds %>%
#     filter(pm %in% c(.25),
#            nla %in% c(10),
#            npcs %in% c(1, 2),
#            mech %in% "MAR",
#            method %in% c("pcr", "fo"))
# }

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
               fs$file_name_res, ".rds")
)
