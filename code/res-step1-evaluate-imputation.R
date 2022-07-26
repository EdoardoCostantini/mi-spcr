# Project:   mi-spcr
# Objective: Script to evaluate imputations
# Author:    Edoardo Costantini
# Created:   2022-07-13
# Modified:  2022-07-26

# Prep environment -------------------------------------------------------------

  rm(list = ls()) # to clean up
  source("init-software.R")
  source("init-objects.R") # only for support functions

# Load Results -----------------------------------------------------------------

  loaction <- "../output/"
  run_name <- "20220719-142259-trial-pc-unzipped" # toy run on pc
  out <- readRDS(paste0(loaction, run_name, ".rds"))

# absence of non-convergence ---------------------------------------------------

  # Convergence plots for all conditions
  lapply(1:length(out$mids), function (i){
    plot(out$mids[[i]], main = names(out$mids)[i])
  })

# posterior predictive checks / fit of the imputation model --------------------

# distributional characteristics of the imputations ----------------------------

# imputation distribution vs observed data distribution ------------------------

  # Box and wisker plots
  lapply(1:length(out$mids), function (i){
    bwplot(
      out$mids[[i]],
      X1 + X2 + X3 ~ .imp,
      main = names(out$mids)[i]
    )
  })

  # Densities
  lapply(1:length(out$mids), function (i){
    densityplot(
      out$mids[[i]],
      main = names(out$mids)[i]
    )
  })
