# Project:   mi-spcr
# Objective: Install packages required for running simulation
# Author:    Edoardo Costantini
# Created:   2022-07-05
# Modified:  2022-07-12

# Set up -----------------------------------------------------------------------

    # Check working direcotry
    if (!grepl("code", getwd())) {
        setwd("./code")
    }

# MASS 7.3-57 ------------------------------------------------------------------

    install.packages(
        pkgs = "https://cran.r-project.org/src/contrib/Archive/MASS/MASS_7.3-57.tar.gz",
        repos = NULL, 
        type = "source",
        lib = "../input/rlib/"
    )

# lavaan 0.6-11 ----------------------------------------------------------------

    install.packages(
        pkgs = "https://cran.r-project.org/src/contrib/Archive/lavaan/lavaan_0.6-11.tar.gz",
        repos = NULL,
        type = "source",
        lib = "../input/rlib/"
    )

# dplyr 1.0.8 ------------------------------------------------------------------

    install.packages(
        pkgs = "https://cran.r-project.org/src/contrib/Archive/dplyr/dplyr_1.0.8.tar.gz",
        repos = NULL,
        type = "source",
        lib = "./input/rlib/"
    )

# mice 3.14.7.9000 (local experimental version)---------------------------------

    install.packages("./input/mice_3.14.7.9000.tar.gz",
        repos = NULL,
        type = "source",
        lib = "./input/rlib/"
    )