# Project:   mi-spcr
# Objective: Initialization script for functions and packages
# Author:    Edoardo Costantini
# Created:   2022-07-26
# Modified:  2022-08-04

# Packages ---------------------------------------------------------------------

  # Define path to folder for project-specific R packages
  R_pack_lib <- list(pc = "../input/rlib/",
                     lisa = NULL)[[2]]

  # Load packages from the project library
  library(mice, lib.loc = R_pack_lib)
  # library(mice, lib.loc = paste0(.libPaths(), "-dev/"))
  library(miceadds, lib.loc = R_pack_lib)
  library(MASS, lib.loc = R_pack_lib)
  library(lavaan, lib.loc = R_pack_lib)
  library(dplyr, lib.loc = R_pack_lib)
  library(rlecuyer, lib.loc = R_pack_lib)
  library(stringr, lib.loc = R_pack_lib)

  # Load packages included in R installation
  library(parallel)

# Load Functions ---------------------------------------------------------------

  # Subroutines
  all_subs <- paste0(
    "./subroutines/",
    list.files("./subroutines/")
  )
  lapply(all_subs, source)

  # Functions
  all_funs <- paste0(
    "./functions/",
    list.files("./functions/")
  )
  lapply(all_funs, source)

  # Helper
  all_help <- paste0(
    "./helper/",
    list.files("./helper/")
  )
  lapply(all_help, source)
