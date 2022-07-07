# Project:   mi-spcr
# Objective: initialization script
# Author:    Edoardo Costantini
# Created:   2022-07-05
# Modified:  2022-07-07

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
  parms$N  <- 1e3  # sample size 
  parms$L  <- 2    # fixed number latent variables
  parms$J  <- 3    # number items per latent variable
  parms$cor_high <- .7   # true latent cov for target variables
  parms$cor_low <- .1 # for junk auxiliary
  parms$item_mean <- 5 # true item mean
  parms$item_var <- (2.5)^2 # true item variance

  # Missingness
  parms$pm <- .3       # proportion of missings level

  # Map variables to their roles
  parms$vmap <- list(
    ta = 1:parms$J, # target of missingness, imputation, and analysis
    mp = (1:parms$J) + parms$J # mar Predictors
  )

# Experimental Conditions ------------------------------------------------------

  # Fully crossed factors
  pm <- c(.1, .25, .5)
  mech <- c("MCAR", "MAR", "MNAR")
  loc <- c("LEFT", "MID", "RIGHT")
  nla <- c(1, 10, 100)

  # Other factors
  method <- c("pcr", "spcr", "pls", "pcovr") # pca based methods
  npcs <- c(1:15, 102)
  cnds_pt1 <- expand.grid(
    npcs = npcs,
    method = method,
    nla = nla,
    pm = pm,
    mech = mech,
    loc = loc
  )

  method <- c("qp", "am", "all", "cc")              # non-pca based methods
  npcs <- 0
  cnds_pt2 <- expand.grid(
    npcs = npcs,
    method = method,
    nla = nla,
    pm = pm,
    mech = mech,
    loc = loc
  )

  # Combine condition objects
  head(cnds_pt1)
  head(cnds_pt2)

  cnds <- rbind(cnds_pt1, cnds_pt2)
  
  # Get rid of impossible number of npcs for a given number of latent variables
  cnds$nlt <- (cnds$nla + 2) * parms$J
  cnds <- cnds[cnds$npcs <= cnds$nlt, ]