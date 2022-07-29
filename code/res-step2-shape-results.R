# Project:   mi-spcr
# Objective: combine and shape results from simulation study
# Author:    Edoardo Costantini
# Created:   2022-07-12
# Modified:  2022-07-29

# Prep environment -------------------------------------------------------------

  rm(list = ls()) # to clean up
  source("init-software.R")

# Load Results -----------------------------------------------------------------

  run_name <- "../output/20220719-133959-trial-pc-unzipped.rds" # toy run on pc
  out <- readRDS(run_name)

  sInfo <- out$sInfo
  res <- out$main

  # Define vector of epxerimental factor
  exp_fact <- colnames(out$sInfo$cnds)

  # Define component related to missing data treatments
  methods <- exp_fact[1:2]

  # Define component related to data generation
  data_gen <- exp_fact[3:8]

  # Define tag component
  tag <- exp_fact[9]

  # Define component related to the stored outcomes
  outcomes <- c("stat", "vars")

# Define "True" values ---------------------------------------------------------

  # Define what to group by
  group_by <- c(methods, data_gen, tag, outcomes)

  # Compute mean value for the "fo" method
  ref <- data.frame(
    res %>%
      group_by_at(group_by) %>%
      filter(method == "fo") %>%
      summarize(ref = mean(est))
  )

  # > Check --------------------------------------------------------------------

  # Define a reference value to check
  check_cond <- "npcs-0-method-fo-nla-2-auxcor-0.1-pm-0.1-mech-MAR-loc-rlt-p-6"
  check_stat <- "mean"
  check_vars <- "X1"

  # Extract computed statistic
  comp1 <- ref %>%
    filter(tag == check_cond, stat == check_stat, vars == check_vars) %>%
    select(ref)

  # Copmute the statistic manually
  comp2 <- colMeans(
    res %>%
      filter(tag == check_cond, stat == check_stat, vars == check_vars) %>%
      select(est)
  )

  # Are they the same?
  c(ref = comp1, res = comp2, diff = comp1 - comp2)

  # > Attach reference value based on matching conditions and parameter --------

  # Get rid of redundant columns form ref
  ref <- ref %>%
    select(-methods, -tag)

  # Attach reference value based on matching par to original dataset
  match_by <- c(data_gen, outcomes)

  # Merge data
  res_ref <- merge(x = res,
                   y = ref,
                   by = match_by)
  head(res_ref)

  # Sort in a more meaningful way
  res_ref <- arrange_(res_ref, .dots = c(data_gen, methods))

# Bias -------------------------------------------------------------------------

  # Compute mean and standard deviation of estimates
  bias_df <- data.frame(
    res_ref %>%
      group_by_at(group_by) %>%
      dplyr::summarize(est_avg = mean(est),
                       mcsd = sd(est))
  )

  # Merge data
  bias_df <- merge(x = bias_df, y = ref, by = match_by)

  # Compute bias
  bias_df$RB <- bias_df$est_avg - bias_df$ref
  bias_df$PRB <- 100 * abs(bias_df$RB) / bias_df$ref

  # Arrange meangingful
  bias_df <- arrange_(bias_df, .dots = c(data_gen, methods))
  arrange_(bias_df, .dots = data_gen)

  # > Check --------------------------------------------------------------------

  # Define a reference value to check
  check_cond <- "npcs-29-method-pcr-nla-10-auxcor-0.1-pm-0.25-mech-MAR-loc-rlt-p-30"
  check_stat <- "mean"
  check_vars <- "X2"

  # Extract computed statistic
  comp1 <- bias_df %>%
    filter(tag == check_cond, stat == check_stat, vars == check_vars) %>%
    select(RB)

  # Copmute the statistic manually
  comp2 <- diff(colMeans(
    res_ref %>%
      filter(tag == check_cond, stat == check_stat, vars == check_vars) %>%
      select(ref, est)
  ))

  # Are they the same?
  c(ref = comp1, res = comp2, diff = comp1 - comp2)

  # > coverage computation -----------------------------------------------------

  # Create logical vector saying whether the true value is in or out
  res_ref$cover_log <- res_ref$lwr < res_ref$ref & res_ref$ref < res_ref$upr

  # Compute the coverage probability
  CIC <- data.frame(res_ref %>%
                      group_by_at(group_by) %>%
                      dplyr::summarize(coverage = mean(cover_log, na.rm = TRUE)))

  # > Check --------------------------------------------------------------------

  # Define a reference value to check
  check_cond <- "npcs-29-method-pcr-nla-10-auxcor-0.1-pm-0.25-mech-MAR-loc-rlt-p-30"
  check_stat <- "var"
  check_vars <- "X1"

  # Extract computed statistic

  comp1 <- CIC %>%
    filter(tag == check_cond, stat == check_stat, vars == check_vars) %>%
    select(coverage)

  # Copmute the statistic manually
  comp2 <- colMeans(
    res_ref %>%
      filter(tag == check_cond, stat == check_stat, vars == check_vars) %>%
      select(cover_log)
  )

  # Are they the same?
  c(ref = comp1, res = comp2, diff = comp1 - comp2)

  # > confidence interval width ------------------------------------------------

  # Compute summarises for CIW
  CIW <- data.frame(res_ref %>%
                      group_by_at(group_by) %>%
                      dplyr::summarize(CIW_avg = mean(CIW),
                                       CIW_sd = sd(CIW),
                                       CIW_lwr_avg = mean(lwr),
                                       CIW_upr_avg = mean(upr)
                      ))

  # > Check --------------------------------------------------------------------

  # Define a reference value to check
  check_cond <- "npcs-29-method-pcr-nla-10-auxcor-0.1-pm-0.25-mech-MAR-loc-rlt-p-30"
  check_stat <- "mean"
  check_vars <- "X1"

  # # Extract computed statistic
  comp1 <- CIW %>%
    filter(tag == check_cond, stat == check_stat, vars == check_vars) %>%
    select(CIW_avg)

  # Copmute the statistic manually
  comp2 <- colMeans(
    res_ref %>%
      filter(tag == check_cond, stat == check_stat, vars == check_vars) %>%
      select(CIW)
  )

  # Are they the same?
  c(ref = comp1, res = comp2, diff = comp1 - comp2)

# Merge ------------------------------------------------------------------------

  # Merge bias and CIC
  bias_CIC <- merge(x = bias_df, y = CIC, by = c(tag, methods, data_gen, outcomes))

  # Merge with ICW
  gg_shape <- merge(x = bias_CIC, y = CIW, by = c(tag, methods, data_gen, outcomes))

# Store --------------------------------------------------------------------

  saveRDS(output,
          file = paste0("../output/",
                        gsub("unzipped",
                             "main-res",
                             run_name))
  )

