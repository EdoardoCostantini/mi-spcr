# Project:   mi-spcr
# Objective: runs a single repetiton of a single experimental condition
# Author:    Edoardo Costantini
# Created:   2022-07-05
# Modified:  2022-07-05
# Note:      A "cell" is a given repetition for a given condition.
#            This function: 
#            - generates 1 data set, 
#            - performs imputations,
#            - stores output.

runCell <- function(rp, cond, fs, parms) {

  # Example Internals -------------------------------------------------------

  # cond = conds[688, ]
  # rp   = 1

  # Run internals in a tryCatch statement
  tryCatch({

    # Data Generation ---------------------------------------------------------

    # Generate data
    dataGen_out <- dataGen(
        N = parms$N,
        L = parms$L,
        J = parms$J,
        P = parms$P,
        rho_high = parms$cor_high,
        rho_junk = parms$cor_low,
        p_junk = .1
    )

    # Impose Missingness
    preds <- dataGen_out$x[, parms$vmap$mp, drop = FALSE]
    targets <- dataGen_out$x[, parms$vmap$ta, drop = FALSE]

    # Imputation --------------------------------------------------------------

    # Analyze and pool --------------------------------------------------------

    # Store Output ------------------------------------------------------------

    ### END TRYCATCH EXPRESSION
  }, error = function(e){
    err <- paste0("Original Error: ", e)
    err_res <- cbind(rp = rp, cond, Error = err)
    saveRDS(err_res,
            file = paste0(fs$outDir,
                          "rep_", rp, "_", cond$tag,
                          "_ERROR",
                          ".rds")
    )
    return(NULL)
  }
  )

}

