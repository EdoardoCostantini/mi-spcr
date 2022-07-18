# Project:   mi-spcr
# Objective: runs all the repetitions of single condition
# Author:    Edoardo Costantini
# Created:   2022-07-18
# Modified:  2022-07-18

runCond <- function(cond_index, reps, cnds, parms, fs) {

    # Example Internals -------------------------------------------------------

    # cnd = cnds["201", ]
    # cond_index <- 2
    cnd <- cnds[cond_index, ]

    # Set seed
    .lec.SetPackageSeed(rep(parms$seed, 6))
    if (!cond_index %in% .lec.GetStreams()) { # if the streams do not exist yet
        .lec.CreateStream(c(1:parms$nStreams))
    } # then
    .lec.CurrentStream(cond_index) # this is equivalent to setting the seed Rle

    # Cycle thorugh conditions
    for (i in 1:reps) {
        # i <- 1
        cat(
          paste0(
            "Cond: ", cond_index,
            " / Rep: ", i,
            " / Time: ",
            Sys.time(),
            " / ", cnd$tag
          ),
          file = paste0(fs$out_dir, fs$file_name_prog, ".txt"),
          sep = "\n",
          append = TRUE
        )

        runCell(
            rp = i,
            cnd = cnd,
            fs = fs,
            parms = parms
        )
    }
}