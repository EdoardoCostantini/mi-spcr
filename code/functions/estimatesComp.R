# Project:   mi-spcr
# Objective: Estimate and pool for no imputation results
# Author:    Edoardo Costantini
# Created:   2022-07-11
# Modified:  2022-07-12

estimatesComp <- function(dt, targets) {

    # Means, variances, and covariances ----------------------------------------

    # Estimate means, variances, and covariances in bulk
    fit <- sem(
        model = genLavaanMod(dt, targets = targets),
        data = dt
    )

    # Extract parameters
    est_sem <- parameterEstimates(fit)

    # Store name of parameter
    est_sem <- cbind(
        par = apply(est_sem, 1, function(i) {
            if (grepl("1", i[2])) {
                par_name <- i[1]
            } else {
                par_name <- paste0(i[c(1, 3)], collapse = "v")
            }
        }),
        est_sem
    )

    # Drop useless column
    est_sem <- est_sem[, c("par", "est", "ci.lower", "ci.upper")]

    # Change names
    colnames(est_sem) <- c("par", "est", "lwr", "upr")

    # Correlations -------------------------------------------------------------

    var_names <- colnames(dt[, targets])
    all_cors <- t(combn(var_names, 2))
    est_cor <- data.frame(matrix(NA, ncol = 4, nrow = nrow(all_cors)))
    for (r in 1:nrow(all_cors)) {
        y <- dt[, all_cors[r, 1]]
        x <- dt[, all_cors[r, 2]]
        cor_test <- cor.test(y, x)
        est_cor[r, 1] <- paste0(all_cors[r, 1], "r", all_cors[r, 2]) # id
        est_cor[r, -1] <- c(cor_test$estimate, cor_test$conf.int) # data
    }

    # Give proper names
    colnames(est_cor) <- c("par", "est", "lwr", "upr")

    # Join results
    est <- rbind(est_sem, est_cor)

    # Add empty row for fmi
    est$fmi <- NA

    # Position it right after est
    est <- est[, c(1:2, 5, 3:4)]

    # Add confidence interval width --------------------------------------------

    est$CIW <- apply(est[, c("lwr", "upr")], 1, diff)

    return(est)
}
