# Project:   mi-spcr
# Objective: subroutine runRep to run all conditions for a single repetition
# Author:    Edoardo Costantini
# Created:   2022-07-12
# Modified:  2022-08-17

runRep <- function(rp, cnds, parms, fs) {

    # Example Internals -------------------------------------------------------

    # rp = 1

    # Set seed
    .lec.SetPackageSeed(rep(parms$seed, 6))
    if (!rp %in% .lec.GetStreams()) { # if the streams do not exist yet
        .lec.CreateStream(c(1:parms$nStreams))
    } # then
    .lec.CurrentStream(rp) # this is equivalent to setting the seed Rle

    # Define storing object
    target_rows <- 12   # number of elements to store per repetition
    target_cols <- 19   # number of columns to store per repetition
    ncnds <- nrow(cnds) # number of conditions per repetition
    target_cols_names <- c("rp", colnames(cnds), "run", "stat", "vars", "est", "fmi", "lwr", "upr", "CIW", "time") # TODO: define based on internal results of runCell()
    initial <- seq(1, target_rows * ncnds, by = target_rows)
    stop <- seq(0, target_rows * ncnds, by = target_rows)[-1]

    # Store results in a list
    store_res <- data.frame(matrix(NA,
                                   ncol = target_cols,
                                   nrow = target_rows * ncnds,
                                   dimnames = list(NULL, target_cols_names)))

    # Where are the factors?
    indx_col_cnds <- names(which(sapply(cnds, is.factor)))
    for(j in indx_col_cnds){
        store_res[, j] <- factor(store_res[, j], levels = levels(cnds[, j]))
    }

    # Cycle thorugh conditions
    for (i in 1:nrow(cnds)) {
        # i <- 1
        print(paste0(
            "Rep: ", rp,
            " / Cond: ", i,
            " / Time: ",
            Sys.time()
        ))

        store_res[initial[i]:stop[i], ] <- runCell(
            rp = rp,
            cnd = cnds[i, ],
            fs = fs,
            parms = parms
        )
    }

    # Save results of repetition
    saveRDS(store_res,
            file = paste0(
              fs$out_dir,
              "rp-", rp,
              "-main",
              ".rds"
            )
    )
}
