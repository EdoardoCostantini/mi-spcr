# Project:   mi-spcr
# Objective: initialization script
# Author:    Edoardo Costantini
# Created:   2022-07-05
# Modified:  2022-07-26

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

# Fixed Parameters -------------------------------------------------------------

  # Empty List
  parms <- list()

  # Seed
  parms$seed     <- 20220712
  parms$nStreams <- 1000 # TODO: should this be as large as the number of parallel processes?

  # Data generation
  parms$N  <- 500  # sample size
  parms$L  <- 2    # fixed number latent variables
  parms$J  <- 3    # number items per latent variable
  parms$loading <- .85
  parms$cor_high <- .8   # true latent cov for target variables
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

  # General imputation parameters
  parms$mice_ndt <- 5
  parms$mice_iters <- 25

# Experimental Conditions ------------------------------------------------------

  # Fully crossed factors
  pm    <- c(.1, .25, .5)#[1:2] # TODO: Do we really need the .5?
  mech  <- c("MCAR", "MAR") # c("MCAR", "MAR", "MNAR")
  loc <- "rlt" # c("TAIL", "MID", "RIGHT")
  nla   <- c(2, 10, 50)#[1:2]
  auxcor <- c(.1, .5, parms$cor_high)[1]

  # Other factors
  method_pcr <- c("pcr", "spcr", "pls", "pcovr")#[1:2] # pca based methods
  method_rmi <- c("qp", "am", "all") # reference mi methods
  method_noi  <- c("cc", "fo") # complete case analysis and fully observed data analysis

  # Combine factors part 1
  npcs <- sort(unique(c(1:10, 11:12, seq(20, 40, 10), 48:52, 60, (nla*parms$J - 1))))

  cnds_pt1 <- expand.grid(
    npcs = npcs,
    method = method_pcr,
    nla = nla,
    auxcor = auxcor,
    pm = pm,
    mech = mech,
    loc = loc
  )

  # Combine factors part 2
  npcs <- 0
  cnds_pt2 <- expand.grid(
    npcs = npcs,
    method = c(method_rmi, method_noi),
    nla = nla,
    auxcor = auxcor,
    pm = pm,
    mech = mech,
    loc = loc
  )

  # Combine condition objects
  cnds <- rbind(cnds_pt1, cnds_pt2)
  
  # Get rid of impossible number of npcs for a given number of latent variables
  cnds$p <- (cnds$nla) * parms$J # total number of variables
  cnds <- cnds[cnds$npcs < (cnds$p), ]

  # Get rid of undesired granularity of npcs
  keep_rows <- !(cnds$npcs %in% c(11, 12, 20, 29) & cnds$nla == 50)
  cnds <- cnds[keep_rows, ]

  # Redefine rownames
  rownames(cnds) <- 1:nrow(cnds)

  # Create a condition tag
  cnds_chrt <- sapply(cnds, as.character)
  cnds$tag <- apply(cnds_chrt, 1, function(i){
    paste0(colnames(cnds), "-", i, collapse = "-")
  })

# File system ------------------------------------------------------------------

  # 1-word run description
  run_descr <- "trial"

  # Create object to store file system directives
  fs <- list()
  fs$start_time <- format(Sys.time(), "%Y%m%d-%H%M%S")

  # Create a run-sepecific output subfolder
  fs$out_dir <- paste0("../output/", fs$start_time, "-", run_descr, "/")

  # Define filenmaes for the results and progress report files
  fs$file_name_res <- paste0(fs$start_time, "-", run_descr)

  # Progress report file
  fs$file_name_prog <- paste0(fs$start_time, "-", run_descr)