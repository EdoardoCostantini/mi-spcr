# Project:   mi-spcr
# Objective: Run a single repetition in lisa
# Author:    Edoardo Costantini
# Created:   2022-07-29
# Modified:  2022-08-01

# Prepare Environment
rm(list = ls())

# Initialize the environment:
source("./init-objects.R")
source("./init-software.R")

# Subset conditions?
subset_cond <- TRUE
if(subset_cond == TRUE){
  cnds <- cnds %>%
    filter(pm %in% c(.25),
           nla %in% c(10),
           npcs %in% c(1, 2),
           mech %in% "MAR",
           method %in% c("pcr", "fo"))
}

# Extract commandline arguments
args      <- commandArgs(trailingOnly = TRUE)
rp        <- as.numeric(args[1]) # replication rp = 1 to desired
fs$out_dir <- args[2]   # overwrite output directory defined

# Example Inputs Not to run
# rp        <- 1
# fs$out_dir <- "../output/trash/"

# Run one replication of the simulation:
runRep(rp = rp,
       cnds = cnds,
       parms = parms,
       fs = fs)
