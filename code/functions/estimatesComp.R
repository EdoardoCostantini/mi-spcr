# Project:   mi-spcr
# Objective: Estimate and pool for no imputation results
# Author:    Edoardo Costantini
# Created:   2022-07-11
# Modified:  2022-07-12

estimatesComp <- function(object, targets) {

    # Function parameters:
    # object = na.omit(X_mis) # compelte cases from data set
    # targets = parms$vmap$ta # vector of indices of the variables under analysis

    # Means, variances, and covariances ----------------------------------------

    # Estimate means, variances, and covariances in bulk
    fit <- sem(
        model = genLavaanMod(object, targets = targets),
        data = object
    )

    # Extract parameters
    est_sem <- parameterEstimates(fit)

    # Create vector of parameter type
    stat <- ifelse(est_sem$lhs == est_sem$rhs, "var", "cov")
    stat[est_sem$op == "~1"] <- "mean"

    # Store name of parameter
    est_sem <- cbind(
        vars = apply(est_sem, 1, function(i) {
            if (grepl("1", i[2])) {
                par_name <- i[1]
            } else {
                par_name <- paste0(i[c(1, 3)], collapse = "")
            }
        }),
        stat = stat,
        est_sem
    )

    # Drop useless column
    est_sem <- est_sem[, c("stat", "vars", "est", "ci.lower", "ci.upper")]

    # Change names
    colnames(est_sem) <- c("stat", "vars", "est", "lwr", "upr")

    # Correlations -------------------------------------------------------------

    var_names <- colnames(object[, targets])
    all_cors <- t(combn(var_names, 2))
    est_cor <- data.frame(matrix(NA, ncol = 5, nrow = nrow(all_cors)))
    est_cor[, 1] <- "cor"
    for (r in 1:nrow(all_cors)) {
        y <- object[, all_cors[r, 1]]
        x <- object[, all_cors[r, 2]]
        cor_test <- cor.test(y, x)
        est_cor[r, 2] <- paste0(all_cors[r, 1], all_cors[r, 2]) # id
        est_cor[r, 3:ncol(est_cor)] <- c(cor_test$estimate, cor_test$conf.int) # data
    }

    # Give proper names
    colnames(est_cor) <- c("stat", "vars", "est", "lwr", "upr")

    # Join results
    est <- rbind(est_sem, est_cor)

    # Add empty row for fmi
    est$fmi <- NA

    # Position it right after est
    est <- est[, c(1:3, 6, 4:5)]

    # Add confidence interval width --------------------------------------------

    est$CIW <- apply(est[, c("lwr", "upr")], 1, diff)

    return(est)
}
