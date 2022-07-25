# Project:   mi-spcr
# Objective: Estimate time per condition
# Author:    Edoardo Costantini
# Created:   2022-07-18
# Modified:  2022-07-26

# Diagnostics run --------------------------------------------------------------

# - Environment ----------------------------------------------------------------

    # Make sure environment is clean
    rm(list = ls())

    # Check the working directory
    if (!grepl("code", getwd())) {
        setwd("./code")
        print("Working directory changed")
    }

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
    reps <- c(1) #1 : 5 # define repetitions

    # which conditions should be run?
    cindex <- 1 : nrow(cnds)
    cindex <- 1 : 5

    # number of clusters for parallelization
    clusters <- 5

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
    tar_name <- "../output/20220719-133959-trial.tar.gz" # 1e3 max nla = 100
    tar_name <- "../output/20220720-101833-trial.tar.gz" # 5e3 max nla = 50
    tar_name <- "../output/20220725-111938-trial.tar.gz" # 5e3 max nla = 50

    output <- readTarGz(tar_name)

    # Collect main time results
    rds_main_names <- grep("main", output$file_names)
    rds_main <- do.call(rbind, output$out[rds_main_names])

    # Define a time-per-condition data.frame
    time_per_condition <- rds_main[!duplicated(rds_main[, c("tag", "time")]), c("tag", "time")]

    # Attach experimental factors as columns
    time_per_condition <- merge(output$sInfo$cnds, time_per_condition, by = "tag")

    # Sort information by method
    time_per_condition <- arrange(time_per_condition, method, nla)
    # time_per_condition <- arrange(time_per_condition, desc(time))

    # Deliver information in minutes
    time_per_condition$time_minutes <- round(time_per_condition$time / 60, 3)

    # Define an expected time per condition for a given number of repetitions
    time_per_condition$full_cycle_m <- time_per_condition$time_minutes * 200

    # Express full cycle in hours
    time_per_condition$full_cycle_h <- round(time_per_condition$full_cycle_m/60, 1)

    # Collect mids results
    rds_mids_names <- grep("mids", output$file_names)
    rds_mids <- output$out[rds_mids_names]
    names(rds_mids) <- output$file_names[rds_mids_names]

    # Take a peek
    i <- 12
    plot(rds_mids[[i]], main = output$file_names[rds_mids_names][i])

    # Read error results
    rds_error_names <- grep("ERROR", output$file_names)
    if(length(rds_error_names) != 0){
        rds_error <- do.call(rbind, output$out[rds_error_names])
    } else {
        rds_error <- NULL
    }

# - Save processed results -----------------------------------------------------

    saveRDS(list(time = time_per_condition,
                 mids = rds_mids,
                 error = rds_error,
                 sInfo = output$sInfo),
            paste(tools::file_path_sans_ext(file_name, compression = TRUE),
                  "prep-diagnostics.rds", sep = "-"))

# LISA estimate ----------------------------------------------------------------
# Calculate expected CPU time

    # Time to run a single repetition of all conditions (on blade, in hours)
    time_to_run <- sum(time_per_condition$time_minutes, na.rm = TRUE)/60
    time_to_run <- 10

    # the goal number of repetitions
    goal_reps <- 500 # should match your total goal of repetitions

    # number of cores usable in each lisa node
    ncores    <- 15

    # how will the tasks be devided in arrayes
    # e.g.: I want to specify a sbatch array of 2 tasks (sbatch -a 1-2 job_script_array.sh)
    narray    <- ceiling(goal_reps/ncores)
    n_nodes   <- goal_reps/ncores # number of arrays

    # Define a conservative wall time (max is 90ish h? TODO: check max time)
    wall_time <- time_to_run * 2 # expected job time on lisa

    # Indicative SBU consumption
    n_nodes * ncores * time_to_run

    # Conservative SBU consumption
    n_nodes * ncores * wall_time # 10000 left on my account