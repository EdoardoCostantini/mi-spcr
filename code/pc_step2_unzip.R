# Project:   mi-spcr
# Objective: put results together from tar archive obtained with pc run
# Author:    Edoardo Costantini
# Created:   2022-07-12
# Modified:  2022-07-12

# Prep environment --------------------------------------------------------

  rm(list = ls()) # to clean up
  source("./init.R") # only for support functions
  in_dir <- "../output/" # directory where results are stored
  target_tar <- "20220712-155155-trial.tar.gz"

# Load Results ------------------------------------------------------------

  output <- readTarGz(target_tar)

  # Collect main results
  rds_main_names <- grep("main", output$file_names)
  rds_main <- do.call(rbind, output$out[rds_main_names])

  # Read error results
  rds_error_names <- grep("ERROR", output$file_names)
  if(length(rds_error_names) != 0){
    rds_error <- do.call(rbind, output$out[rds_error_names])
  } else {
    rds_error <- NULL
  }

# Save output ------------------------------------------------------------

  saveRDS(list(main = rds_main,
               error = rds_error,
               sInfo = output$sInfo),
          paste(paste0(in_dir, tools::file_path_sans_ext(target_tar, compression = TRUE)),
                "pc",
                "unzipped.rds", sep = "-"))
