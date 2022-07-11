# Project:   mi-spcr
# Objective: Estimate and pool for mids results
# Author:    Edoardo Costantini
# Created:   2022-07-11
# Modified:  2022-07-11

estimatesPool <- function(mids, targets) {

    # Internals
    # mids = mids_out$mids
    # targets = parms$vmap$ta

    # Body

    # Pool means ---------------------------------------------------------------

    # Fit linear models
    fitX1 <- mids %>% with(lm(X1 ~ 1))
    fitX2 <- mids %>% with(lm(X2 ~ 1))
    fitX3 <- mids %>% with(lm(X3 ~ 1))
    
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
        par = rownames(pooled_means),
        pooled_means[, c("estimate", "fmi")],
        pooled_means_CIs
    )

    # Change names
    colnames(out_means) <- c("par", "est", "fmi", "lwr", "upr")

    # Pool correlations --------------------------------------------------------

    cor_out <- miceadds::micombine.cor(mids,
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
        par = paste0(
            cor_unique$variable1,
            "r",
            cor_unique$variable2
        ),
        cor_unique
    )

    # Drop useless column
    cor_select <- cor_unique[, c("par", "r", "fmi", "lower95", "upper95")]

    # Change names
    colnames(cor_select) <- c("par", "est", "fmi", "lwr", "upr")

    # Pool variances(sd?) and covariances --------------------------------------

    cov_out <- miceadds::micombine.cov(mids,
        variables = targets,
        conf.level = .95,
        nested = FALSE
    )

    # Identify unique correlations
    cov_unique_index <- !duplicated(t(apply(cov_out, 1, sort)))
    cov_unique <- cov_out[cov_unique_index, ]

    # Store name of parameter
    cov_unique <- cbind(
        par = paste0(
            cov_unique$variable1,
            "v",
            cov_unique$variable2
        ),
        cov_unique
    )

    # Drop useless column
    cov_select <- cov_unique[, c("par", "cov", "fmi", "lower95", "upper95")]

    # Change names
    colnames(cov_select) <- c("par", "est", "fmi", "lwr", "upr")

    # Put all together 

    out_pool <- rbind(out_means, cov_select, cor_select)
    rownames(out_pool) <- 1:nrow(out_pool)

    # Add confidence interval width --------------------------------------------

    out_pool$CIW <- apply(out_pool[, c("lwr", "upr")], 1, diff)

    # Return results -----------------------------------------------------------

    return(out_pool)
}
