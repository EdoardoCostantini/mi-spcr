# Project:   mi-spcr
# Objective: initialization script
# Author:    Edoardo Costantini
# Created:   2022-07-05
# Modified:  2022-07-05

# Packages ---------------------------------------------------------------------

  # Load packages from the project library
  library(mice, lib.loc = "./input/rlib/")

  # Load packages
  library(MASS)

# Check the working directory --------------------------------------------------

  if(!grepl("code", getwd())){
    setwd("./code")
  }

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

# Fixed Parameters -------------------------------------------------------------

  # Empty List
  parms <- list()

  # Data generation
  parms$N  <- 500       # sample size
  parms$L  <- 1 + 5       # number latent variables
  parms$J  <- 5 # number items per latent variable
  parms$P  <- parms$L * parms$J # number of items (100 target)
  parms$cor_high <- .7   # true latent cov for target variables
  parms$cov_low <- .1 # for junk auxiliary
  parms$item_mean <- 5 # true item mean
  parms$item_var <- (2.5)^2 # true item variance

  # Missingness
  parms$pm <- .3       # proportion of missings level

  # Map variables to their roles
  parms$vmap <- list(
    ta = 1:3, # target of missingness, imputation, and analysis
    mp = 4:5, # mar Predictors
    ax = 6:parms$P # Auxiliary variables
  )

# Experimental Conditions ------------------------------------------------------

