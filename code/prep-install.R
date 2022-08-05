# Project:   mi-spcr
# Objective: Install packages required for running simulation
# Author:    Edoardo Costantini
# Created:   2022-07-05
# Modified:  2022-08-04

# Set up -----------------------------------------------------------------------

    # Check working direcotry
    if (!grepl("", getwd())) {
        setwd("")
    }

    # Check if folder for local library exists, if not create it
    if (any(!grepl("../input/rlib", list.files("../input/", recursive = FALSE)))) {
        dir.create("../input/rlib")
    }

    # Destination directory
    destDir <- c(pc = "../input/rlib/",
                 lisa = "~/R/x86_64-pc-linux-gnu-library/4.1")[2]

# devtools ---------------------------------------------------------------------

    # install.packages("devtools",
    #                  lib = destDir)

# versions 0.3 -----------------------------------------------------------------

    # install.packages("versions",
    #                  lib = destDir)

# PCovR 2.7.1 ------------------------------------------------------------------

    versions::install.versions(
      "PCovR",
      dependencies = TRUE,
      versions = "2.7.1",
      repo = "https://cloud.r-project.org/",
      lib = destDir
    )

# MLmetrics 7.3-57 -------------------------------------------------------------

    versions::install.versions(
      "MLmetrics",
      dependencies = TRUE,
      versions = "1.1.1",
      repo = "https://cloud.r-project.org/",
      lib = destDir
    )

# MASS 7.3-57 ------------------------------------------------------------------

    versions::install.versions(
        pkgs = "MASS",
        dependencies = TRUE,
        versions = "7.3-57",
        repo = "https://cloud.r-project.org/",
        lib = destDir
    )

# lavaan 0.6-11 ----------------------------------------------------------------

    versions::install.versions(
        pkgs = "lavaan",
        dependencies = TRUE,
        versions = "0.6-12",
        repo = "https://cloud.r-project.org/",
        lib = destDir
    )

# dplyr 1.0.8 ------------------------------------------------------------------

    versions::install.versions(
        pkgs = "dplyr",
        dependencies = TRUE,
        versions = "1.0.9",
        repo = "https://cloud.r-project.org/",
        lib = destDir
    )

# rlecuyer 0.3-5 ---------------------------------------------------------------

    versions::install.versions(
        pkgs = "rlecuyer",
        dependencies = TRUE,
        versions = "0.3-5",
        repo = "https://cloud.r-project.org/",
        lib = destDir,
        type = "source"
    )

# stringr 1.4.0 ----------------------------------------------------------------

    versions::install.versions(
        pkgs = "stringr",
        dependencies = TRUE,
        versions = "1.4.0",
        repo = "https://cloud.r-project.org/",
        lib = destDir
    )

# miceadds 3.13-12 -------------------------------------------------------------

    versions::install.versions(
        pkgs = "miceadds",
        dependencies = TRUE,
        versions = "3.13-12",
        repo = "https://cloud.r-project.org/",
        lib = destDir
    )

# mice 3.14.7.9*** (local experimental version)---------------------------------

    # First install mice and its dependencies
    install.packages("mice",
                     dependencies = TRUE,
                     repo = "https://cloud.r-project.org/",
                     lib = destDir)

    # Then install the developmental version of mice we need
    install.packages("../input/mice_3.14.7.9005.tar.gz",
                     repos = NULL,
                     type = "source",
                     lib = destDir)
