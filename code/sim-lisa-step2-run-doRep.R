# Project:   mi-spcr
# Objective: Run a single repetition in lisa
# Author:    Edoardo Costantini
# Created:   2022-07-29
# Modified:  2022-07-29

## Make sure we have a clean environment:
rm(list = ls(all = TRUE))

## Initialize the environment:
source("./init.R")

## Prepare storing results
source("./fs.R")

## Extract commandline arguments
args      <- commandArgs(trailingOnly = TRUE)
rp        <- as.numeric(args[1]) # replication rp = 1 to desired
fs$out_dir <- args[2]   # overwrite output directory defined

## Example Inputs Not to run
# rp        <- 1
# fs$out_dir <- "../output/trash/"

## Run one replication of the simulation:
runRep(rp = rp,
       cnds = cnds,
       parms = parms,
       fs = fs)
