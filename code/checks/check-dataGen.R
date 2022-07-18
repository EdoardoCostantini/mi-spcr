# Project:   mi-spcr
# Objective: Check behaviours of dataGen funcitons
# Author:    Edoardo Costantini
# Created:   2022-07-15
# Modified:  2022-07-18

# Average correlation ----------------------------------------------------------

cor_YY <- NULL # correlation between items measuring the same latent variable
cor_YX <- NULL # correlation between items measuring the first and second latent variable

cor_store <- matrix(0, ncol = 6, nrow = 6)
reps <- 100

for (i in 1:reps){
  print(i)
  # Generate data
  dataGen_out <- dataGen(
    N = 500,
    L = 300,
    L_junk = 300-3,
    J = 3,
    loading = .85,
    mu = 5,
    sd = 2.5,
    rho_high = .9,
    rho_junk = .9
  )

  # Extract data
  cor_store <- cor_store + cor(dataGen_out$X[, 1:6])
}

round(cor_store / reps, 3)

# Imposing missing values in random position -----------------------------------
# Location of missing values should be a fixed factor because otherwise the effect
# disappears

store_loc_x1 <- NULL
reps <- 1e3
mu1 <- NULL

loc_cond <- c("high", "low", "tails", "random_hl", "random_hlt", "random_lt", "random_ht", "fixed_hlt")
store_mu <- store_cor <- matrix(NA, nrow = reps, ncol = length(loc_cond))
colnames(store_mu) <- loc_cond
colnames(store_cor) <- loc_cond
store_cor_true <- rep(NA, reps)

for (cnd in 1:length(loc_cond)){

  for (i in 1:reps){
    print(i)

    # Gen data
    dataGen_out <- dataGen(
      N = 500,
      L = 3,
      L_junk = 0,
      J = 3,
      loading = .85,
      mu = 5,
      sd = 2.5,
      rho_high = .9,
      rho_junk = .1
    )

    X_mis <- dataGen_out$X
    store_cor_true[i] <- cor(dataGen_out$X)[1, 2]

    for (j in seq_along(parms$vmap$ta)) {

      if(loc_cond[cnd] == "high"){
        loc <- "high"
      }
      if(loc_cond[cnd] == "low"){
        loc <- "low"
      }
      if(loc_cond[cnd] == "tails"){
        loc <- "tails"
      }
      if(loc_cond[cnd] == "random_hl"){
        loc <- sample(c("high", "low"), 1)
      }
      if(loc_cond[cnd] == "random_hlt"){
        loc <- sample(c("high", "low", "tails"), 1)
      }
      if(loc_cond[cnd] == "random_lt"){
        loc <- sample(c("low", "tails"), 1)
      }
      if(loc_cond[cnd] == "random_ht"){
        loc <- sample(c("high", "tails"), 1)
      }
      if(loc_cond[cnd] == "fixed_hlt"){
        loc <- c("high", "low", "tails")[j]
      }

      nR <- simMissingness(pm   = .3,
                           data = X_mis[, 4:6],
                           type = loc)

      # Fill in NAs
      X_mis[nR, j] <- NA
    }

    store_mu[i, cnd] <- mean(X_mis[, 1], na.rm = TRUE)
    store_cor[i, cnd] <- cor(X_mis[, 1], X_mis[, 2], use = "complete.obs")

  }

}

data.frame(
  mean = round(c(true = 5, colMeans(store_mu)), 3),
  cor = round(c(true = mean(store_cor_true), colMeans(store_cor)), 3)
)

# Creating a context where mi-qp will perform badly -----------------------------------
# Location of missing values should be a fixed factor because otherwise the effect
# disappears

reps <- 1e2
store_res <- list()

for (r in 1:reps){
  print(r)

  # Gen data
  dataGen_out <- dataGen(
    N = 500,
    L = 300,
    L_junk = 300-3,
    J = 3,
    loading = .85,
    mu = 5,
    sd = 2.5,
    rho_high = .9,
    rho_junk = .9
  )

  # Induce missingness ------------------------------------------------------

  # Create copy of original data to impose missing values on
  X_mis <- X

  # Impose missing values on a per-variable basis
  for (i in seq_along(parms$vmap$ta)) {

    # Sample response vector

    if(cnd$mech == "MCAR"){
      nR <- rbinom(n = parms$N, size = 1, prob = cnd$pm) == 1
    }

    if(cnd$mech == "MAR"){
      nR <- simMissingness(pm   = cnd$pm,
                           data = X,
                           preds = parms$vmap$mp,
                           beta = rep(1, 3),
                           type = c("high", "low", "tails")[i])
    }

    # Fill in NAs

    X_mis[nR, i] <- NA

  }

  # Define predictor matrix with quickpred defaults
  pred_mat <- quickpred(X_mis)

  # Impute with deafult values for linear dependency checks
  mice_start <- Sys.time()
  mice_mids <- mice(X_mis,
                    m = 5,
                    maxit = 20,
                    method = "norm.boot",
                    predictorMatrix = pred_mat,
                    # printFlag = FALSE,
                    threshold = .999,
                    eps = 1e-04,
                    ridge = 1e-05
  )
  mice_ends <- Sys.time()

  # Estimate something
  estimates_out <- estimatesPool(
    object = mice_mids,
    targets = parms$vmap$ta
  )

  store_res[[r]] <- estimates_out[, -(1:2)]

}

Reduce("+", store_res)/reps
