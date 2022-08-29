# Project:   mi-spcr
# Objective: Run the simulation study
# Author:    Edoardo Costantini
# Created:   2022-07-08
# Modified:  2022-08-29

# Environment ------------------------------------------------------------------

    # Make sure environment is clean
    rm(list = ls())

    # Check the working directory
    if (!grepl("code", getwd())) {
        setwd("./code")
        print("Working directory changed")
    }

    # 1-word run description
    run_descr <- "reduce-save"

    # Initialize the environment:
    source("0-init-software.R") # load packages
    source("0-init-objects.R")  # load objects

    # Create folders and report files
    dir.create(fs$out_dir)
    file.create(paste0(fs$out_dir, fs$file_name_prog, ".txt"))

    cat(paste0("SIMULATION PROGRESS REPORT",
            "\n",
            "Starts at: ", Sys.time(),
            "\n", "------", "\n" ),
        file = paste0(fs$out_dir, fs$file_name_prog, ".txt"),
        sep = "\n",
        append = TRUE)

# Run specifications -----------------------------------------------------------

    # number of repetitions
    reps <- (1:5) #1 : 5 # define repetitions

    # parms$mice_iters <- 5

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

# Parallelization --------------------------------------------------------------

    # number of clusters for parallelization
    clusters <- 5

    # Open clusters
    clus <- makeCluster(clusters)

    # export scripts to be executed to worker nodes
    clusterEvalQ(cl = clus, expr = source("0-init-software.R"))

# parallel apply ---------------------------------------------------------------

    sim_start <- Sys.time()

    # Run the computations in parallel on the 'clus' object:
    out <- parLapply(
        cl = clus,
        X = reps,
        fun = runRep,
        cnds = cnds,
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
    out_support$cnds <- cnds
    out_support$session_info <- devtools::session_info()
    out_support$run_time <- run_time
    saveRDS(
        out_support,
        paste0(fs$out_dir, "sInfo.rds")
    )

    # Zip result fodler
    writeTarGz(fs$file_name_res)