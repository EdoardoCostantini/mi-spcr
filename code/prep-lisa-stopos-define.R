# Project:   mi-spcr
# Objective: Write stopos lines for lisa (execute beforehand on personal computer)
# Author:    Edoardo Costantini
# Created:   2022-07-29
# Modified:  2022-08-01

# Prepare Environment
rm(list = ls())

# Calculate
goal_reps <- 32 # should match your total goal of repetitions
ncores    <- 16  # I want to use this many cores in each node
narray    <- ceiling(goal_reps/ncores)  # I want to specify a sbatch array of 2 tasks (sbatch -a 1-2 job_script_array.sh)

# Save in input folder for Stopos
write(x = as.character(1:goal_reps),
      file = "../input/stopos-lines")