# Project:   mi-spcr
# Objective: subroutine runRep to run all conditions for a single repetition
# Author:    Edoardo Costantini
# Created:   2022-07-12
# Modified:  2022-07-12

runRep <- function(rp, cnds, parms, fs) {

    # Example Internals -------------------------------------------------------

    # rp = 1

    # Set seed
    .lec.SetPackageSeed(rep(parms$seed, 6))
    if (!rp %in% .lec.GetStreams()) { # if the streams do not exist yet
        .lec.CreateStream(c(1:parms$nStreams))
    } # then
    .lec.CurrentStream(rp) # this is equivalent to setting the seed Rle

    # Cycle thorugh conditions
    for (i in 1:nrow(cnds)) {
        # i <- 1
        print(paste0(
            "Rep: ", rp,
            " / Cond: ", i,
            " / Time: ",
            Sys.time()
        ))

        runCell(
            rp = rp,
            cnd = cnds[i, ],
            fs = fs,
            parms = parms
        )
    }
}
