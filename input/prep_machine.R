# Project:   mi-spcr
# Objective: Install packages required for running simulation
# Author:    Edoardo Costantini
# Created:   2022-07-05
# Modified:  2022-07-25

# Set up -----------------------------------------------------------------------

    # Check working direcotry
    if (!grepl("code", getwd())) {
        setwd("./code")
    }

    # Check if folder for local library exists, if not create it
    if (any(!grepl("rlib", list.files("../input/", recursive = FALSE)))) {
        dir.create("../input/rlib")
    }

# versions 0.3 -----------------------------------------------------------------

    install.packages("devtools")
    install.packages("versions")

# MASS 7.3-57 ------------------------------------------------------------------

    versions::install.versions(
        pkgs = "MASS",
        versions = "7.3-57",
        lib = "../input/rlib/"
    )

# lavaan 0.6-11 ----------------------------------------------------------------

    versions::install.versions(
        pkgs = "lavaan",
        versions = "0.6-12",
        lib = "../input/rlib/"
    )

# dplyr 1.0.8 ------------------------------------------------------------------

    versions::install.versions(
        pkgs = "dplyr",
        versions = "1.0.9",
        lib = "../input/rlib/"
    )

# mice 3.14.7.9000 (local experimental version)---------------------------------

    # First install mice and its dependencies
    install.packages("mice",
                     lib = "../input/rlib/")

    # Then install the developmental version of mice we need
    install.packages("../input/mice_3.14.7.9002.tar.gz",
                     repos = NULL,
                     type = "source",
                     lib = "../input/rlib/")

# rlecuyer 0.3-5 ---------------------------------------------------------------

    versions::install.versions(
        pkgs = "rlecuyer",
        versions = "0.3-5",
        lib = "../input/rlib/"
    )

# stringr 1.4.0 ----------------------------------------------------------------

    versions::install.versions(
        pkgs = "stringr",
        versions = "1.4.0",
        lib = "../input/rlib/"
    )

# miceadds 3.13-12 -------------------------------------------------------------

    versions::install.versions(
        pkgs = "miceadds",
        versions = "3.13-12",
        lib = "../input/rlib/"
    )