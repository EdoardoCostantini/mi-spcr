# Project:   mi-spcr
# Objective: Check use of alpha in pcovr
# Author:    Edoardo Costantini
# Created:   2022-11-26
# Modified:  2022-11-26
# Notes: 

# All alphas

t(sapply(1:29, function(i) {
    vec <- 1:i
    vec <- c(vec[1] - 1, vec, vec[length(vec)] + 1)
    VAF <- c(0, cumsum(svd_erx$d^2) / sum(svd_erx$d^2))
    VAF <- VAF[vec + 1]
    scr <- array(NA, c(1, length(vec)))
    for (u in 2:(length(vec) - 1)) {
        scr[, u] <- (VAF[u] - VAF[u - 1]) / (VAF[u + 1] - VAF[u])
    }
    erx <- 1 - VAF[which.max(scr)]

    # Find alpha ML
    alpha <- sum(dotxobs^2) / (sum(dotxobs^2) + sum(dotyobs^2) * erx / ery)

    round(c(Rmax = i, maxsr = which.max(scr) - 1, erx = erx, alpha = alpha),3)
}))

# Different results by choices for a given number of npcs
results <- list()
npcs <- 9

# R: npcs
VAF <- cumsum(svd_erx$d^2) / sum(svd_erx$d^2)
erx <- 1 - VAF[npcs]
alpha <- sum(dotxobs^2) / (sum(dotxobs^2) + sum(dotyobs^2) * erx / ery)
results[[1]] <- round(c(Rmin = npcs, Rmax = npcs, Rchoice = npcs, erx = erx, alpha = alpha), 3)

# R: npcs (result as vector)
VAF <- cumsum(svd_erx$d^2) / sum(svd_erx$d^2)
erx <- 1 - VAF
alpha <- sum(dotxobs^2) / (sum(dotxobs^2) + sum(dotyobs^2) * erx / ery)
results[[1]] <- round(cbind(R = 1:length(VAF), erx = erx, alpha = alpha), 3)

# R: 1 to npcs
vec <- 1:npcs
vec <- c(vec[1] - 1, vec, vec[length(vec)] + 1)
VAF <- c(0, cumsum(svd_erx$d^2) / sum(svd_erx$d^2))
VAF <- VAF[vec + 1]
scr <- array(NA, c(1, length(vec)))
for (u in 2:(length(vec) - 1)) {
    scr[, u] <- (VAF[u] - VAF[u - 1]) / (VAF[u + 1] - VAF[u])
}
erx <- 1 - VAF[which.max(scr)]
alpha <- sum(dotxobs^2) / (sum(dotxobs^2) + sum(dotyobs^2) * erx / ery)
results[[2]] <- round(c(Rmin = 1, Rmax = npcs, Rchoice = which.max(scr) - 1, erx = erx, alpha = alpha), 3)

# R: 1 to max    
vec <- 1:ncol(dotxobs)
vec <- c(vec[1] - 1, vec, vec[length(vec)] + 1)
VAF <- c(0, cumsum(svd_erx$d^2) / sum(svd_erx$d^2))
VAF <- VAF[vec + 1]
scr <- array(NA, c(1, length(vec)))
for (u in 2:(length(vec) - 1)) {
    scr[, u] <- (VAF[u] - VAF[u - 1]) / (VAF[u + 1] - VAF[u])
}
erx <- 1 - VAF[which.max(scr)]
alpha <- sum(dotxobs^2) / (sum(dotxobs^2) + sum(dotyobs^2) * erx / ery)
results[[3]] <- round(c(Rmin = 1, Rmax = ncol(dotxobs), Rchoice = which.max(scr) - 1, erx = erx, alpha = alpha), 3)

names(results) <- c("R_npcs", "R_1_to_npcs", "R_1_to_ncol")

t(as.data.frame(results))

