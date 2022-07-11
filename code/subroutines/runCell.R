# Project:   mi-spcr
# Objective: runs a single repetiton of a single experimental cndition
# Author:    Edoardo Costantini
# Created:   2022-07-05
# Modified:  2022-07-12
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
        J = parms$J,
        P = cnd$nla * parms$J,
        rho_high = parms$cor_high,
        rho_junk = parms$cor_low,
        p_junk = .1
    )

    # Extract data
    X <- dataGen_out$X

    # Induce missingness ------------------------------------------------------

    # Active missing data mechanism
    mmw_active <- mmw[cnd$mech, ]

    # Variables involved in missing data amputation (VIMs)
    vim <- colnames(X) %in% names(mmw_active)
  
    # Amputation
    amp_out <- ampute(
      data = X[, vim],
      prop = cnd$pm,
      mech = as.character(cnd$mech),
      patterns = mm,
      weights = mmw_active
    )

    # Arrange missing data
    X_mis <- cbind(amp_out$amp, X[, !vim])

    # Apply methods -----------------------------------------------------------

    # If mi-pcr based method is required
    if(cnd$meth %in% method_pcr){

      # Define active PCR method
      mice.impute.active <- as.character(cnd$meth)

      # Impute
      mice_mids <- mice(X_mis,
        m = parms$mice_ndt,
        maxit = parms$mice_iters,
        method = mice.impute.active,
        npcs = cnd$npcs,
        # DoF = "naive",
        DoF = "kramer",
        # printFlag = FALSE,
        eps = 0
      )
    }

    # If reference mi method is required
    if (cnd$meth %in% method_rmi) {

      # Define predictor matrix (active set) depending on mi method
      if(cnd$meth %in% "qp"){
        pred_mat <- quickpred(X_mis)
      }
      if (cnd$meth %in% "am") {
        pred_mat <- matrix(0,
          ncol(X_mis), ncol(X_mis),
          dimnames = list(colnames(X_mis), colnames(X_mis))
        )
        pred_mat[parms$vmap$ta, parms$vmap$ta] <- 1
        diag(pred_mat) <- 0
      }
      if (cnd$meth %in% "all") {
        pred_mat <- matrix(1,
          ncol(X_mis), ncol(X_mis),
          dimnames = list(colnames(X_mis), colnames(X_mis))
        )
        diag(pred_mat) <- 0
      }

      # Impute
      mice_mids <- mice(X_mis,
        m = parms$mice_ndt,
        maxit = parms$mice_iters,
        method = "norm.boot",
        predictorMatrix = pred_mat,
        printFlag = FALSE,
        eps = 0,  # no lienar dependency checks
        ridge = 0 # no ridge regression applied
      )

    }

    # Evaluate imputations ----------------------------------------------------

    # For each condition, store the mice object of a subset of the repetitions
    # These can be used to perform the checks described by ObermanVink0000
    # Save it in a ./output/mids/ folder only for repetition 1, and then 
    # every 100 rps

    if (exists("mice_mids")) {
      if (rp == 1 || rp %% 100 == 0) {
        saveRDS(
          object = mice_mids,
          file = paste0(
            fs$mids_dir,
            "rp-", rp, "-",
            cnd$tag,
            "-mids",
            ".rds"
          )
        )
      }
    }

    # Analyze and pool --------------------------------------------------------

    if (exists("mice_mids")) {
      estimates_out <- estimatesPool(mids = mice_mids, targets = parms$vmap$ta)
    } else {
      estimates_out <- estimatesComp(dt = na.omit(X_mis), targets = parms$vmap$ta)
    }

    # Store Output ------------------------------------------------------------

    ### END TRYCATCH EXPRESSION
  }, error = function(e){
    err <- paste0("Original Error: ", e)
    err_res <- cbind(rp = rp, cnd, Error = err)
    saveRDS(err_res,
            file = paste0(fs$out_dir,
                          "rp-", rp, "-", cnd$tag,
                          "-ERROR",
                          ".rds")
    )
    return(NULL)
  }
  )

}

