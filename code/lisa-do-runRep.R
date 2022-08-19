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

# Change location of files
fs$out_dir <- args[1]
rp         <- as.numeric(args[2]) # replication rp = 1 to desired

# Subset conditions?
if(TRUE){
  cnds <- cnds %>%
    filter(pm %in% c(.25),
           nla %in% c(2),
           npcs %in% c(0, 1),
           mech %in% "MAR",
           method %in% c("am", "cc", "fo"))
  parms$mice_iters <- 2
}

# Example Inputs Not to run
# rp        <- 3
# fs$out_dir <- "../output/trash/"

# Run one replication of the simulation:
runRep(rp = rp,
       cnds = cnds,
       parms = parms,
       fs = fs)
