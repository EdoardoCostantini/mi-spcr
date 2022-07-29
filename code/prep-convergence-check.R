# Project:   mi-spcr
# Objective: Run with many iterations to check convergence
# Author:    Edoardo Costantini
# Created:   2022-07-25
# Modified:  2022-07-29

# 1. Prepare run ---------------------------------------------------------------

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
    source("init-software.R")
    source("init-objects.R")

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
    cindex <- which(cnds$pm == .5 & cnds$mech == "MAR" & cnds$nla == 50)
    # TODO: replace with filter

    # number of clusters for parallelization
    clusters <- 5

    # Modify run parameters to check convergence
    parms$mice_iters <- 1e2
    parms$nStreams   <- max(cindex)

# 2. Perform run ---------------------------------------------------------------

# - Parallelization ------------------------------------------------------------

    # Open clusters
    clus <- makeCluster(clusters)

    # export scripts to be executed to worker nodes
    clusterEvalQ(cl = clus, expr = source("init-software.R"))

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
    out_support$cnds <- cnds[cindex, ]
    out_support$session_info <- devtools::session_info()
    out_support$run_time <- run_time
    saveRDS(out_support, paste0(fs$out_dir, "sInfo.rds"))

    # Zip result fodler
    writeTarGz(fs$file_name_res)

# 3. Evaluate run results ---------------------------------------------------------

    # Load Results
    tar_name <- "../output/20220726-094436-convergence-check.tar.gz"
    tar_name <- "../output/20220729-104900-convergence-check.tar.gz"
    output <- readTarGz(tar_name)

    # Define conditions
    cnds <- output$sInfo$cnds

    # Collect mids results
    rds_mids_names <- grep("mids", output$file_names)
    rds_mids <- output$out[rds_mids_names]
    names(rds_mids) <- output$file_names[rds_mids_names]

# - Trace plots ----------------------------------------------------------------

    # Define what combination of methods to check
    npcs <- 1
    method <- unique(cnds$method)[4]

    # Produce object to filter the results
    cnd_search <- paste0("npcs-", npcs, "-method-", method)
    cnd_id <- grep(cnd_search, names(rds_mids))

    # Plot
    plot(rds_mids[[cnd_id]],
         main = output$file_names[rds_mids_names][cnd_id],
         ylim = list(c(4, 6), c(1, 3)))

# - Density plots --------------------------------------------------------------

    # Define what combination of methods to check
    npcs <- 5
    method <- unique(cnds$method)[4]

    # Produce object to filter the results
    cnd_search <- paste0("npcs-", npcs, "-method-", method)
    cnd_id <- grep(cnd_search, names(rds_mids))

    # Density plots
    densityplot(rds_mids[[cnd_id]],
                ylim = c(0, .50),
                xlim = c(-5, 15),
                main = paste0(method, " ", npcs, ": ",
                              output$file_names[rds_mids_names][cnd_id]))