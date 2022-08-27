# Project:   mi-spcr
# Objective: Initialization script for functions and packages
# Author:    Edoardo Costantini
# Created:   2022-07-26
# Modified:  2022-08-26

# Packages ---------------------------------------------------------------------

  # Load packages from the project library
  library(mice)
  library(pls)
  library(miceadds)
  library(MASS)
  library(lavaan)
  library(dplyr)
  library(rlecuyer)
  library(stringr)
  library(parallel)
  library(flexiblas)

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
