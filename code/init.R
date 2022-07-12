# Project:   mi-spcr
# Objective: initialization script
# Author:    Edoardo Costantini
# Created:   2022-07-05
# Modified:  2022-07-12

# Check the working directory --------------------------------------------------

  if(!grepl("code", getwd())){
    setwd("./code")
  }

  # Define path to folder for project-specific R packages
  R_pack_lib <- "../input/rlib/"

  # Create rlib if it doesn't exist
  if(!any(grepl(R_pack_lib, list.dirs("../")))){
    system(command = "mkdir ../input/rlib")
  }

# Packages ---------------------------------------------------------------------

  # Load packages from the project library
  library(mice, lib.loc = R_pack_lib)
  # library(mice, lib.loc = paste0(.libPaths(), "Dev/"))
  library(MASS, lib.loc = R_pack_lib)
  library(lavaan, lib.loc = R_pack_lib)
  library(dplyr, lib.loc = R_pack_lib)

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
  parms$N  <- 5e2  # sample size 
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

  # Missing data patterns
  mm <- data.frame(
    X1 = c(0, 1, 0, 0),
    X2 = c(0, 0, 1, 0),
    X3 = c(0, 0, 0, 1),
    X4 = c(1, 1, 1, 1),
    X5 = c(1, 1, 1, 1),
    X6 = c(1, 1, 1, 1)
  )

  # Missing data weights / mechanisms
  mmw <- t(data.frame(
    MCAR = c(X1 = 0, X2 = 0, X3 = 0, X4 = 0, X5 = 0, X6 = 0),
    MAR = c(0, 0, 0, 1, 1, 1),
    MNAR = c(1, 0, 0, 0, 0, 0)
  ))

  # Genearl imputation parameters
  parms$mice_ndt <- 5
  parms$mice_iters <- 20

# Experimental Conditions ------------------------------------------------------

  # Fully crossed factors
  pm    <- c(.1) #c(.1, .25, .5)
  mech  <- c("MCAR", "MAR") # c("MCAR", "MAR", "MNAR")
  loc <- "RIGHT" # c("TAIL", "MID", "RIGHT")
  nla   <- c(10, 50, 100)

  # Other factors
  method_pcr <- c("pcr", "spcr", "pls", "pcovr") # pca based methods
  method_rmi <- c("qp", "am", "all") # reference mi methods
  method_cc  <- c("cc") # complete case analysis

  # Combine factors part 1
  npcs <- c(1, 5:15, 45:55)
  npcs <- c(1:55)

  npcs_list <- lapply(nla, function(i) {
    (i - 2):(i + 2)
  })

  npcs <- unique(unlist(c(1, npcs_list)))

  cnds_pt1 <- expand.grid(
    npcs = npcs,
    method = method_pcr,
    nla = nla,
    pm = pm,
    mech = mech,
    loc = loc
  )

  # Combine factors part 2
  npcs <- 0
  cnds_pt2 <- expand.grid(
    npcs = npcs,
    method = c(method_rmi, method_cc),
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
  cnds$p <- (cnds$nla) * parms$J # total number of variables
  cnds <- cnds[cnds$npcs <= cnds$p, ]

  # Create a condition tag
  cnds_chrt <- sapply(cnds, as.character)
  cnds$tag <- paste0(colnames(cnds), "-", cnds_chrt[1, ], collapse = "-")
