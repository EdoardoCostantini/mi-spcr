#!/bin/bash
# Project:   mi-spcr
# Objective: Recipe for running simulation on lisa
# Author:    Edoardo Costantini
# Created:   2022-08-19
# Modified:  2022-08-27

# Parameters
# $1 : short / normal
# $2 : number of arrays

# Load year module
module load 2021

# Load R
module load R/4.1.0-foss-2021a

# Deploy stopos lines for parallelization
module load Stopos/0.93-GCC-10.3.0

# Move to code folder
cd mi-spcr/code/

# Define stopos lines
R --vanilla -e '

  # Define how many cores will be used on a node
  ncores    <- 16

  # Define repetitions
  first_rep <- 1
  last_rep <- 32

  # Define target number of repetitions
  goal_reps <- length(first_rep:last_rep)   # should match your total goal of repetitions
  narray    <- ceiling(goal_reps/ncores)  # the number to use in `sbatch -a 1-2 job_script_array.sh`

  # Save in input folder for Stopos
  write(x = as.character(first_rep:last_rep),
        file = "../input/stopos-lines")
'

# Deploy stopos lines
stopos create -p pool	                   # to create an empty pool of parameters
stopos -p pool add ../input/stopos-lines # to put the parameters as lines in the pool
stopos status		                         # print a description of the resulting pool

# Sbatch arrays
sbatch -a 1-$2 lisa-js-$1.sh