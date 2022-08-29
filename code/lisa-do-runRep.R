# Project:   mi-spcr
# Objective: Run a single repetition in lisa
# Author:    Edoardo Costantini
# Created:   2022-07-29
# Modified:  2022-08-19

# Output Directory from Terminal inputs
args <- commandArgs(trailingOnly = TRUE)

# Initialize the environment:
source("0-init-objects.R")
source("0-init-software.R")

# Make sure that 1 r rpocess uses 1 thread
flexiblas::flexiblas_set_num_threads(1)

# Change location of files
fs$out_dir <- args[1]
rp         <- as.numeric(args[2]) # replication rp = 1 to desired

# Subset conditions?
if (FALSE) {
  cnds <- cnds %>%
    filter(
      pm %in% c(.25),
      nla %in% c(10),
      npcs %in% c(0, 1, 10),
      mech %in% "MAR",
      method %in% c("pcr", "am", "fo")
    )
}

# Example Inputs Not to run
# rp        <- 3
# fs$out_dir <- "../output/trash/"

# Run one replication of the simulation:
runRep(rp = rp,
       cnds = cnds,
       parms = parms,
       fs = fs)
