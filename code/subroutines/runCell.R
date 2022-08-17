# Project:   mi-spcr
# Objective: runs a single repetiton of a single experimental cndition
# Author:    Edoardo Costantini
# Created:   2022-07-05
# Modified:  2022-08-17
# Note:      A "cell" is a given repetition for a given cndition.
#            This function:
#            - generates 1 data set,
#            - performs imputations,
#            - stores output.

runCell <- function(rp, cnd, fs, parms) {

  # Example Internals -------------------------------------------------------

  # cnd = cnds[1, ]
  # rp   = 1

  # Run internals in a tryCatch statement
  tryCatch({

    # Obtain truth ------------------------------------------------------------

    # Generate data
    dataGen_out <- dataGen(
        N = parms$N,
        L = cnd$nla,
        L_junk = cnd$nla - 2,
        J = parms$J,
        loading = parms$loading,
        mu = parms$item_mean,
        sd = sqrt(parms$item_var),
        rho_high = parms$cor_high,
        rho_junk = cnd$auxcor
    )

    # Extract data
    X <- dataGen_out$X

    # Induce missingness ------------------------------------------------------

    # Create copy of original data to impose missing values on
    X_mis <- X

    # Impose missing values on a per-variable basis
    for (i in seq_along(parms$vmap$ta)) {

      # Sample response vector

      if(cnd$mech == "MCAR"){
        nR <- rbinom(n = parms$N, size = 1, prob = cnd$pm) == 1
      }

      if(cnd$mech == "MAR"){
        nR <- simMissingness(pm   = cnd$pm,
                             data = X,
                             preds = parms$vmap$mp,
                             beta = rep(1, 3),
                             type = c("high", "low", "tails")[i])
      }

      # Fill in NAs

      X_mis[nR, i] <- NA

    }

    # Apply methods -----------------------------------------------------------

    # Impute pcr
    if(cnd$meth == "pcr"){

      mice_start <- Sys.time()

      mice_mids <- mice(X_mis,
                        m = parms$mice_ndt,
                        maxit = parms$mice_iters,
                        method = "pcr",
                        npcs = cnd$npcs,
                        printFlag = FALSE,
                        threshold = 1,
                        eps = 0,
                        ridge = 0
      )

      mice_ends <- Sys.time()

    }

    # Impute spcr
    if(cnd$meth == "spcr"){

      mice_start <- Sys.time()

      mice_mids <- mice(X_mis,
                        m = parms$mice_ndt,
                        maxit = parms$mice_iters,
                        method = "spcr",
                        theta = seq(0.05, .95, by = .05),
                        npcs = cnd$npcs,
                        nfolds = 10,
                        printFlag = FALSE,
                        threshold = 1,
                        eps = 0,
                        ridge = 0
      )

      mice_mids$loggedEvents

      mice_ends <- Sys.time()

    }

    # Impute pls
    if(cnd$meth == "pls"){

      mice_start <- Sys.time()

      mice_mids <- mice(X_mis,
                        m = parms$mice_ndt,
                        maxit = parms$mice_iters,
                        method = "pls",
                        nlvs = cnd$npcs,
                        DoF = "naive",
                        printFlag = FALSE,
                        threshold = 1,
                        eps = 0,
                        ridge = 0
      )

      mice_ends <- Sys.time()

    }

    # Impute pcovr
    if(cnd$meth == "pcovr"){

      mice_start <- Sys.time()

      mice_mids <- mice(X_mis,
                        m = parms$mice_ndt,
                        maxit = parms$mice_iters,
                        method = "pcovr",
                        npcs = cnd$npcs,
                        DoF = "naive",
                        printFlag = FALSE,
                        threshold = 1,
                        eps = 0,
                        ridge = 0
      )

      mice_ends <- Sys.time()

    }

    if(cnd$meth == "qp"){

      # Define predictor matrix with quickpred defaults
      pred_mat <- quickpred(X_mis)

      # Impute with deafult values for linear dependency checks
      mice_start <- Sys.time()
      mice_mids <- mice(X_mis,
                        m = parms$mice_ndt,
                        maxit = parms$mice_iters,
                        method = "norm.boot",
                        predictorMatrix = pred_mat,
                        printFlag = FALSE,
                        threshold = .999,
                        eps = 1e-04,
                        ridge = 1e-05
      )
      mice_ends <- Sys.time()

    }
    if (cnd$meth == "am") {

      # Define predictor matrix based only on variables we will use in analysis
      pred_mat <- matrix(0,
                         ncol(X_mis), ncol(X_mis),
                         dimnames = list(colnames(X_mis), colnames(X_mis))
      )
      pred_mat[parms$vmap$ta, parms$vmap$ta] <- 1
      diag(pred_mat) <- 0

      # Impute
      mice_start <- Sys.time()
      mice_mids <- mice(X_mis,
                        m = parms$mice_ndt,
                        maxit = parms$mice_iters,
                        method = "norm.boot",
                        predictorMatrix = pred_mat,
                        printFlag = FALSE,
                        # No safeties
                        threshold = 1,
                        eps = 0,
                        ridge = 0
      )
      mice_ends <- Sys.time()

    }

    if (cnd$meth == "all") {

      # Define predictor matrix containing all of the possible predictors
      pred_mat <- matrix(1,
                         ncol(X_mis), ncol(X_mis),
                         dimnames = list(colnames(X_mis), colnames(X_mis))
      )
      diag(pred_mat) <- 0

      # Impute
      mice_start <- Sys.time()
      mice_mids <- mice(X_mis,
                        m = parms$mice_ndt,
                        maxit = parms$mice_iters,
                        method = "norm.boot",
                        predictorMatrix = pred_mat,
                        printFlag = FALSE,
                        # No safeties
                        threshold = 1,
                        eps = 0,
                        ridge = 0
      )
      mice_ends <- Sys.time()

    }

    # Evaluate imputations ----------------------------------------------------

    # For each condition, store the mice object of a subset of the repetitions
    # These can be used to perform the checks described by ObermanVink0000
    # Save it in a ./output/mids/ folder only for repetition 1, and then 
    # every 100 rps

    if (exists("mice_mids")) {
      if (rp %in% c(1, 2)) {
        saveRDS(
          object = mice_mids,
          file = paste0(
            fs$out_dir,
            "rp-", rp, "-mids-",
            cnd$tag,
            ".rds"
          )
        )
      }
    }

    # Analyze and pool --------------------------------------------------------

    # If MI was used
    if (exists("mice_mids")) {
      estimates_out <- estimatesPool(
        object = mice_mids,
        targets = parms$vmap$ta
      )
    } else {
    # If MI was not used
      if(cnd$meth == "cc"){
        X_complete <- na.omit(X_mis)
      }
      if(cnd$meth == "fo"){
        X_complete <- X
      }
      estimates_out <- estimatesComp(
        object = X_complete,
        targets = parms$vmap$ta
      )
    }

    # Store Output ------------------------------------------------------------

    # Define imputation time (if imputation was done)
    imp_time <- ifelse(
      test = exists("mice_mids"),
      yes = as.numeric(difftime(mice_ends, mice_start, units = c("secs"))),
      no = NA
    )

    # Attach condition
    row.names(cnd) <- NULL # to avoid warning
    res <- cbind(
      rp = rp,
      cnd,
      run = fs$file_name_res,
      estimates_out,
      time = imp_time
    )

    # Return it
    return(res)

    ### END TRYCATCH EXPRESSION
  }, error = function(e){

    # Extract error
    err <- paste0("Original Error: ", e)

    # Attach it to a conditon
    err_res <- cbind(rp = rp, cnd, Error = err)

    # And store it
    saveRDS(err_res,
      file = paste0(
        fs$out_dir,
        "rp-", rp, "-ERROR-", cnd$tag,
        ".rds"
      )
    )

    # Return NA
    return(NA)

  }
  )
}

