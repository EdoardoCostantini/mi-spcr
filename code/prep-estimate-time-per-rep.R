# Project:   mi-spcr
# Objective: Estimate time per repetition
# Author:    Edoardo Costantini
# Created:   2022-07-29
# Modified:  2022-08-01

# Run of single repeition (cycle through all conditions) -----------------------

  # Make sure environment is clean
  rm(list = ls())

  # Check the working directory
  if (!grepl("code", getwd())) {
    setwd("./code")
    print("Working directory changed")
  }

  # 1-word run description
  run_descr <- "check-time-per-rep"

  # Initialize the environment:
  source("init-software.R")
  source("init-objects.R")

  # Subset conditions?
  if( FALSE ){ cnds <- cnds[1:5, ] }

  # Create folders and report files
  dir.create(fs$out_dir)
  file.create(paste0(fs$out_dir, fs$file_name_prog, ".txt"))

  # Initialize report
  cat(paste0("SIMULATION PROGRESS REPORT",
             "\n",
             "Starts at: ", Sys.time(),
             "\n", "------", "\n" ),
      file = paste0(fs$out_dir, fs$file_name_prog, ".txt"),
      sep = "\n",
      append = TRUE)

  # Run one replication of the simulation:
  sim_start <- Sys.time()
  runRep(rp = 1,
         cnds = cnds,
         parms = parms,
         fs = fs)
  sim_ends <- Sys.time()
  time_to_run <- sim_ends - sim_start

  # Close report
  run_time <- difftime(sim_ends, sim_start, units = "hours")
  cat(paste0("\n", "------", "\n",
             "Ends at: ", Sys.time(), "\n",
             "Run time: ",
             round(run_time, 3), " h",
             "\n", "------", "\n"),
      file = paste0(fs$out_dir, fs$file_name_prog, ".txt"),
      sep = "\n",
      append = TRUE)

  # Store sessoin info
  out_support <- list()
  out_support$parms <- parms
  out_support$cnds <- cnds
  out_support$session_info <- devtools::session_info()
  out_support$run_time <- run_time
  saveRDS(
    out_support,
    paste0(fs$out_dir, "sInfo.rds")
  )

  # Zip result fodler
  writeTarGz(fs$file_name_res)

# LISA SBU estimate ------------------------------------------------------------

  # Load file
  out_t_per_rep <- readTarGz("../output/20220729-151828-check-time-per-rep.tar.gz")

  # Define a manual expected time to run
  time_to_run <- 20

  # Or extract time to run a single repetiton
  time_to_run <- as.numeric(out_t_per_rep$sInfo$run_time)

  # the goal number of repetitions
  goal_reps <- 250 # should match your total goal of repetitions

  # number of cores usable in each lisa node
  ncores    <- 15

  # how will the tasks be devided in arrayes
  # e.g.: I want to specify a sbatch array of 2 tasks (sbatch -a 1-2 job_script_array.sh)
  narray    <- ceiling(goal_reps/ncores)
  n_nodes   <- goal_reps/ncores # number of arrays

  # Define a conservative wall time (max is 90ish h?)
  wall_time <- time_to_run * 2 # expected job time on lisa

  # Indicative SBU consumption
  n_nodes * ncores * time_to_run

  # Conservative SBU consumption
  n_nodes * ncores * wall_time # 10000 left on my account