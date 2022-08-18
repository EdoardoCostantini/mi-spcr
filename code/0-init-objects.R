# Project:   mi-spcr
# Objective: initialization script
# Author:    Edoardo Costantini
# Created:   2022-07-05
# Modified:  2022-08-18

# File system ------------------------------------------------------------------

  # 1-word run description (only if not given by other run)
  if(!exists("run_descr")){
    run_descr <- "run"
  }

  # Define an object to store file system directives
  fs <- list()
  fs$start_time <- format(Sys.time(), "%Y%m%d-%H%M%S")

  # Define a run-sepecific output subfolder
  fs$out_dir <- paste0("../output/", fs$start_time, "-", run_descr, "/")

  # Define filenmaes for the results and progress report files
  fs$file_name_res <- paste0(fs$start_time, "-", run_descr)

  # Progress report file
  fs$file_name_prog <- paste0(fs$start_time, "-", run_descr)

# Fixed Parameters -------------------------------------------------------------

  # Empty List
  parms <- list()

  # Seed
  parms$seed     <- 20220805
  parms$nStreams <- 1000

  # Data generation
  parms$N         <- 1e3      # sample size
  parms$L         <- 2        # fixed number latent variables
  parms$J         <- 3        # number items per latent variable
  parms$loading   <- .85      # factor loadings
  parms$cor_high  <- .8       # true latent cor for target variables
  parms$item_mean <- 5        # true item mean
  parms$item_var  <- (2.5)^2  # true item variance

  # Map variables to their roles
  parms$vmap <- list(
    ta = 1:parms$J,            # target of missingness, imputation, and analysis
    mp = (1:parms$J) + parms$J # mar predictors
  )

  # General imputation parameters
  parms$mice_ndt <- 5
  parms$mice_iters <- 25

# Experimental Conditions ------------------------------------------------------

  # Fully crossed factors
  pm     <- c(.1, .25, .5)
  mech   <- c("MCAR", "MAR")
  loc    <- "rlt"
  nla    <- c(2, 10, 50)
  auxcor <- c(.1, .5, parms$cor_high)[1]

  # Other factors
  method_pcr <- c("pcr", "spcr", "plsr", "pcovr") # pca based methods
  method_rmi <- c("qp", "am", "all") # reference mi methods
  method_noi <- c("cc", "fo") # complete case analysis and fully observed data analysis
  npcs <- sort(
    unique(
      c(1:10, 11:12, seq(20, 40, 10),
        48:52,
        60, (nla*parms$J - 1)
      )
    )
  ) # number of principal components

  # Combine factors part 1
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
  cnds_pt2 <- expand.grid(
    npcs = 0,
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
  keep_rows <- !(cnds$npcs %in% c(11, 12, 29) & cnds$nla == 50)
  cnds <- cnds[keep_rows, ]

  # Redefine rownames
  rownames(cnds) <- 1:nrow(cnds)

  # Create a condition tag
  cnds_chrt <- sapply(cnds, as.character)
  cnds$tag <- apply(cnds_chrt, 1, function(i){
    paste0(colnames(cnds), "-", i, collapse = "-")
  })