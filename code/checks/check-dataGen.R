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
    N = parms$N,
    L = cnd$nla,
    L_junk = cnd$nla - 3,
    J = parms$J,
    loading = parms$loading,
    mu = parms$item_mean,
    sd = sqrt(parms$item_var),
    rho_high = parms$cor_high,
    rho_junk = parms$cor_low
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