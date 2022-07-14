# Project:   mi-spcr
# Objective: Function to generate data with a latent structure
# Author:    Edoardo Costantini
# Created:   2022-07-05
# Modified:  2022-07-14

dataGen <- function(N, L, L_junk, J, P, mu, sd, rho_high, rho_junk) {

    # Example inputs
    # N = 50
    # L = 10
    # L_junk = 7
    # J = 3
    # mu = 0
    # sd = 1
    # rho_high = .7
    # rho_junk = .1

    # Define other parameters of interest --------------------------------------

    P <- L * J

    # Latent Variables Covariance matrix ---------------------------------------

    # Base latent variables covariance matrix
    Phi <- toeplitz(c(1, rep(rho_high, L - 1)))

    # Distinguish between important variables and possible auxiliary
    if((L-L_junk+1) <= L){
     index_junk_aux <- (L-L_junk+1):L
    } else {
     index_junk_aux <- NULL
    }

    # Change rho values (if needed)
    Phi[index_junk_aux, ] <- rho_junk # junk

    # Fix diagonal
    diag(Phi) <- 1

    # Make symmetric
    Phi[upper.tri(Phi)] <- t(Phi)[upper.tri(Phi)]

    # Factor loadings ----------------------------------------------------------

    lambda <- rep(.85, P)

    # Observed Items Error Covariance matrix ----------------------------------
    # Note: here we create uncorrelated errors for the observed items

    Theta <- diag(P)
    for (i in 1:length(lambda)) {
        Theta[i, i] <- 1 - lambda[i]^2
    }

    # Items Factor Complexity = 1 (simple measurement structure) --------------
    # Reference: Bollen1989 p234

    Lambda <- matrix(nrow = P, ncol = L)
    start <- 1
    for (j in 1:L) {
        end <- (start + J) - 1
        vec <- rep(0, P)
        vec[start:end] <- lambda[start:end]
        Lambda[, j] <- vec
        start <- end + 1
    }

    # Sample Scores -----------------------------------------------------------

    scs_lv <- mvrnorm(N, rep(0, L), Phi)
    scs_delta <- mvrnorm(N, rep(0, P), Theta)

    # Compute Observed Scores -------------------------------------------------

    x <- matrix(nrow = N, ncol = P)
    for (i in 1:N) {
        x[i, ] <- t(0 + Lambda %*% scs_lv[i, ] + scs_delta[i, ])
    }

    # Give meaningful names ---------------------------------------------------

    colnames(x) <- paste0("X", 1:ncol(x))
    colnames(scs_lv) <- paste0("Z", 1:ncol(scs_lv))

    # Scale it correctly
    x_scaled <- apply(x, 2, function(j) j * sd)
    x_center <- x_scaled + mu
    x_cont <- data.frame(x_center)

    # Return ------------------------------------------------------------------
    return(
        list(
            X = data.frame(x_cont),
            Z = data.frame(scs_lv),
            index_junk_aux = index_junk_aux
        )
    )
}
