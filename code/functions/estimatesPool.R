# Project:   mi-spcr
# Objective: Estimate and pool for object results
# Author:    Edoardo Costantini
# Created:   2022-07-11
# Modified:  2022-07-12

estimatesPool <- function(object, targets) {

    # Function parameters:
    # object = mids_out$mids # mids object
    # targets = parms$vmap$ta # vector of indices of the variables under analysis

    # Body

    # Pool means ---------------------------------------------------------------

    # Fit linear models
    fitX1 <- object %>% with(lm(X1 ~ 1))
    fitX2 <- object %>% with(lm(X2 ~ 1))
    fitX3 <- object %>% with(lm(X3 ~ 1))
    
    # Pool estimates
    pooled_means <- rbind(
        X1 = mice::pool(fitX1)$pooled,
        X2 = mice::pool(fitX2)$pooled,
        X3 = c(mice::pool(fitX3)$pooled)
    )

    # Confidence intervals
    pooled_means_CIs <- rbind(
        X1 = summary(pool(fitX1), conf.int = TRUE)[, c("2.5 %", "97.5 %")],
        X2 = summary(pool(fitX2), conf.int = TRUE)[, c("2.5 %", "97.5 %")],
        X3 = summary(pool(fitX3), conf.int = TRUE)[, c("2.5 %", "97.5 %")]
    )

    # Put together
    out_means <- cbind(
        stat = "mean",
        vars = rownames(pooled_means),
        pooled_means[, c("estimate", "fmi")],
        pooled_means_CIs
    )

    # Change names
    colnames(out_means) <- c("stat", "vars", "est", "fmi", "lwr", "upr")

    # Pool correlations --------------------------------------------------------

    cor_out <- miceadds::micombine.cor(object,
        variables = targets,
        conf.level = .95,
        method = "pearson",
        nested = FALSE,
        partial = NULL
    )

    # Identify unique correlations
    cor_unique_index <- !duplicated(t(apply(cor_out, 1, sort)))
    cor_unique <- cor_out[cor_unique_index, ]

    # Store name of parameter
    cor_unique <- cbind(
        stat = "cor",
        vars = paste0(
            cor_unique$variable1,
            cor_unique$variable2
        ),
        cor_unique
    )

    # Drop useless column
    cor_select <- cor_unique[, c("stat", "vars", "r", "fmi", "lower95", "upper95")]

    # Change names
    colnames(cor_select) <- c("stat", "vars", "est", "fmi", "lwr", "upr")

    # Pool variances(sd?) and covariances --------------------------------------

    cov_out <- miceadds::micombine.cov(object,
        variables = targets,
        conf.level = .95,
        nested = FALSE
    )

    # Identify unique correlations
    cov_unique_index <- !duplicated(t(apply(cov_out, 1, sort)))
    cov_unique <- cov_out[cov_unique_index, ]

    # Store name of parameter
    cov_unique <- cbind(
        stat = ifelse(cov_unique[, 1] == cov_unique[, 2], "var", "cov"),
        vars = ifelse(cov_unique[, 1] == cov_unique[, 2],
            cov_unique$variable1,
            paste0(
                cov_unique$variable1,
                cov_unique$variable2
            )
        ),
        cov_unique
    )

    # Drop useless column
    cov_select <- cov_unique[, c("stat", "vars", "cov", "fmi", "lower95", "upper95")]

    # Change names
    colnames(cov_select) <- c("stat", "vars", "est", "fmi", "lwr", "upr")

    # Sort covariances
    cov_select <- cov_select[order(cov_select$stat, decreasing = TRUE), ]

    # Put all together 
    out_pool <- rbind(out_means, cov_select, cor_select)
    rownames(out_pool) <- 1:nrow(out_pool)

    # Add confidence interval width --------------------------------------------

    out_pool$CIW <- apply(out_pool[, c("lwr", "upr")], 1, diff)

    # Return results -----------------------------------------------------------

    return(out_pool)
}
