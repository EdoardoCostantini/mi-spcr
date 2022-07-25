# Project:   mi-spcr
# Objective: Run with many iterations to check convergence
# Author:    Edoardo Costantini
# Created:   2022-07-25
# Modified:  2022-07-25

# Prepare run ------------------------------------------------------------------

    # Make sure environment is clean
    rm(list = ls())

    # Check the working directory
    if (!grepl("code", getwd())) {
        setwd("./code")
        print("Working directory changed")
    }

    # 1-word run description
    run_descr <- "convergence-check"

# - Load default environment ---------------------------------------------------

    # Initialize the environment:
    source("./init.R")

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

# - Run specifications ---------------------------------------------------------

    # number of repetitions
    reps <- 1

    # which conditions should we check?
    cindex <- which(cnds$pm == .5 & cnds$mech == "MAR" & cnds$nl == 50)

    # number of clusters for parallelization
    clusters <- 15

    # Modify run parameters to check convergence
    parms$mice_iters <- 1e2

# - Parallelization ------------------------------------------------------------

    # Open clusters
    clus <- makeCluster(clusters)

    # export global env to worker nodes
    clusterExport(cl = clus, varlist = "fs", envir = .GlobalEnv)

    # export scripts to be executed to worker nodes
    clusterEvalQ(cl = clus, expr = source("./init.R"))

# - mcApply parallel -----------------------------------------------------------

    sim_start <- Sys.time()

    # Run the computations in parallel on the 'clus' object:
    out <- parLapply(
      cl = clus,
      X = cindex,
      fun = runCond,
      reps = 1,
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

# - Post processing ------------------------------------------------------------

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

# Read results ----------------------------------------------------------------

    # Load Results
    tar_name <- "../output/20220725-111938-trial.tar.gz" # 5e3 max nla = 50
    output <- readTarGz(tar_name)

    # Collect mids results
    rds_mids_names <- grep("mids", output$file_names)
    rds_mids <- output$out[rds_mids_names]
    names(rds_mids) <- output$file_names[rds_mids_names]

    # Take a peek
    i <- 12
    plot(rds_mids[[i]], main = output$file_names[rds_mids_names][i])
