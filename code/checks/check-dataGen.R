# Project:   mi-spcr
# Objective: Check behaviours of dataGen funcitons
# Author:    Edoardo Costantini
# Created:   2022-07-15
# Modified:  2022-07-15

# Average correlations

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
