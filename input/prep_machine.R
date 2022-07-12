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

# devtools 2.4.2 ---------------------------------------------------------------
    
    install.packages(
        pkgs = "https://cran.r-project.org/src/contrib/Archive/devtools/devtools_2.4.2.tar.gz",
        repos = NULL,
        type = "source",
        lib = "../input/rlib/"
    )

# MASS 7.3-57 ------------------------------------------------------------------

    devtools::install_version(
        package = "MASS",
        version = "7.3-57",
        type = "source",
        lib = "../input/rlib/"
    )

# lavaan 0.6-11 ----------------------------------------------------------------

    devtools::install_version(
        package = "lavaan",
        version = "0.6-12",
        type = "source",
        lib = "../input/rlib/"
    )

# dplyr 1.0.8 ------------------------------------------------------------------

    devtools::install_version(
        package = "dplyr",
        version = "1.0.9",
        type = "source",
        lib = "../input/rlib/"
    )

# mice 3.14.7.9000 (local experimental version)---------------------------------

    install.packages("./input/mice_3.14.7.9000.tar.gz",
        repos = NULL,
        type = "source",
        lib = "./input/rlib/"
    )

# rlecuyer 0.3-5 ---------------------------------------------------------------

    devtools::install_version(
        package = "rlecuyer",
        version = "0.3-5",
        type = "source",
        lib = "../input/rlib/"
    )

# stringr 1.4.0 ----------------------------------------------------------------

    devtools::install_version(
        package = "stringr",
        version = "1.4.0",
        type = "source",
        lib = "../input/rlib/"
    )
