# Project:   mi-spcr
# Objective: Estimate time per condition
# Author:    Edoardo Costantini
# Created:   2022-07-18
# Modified:  2022-07-18

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

    # condition indeces
    cindex <- 1 : nrow(cnds) # define repetitions
    cindex <- 1 : 20 # define repetitions

    # number of clusters for parallelization
    clusters <- 10

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
    file_name <- "../output/20220718-171027-trial.tar.gz"
    output <- readTarGz(file_name)

    # Collect main time results
    rds_main_names <- grep("main", output$file_names)
    rds_main <- do.call(rbind, output$out[rds_main_names])

    # Define a time-per-condition data.frame
    time_per_condition <- data.frame(
      tag = unique(rds_main$tag),
      time = unique(rds_main$time)
    )

    # Attach experimental factors as columns
    time_per_condition <- merge(output$sInfo$cnds, time_per_condition, by = "tag")

    # Sort information by method
    time_per_condition <- arrange(time_per_condition, method, nla)

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


