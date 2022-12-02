# Project:   mi-spcr
# Objective: File to patch together different results
# Author:    Edoardo Costantini
# Created:   2022-11-29
# Modified:  2022-12-02
# Notes:     Use to combine results in gg_shape format.

# Load results -----------------------------------------------------------------

# Load main results
main <- readRDS(
    "../output/20220827-094950-run-lisa-9945538-9944296-9943298-main-res.rds"
)

# Load results with fixed PCovR
pcovr_fix <- readRDS(
    "../output/20221126-121849-pcovr-correct-alpha-tuning-pc-main-res.rds"
)

# Patchwork --------------------------------------------------------------------

# Remove all pcovr from main
main <- main[main$method != "pcovr", ]

# Remove all other methods from pcovr main
pcovr_fix <- pcovr_fix[pcovr_fix$method == "pcovr", ]

# Append PCovR from new main
main <- rbind(main, pcovr_fix)

# Store final result -----------------------------------------------------------

saveRDS(
    main,
    file = paste0(
        "../output/",
        format(Sys.time(), "%Y%m%d-%H%M%S"),
        "-results.rds"
    )
)