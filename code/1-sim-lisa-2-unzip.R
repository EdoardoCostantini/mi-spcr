# Project:   mi-spcr
# Objective: put results together from tar archive obtained with lisa run
# Author:    Edoardo Costantini
# Created:   2022-07-29
# Modified:  2022-08-30

  rm(list = ls())
  source("0-init-software.R")

# Unzip results -----------------------------------------------------------

  # Job ID
  idJob <- "9945538-9944296-9943298"
  
  # Define location of results
  input_dir <- paste0("../output/", idJob, "/")
  tar_names <- grep(".tar.gz", list.files(input_dir), value = TRUE)

  # Define run name
  run_name <- grep(".rds", list.files(input_dir), value = TRUE)
  run_name <- tools::file_path_sans_ext(run_name, compression = TRUE)

  # Create empty dir to contain results
  res_dir   <- paste0(input_dir, "res/")
  system(command = paste0("mkdir -p ", res_dir))

  # Read results in loop
  print("Unzipping and loading in results")
  pb <- txtProgressBar(min = 0, max = length(tar_names), style = 3)

  for(i in 1:length(tar_names)){

    # Per every tar file do the following
    temp_dir  <- paste0(input_dir, "temp/")
    system(command = paste0("mkdir -p ", temp_dir))

    # Untar command definition
    untar_commands <- paste0("tar -C ",
                             temp_dir,   # where to place
                             " -xvf ", # untarring
                             input_dir,
                             tar_names[i])

    # Untar it
    system(command = untar_commands, ignore.stdout = TRUE, ignore.stderr = TRUE)

    # Obtain unique names of all result files
    fileNames <- grep(".rds", list.files(temp_dir), value = TRUE)

    # Read all
    output <- lapply(paste0(temp_dir, fileNames), readRDS)

    # Get the main results
    out_main_list <- output[grepl("main", fileNames)]
    out_main <- do.call(rbind, out_main_list)

    # Get mids results
    out_mids_list <- output[grepl("mids", fileNames)]
    names(out_mids_list) <- grep("mids", fileNames, value = TRUE)

    # Get the errors results
    errors <- grep("ERROR", fileNames)
    if(length(errors) > 0){
      out_errors <- output[errors] # check that these are all trivial
      out_errors <- do.call(rbind, out_errors)
    } else {
      out_errors <- NULL
    }

    # Store results -----------------------------------------------------------

    # Main
    saveRDS(out_main,
            paste0(res_dir,
                   gsub(".tar.gz", "_main.rds", tar_names[i])
            )
    )

    # Mids
    if(length(out_mids_list) > 0){
      saveRDS(out_mids_list,
              paste0(res_dir,
                     gsub(".tar.gz", "_mids.rds", tar_names[i])
              )
      )
    }

    # Errors
    saveRDS(out_errors, paste0(res_dir,
                             gsub(".tar.gz", "_ERROR.rds", tar_names[i])
    )
    )

    # Delete Temp Folder
    system(command = paste0("rm -rf ", temp_dir))

    # Delete large objects to save same memory
    rm(output)

    # Update progres bar
    setTxtProgressBar(pb, i)
  }

  close(pb)

# Combine results from the multiple tar.gz sources ------------------------

  # Read main results
  rds_main_names <- grep("main", list.files(res_dir), value = TRUE)
  rds_mains <- lapply(paste0(res_dir, rds_main_names), readRDS)
  rds_main <- do.call(rbind, rds_mains)

  # Read mids results
  rds_mids_names <- grep("mids", list.files(res_dir), value = TRUE)
  if(length(rds_mids_names) != 0){
  rds_mids <- lapply(paste0(res_dir, rds_mids_names), readRDS)
  } else {
    rds_mids <- NA
  }

  # Read error results
  rds_error_names <- grep("ERROR", list.files(res_dir), value = TRUE)
  rds_errors <- lapply(paste0(res_dir, rds_error_names), readRDS)
  rds_error <- do.call(rbind, rds_errors)

  # Read the session info object
  grep(".rds", list.files(input_dir), value = TRUE)
  sInfo <- readRDS(paste0(input_dir,
                          grep(".rds", list.files(input_dir), value = TRUE))
  )

  # Save output
  out <- list(
    main = rds_main,
               mids = rds_mids,
               error = rds_error,
    sInfo = sInfo
  )

  saveRDS(out,
          paste0("../output/", run_name, "-lisa-", idJob, "-unzipped.rds"))