# Project:   mi-spcr
# Objective: put results together from tar archive obtained with pc run
# Author:    Edoardo Costantini
# Created:   2022-07-12
# Modified:  2022-07-13

# Prep environment --------------------------------------------------------

  rm(list = ls()) # to clean up
  source("./init.R") # only for support functions
  location <- "../output/" # directory where results are stored
  tar_name <- "20220713-163954-trial.tar.gz"

# Load Results ------------------------------------------------------------

  output <- readTarGz(tar_name)

  # Collect main results
  rds_main_names <- grep("main", output$file_names)
  rds_main <- do.call(rbind, output$out[rds_main_names])

  # Collect mids results
  rds_mids_names <- grep("mids", output$file_names)
  rds_mids <- output$out[rds_mids_names]
  names(rds_mids) <- output$file_names[rds_mids_names]

  # Read error results
  rds_error_names <- grep("ERROR", output$file_names)
  if(length(rds_error_names) != 0){
    rds_error <- do.call(rbind, output$out[rds_error_names])
  } else {
    rds_error <- NULL
  }

# Save output ------------------------------------------------------------

  saveRDS(list(main = rds_main,
               mids = rds_mids,
               error = rds_error,
               sInfo = output$sInfo),
          paste(paste0(location, tools::file_path_sans_ext(tar_name, compression = TRUE)),
                "pc",
                "unzipped.rds", sep = "-"))
