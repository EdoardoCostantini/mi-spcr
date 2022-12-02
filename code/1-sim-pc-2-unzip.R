# Project:   mi-spcr
# Objective: put results together from tar archive obtained with pc run
# Author:    Edoardo Costantini
# Created:   2022-07-12
# Modified:  2022-12-02

# Prep environment --------------------------------------------------------

  rm(list = ls()) # to clean up
  source("0-init-software.R")

# Load Results ------------------------------------------------------------

  tar_name <- "../output/20221126-121849-pcovr-correct-alpha-tuning.tar.gz"

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

  # Create object to store or move on
  out <- list(main = rds_main,
              mids = rds_mids,
              error = rds_error,
              sInfo = output$sInfo)

# Save output ------------------------------------------------------------

  saveRDS(out,
          paste(tools::file_path_sans_ext(tar_name, compression = TRUE),
                "pc",
                "unzipped.rds", sep = "-"))
