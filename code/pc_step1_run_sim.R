# Project:   mi-spcr
# Objective: Run the simulation study
# Author:    Edoardo Costantini
# Created:   2022-07-08
# Modified:  2022-07-11

# Environment ------------------------------------------------------------------

    # Make sure environment is clean
    rm(list = ls())

    # Check the working directory
    if (!grepl("code", getwd())) {
        setwd("./code")
        print("Working directory changed")
    }

    # Initialize the environment:
    source("./init.R")

# Run specifications -----------------------------------------------------------

    # number of repetitions
    reps <- 1 : 5 # define repetitions

    # number of clusters for parallelization
    clusters <- 5 

    # Create object to store file system directives
    fs <- list()
    fs$start_time <- format(Sys.time(), "%Y%m%d_%H%M%S")

    # Create a run-sepecific output subfolder
    fs$out_dir <- paste0("../output/", fs$start_time, "/")
    dir.create(fs$out_dir)

    # Create a subfolder to store mids objects
    fs$mids_dir <- paste0(fs$out_dir, "mids", "/")
    dir.create(fs$mids_dir)

    # Define filenmaes for the results and progress report files
    fs$file_name_res <- fs$start_time

    # Progress report file
    fs$file_name_prog <- fs$start_time
    file.create(paste0(fs$out_dir, fs$file_name_prog, ".txt"))

    cat(paste0("SIMULATION PROGRESS REPORT",
            "\n",
            "Starts at: ", Sys.time(),
            "\n", "------", "\n" ),
        file = paste0(fs$out_dir, fs$file_name_prog, ".txt"),
        sep = "\n",
        append = TRUE)

# Parallelization --------------------------------------------------------------

    # Open clusters
    clus <- makeCluster(clusters)

    # export global env to worker nodes
    clusterExport(cl = clus, varlist = "fs", envir = .GlobalEnv)

    # export scripts to be executed to worker nodes
    clusterEvalQ(cl = clus, expr = source("./init.R"))

# mcApply parallel -------------------------------------------------------------

    sim_start <- Sys.time()

    # Run the computations in parallel on the 'clus' object:
    out <- parLapply(
        cl = clus,
        X = reps,
        fun = runRep,
        conds = conds,
        parms = parms,
        fs = fs
    )


    # Kill the cluster:
    stopCluster(clus)

    # Take note of time to run
    sim_ends <- Sys.time()
    run_time <- difftime(sim_ends, sim_start, units = "hours")
    cat(paste0("\n", "------", "\n",
            "Ends at: ", Sys.time(), "\n",
            "Run time: ",
            round(difftime(sim_ends, sim_start, units = "hours"), 3), " h",
            "\n", "------", "\n"),
        file = paste0(fs$out_dir, fs$file_name_prog, ".txt"),
        sep = "\n",
        append = TRUE)

# Post processing --------------------------------------------------------------

    # Store sessoin info
    out_support <- list()
    out_support$parms <- parms
    out_support$conds <- conds
    out_support$session_info <- devtools::session_info()
    out_support$run_time <- run_time
    saveRDS(
        out_support,
        paste0(fs$out_dir, "sInfo.rds")
    )

    # Zip result fodler
    writeTarGz(fs$file_name_res)