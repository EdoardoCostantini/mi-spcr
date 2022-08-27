# Project:   mi-spcr
# Objective: Install packages required for running simulation
# Author:    Edoardo Costantini
# Created:   2022-07-05
# Modified:  2022-08-26

# devtools 2.4.4 ---------------------------------------------------------------

    install.packages(
      "devtools",
      dependencies = TRUE,
      repo = "https://cloud.r-project.org/"
    )

# flexiblas --------------------------------------------------------------------

    install.packages(
      "flexiblas",
      dependencies = TRUE,
      repo = "https://cloud.r-project.org/"
    )

# PCovR 2.7.1 ------------------------------------------------------------------

    install.packages(
      "PCovR",
      dependencies = TRUE,
      repo = "https://cloud.r-project.org/"
    )

# MLmetrics 7.3-57 -------------------------------------------------------------

    install.packages(
      "MLmetrics",
      dependencies = TRUE,
      repo = "https://cloud.r-project.org/"
    )

# MASS 7.3-57 ------------------------------------------------------------------

    install.packages(
      "MASS",
      dependencies = TRUE,
      repo = "https://cloud.r-project.org/"
    )

# lavaan 0.6-11 ----------------------------------------------------------------

    install.packages(
      "lavaan",
      dependencies = TRUE,
      repo = "https://cloud.r-project.org/"
    )

# dplyr 1.0.8 ------------------------------------------------------------------

    install.packages(
      "dplyr",
      dependencies = TRUE,
      repo = "https://cloud.r-project.org/"
    )

# rlecuyer 0.3-5 ---------------------------------------------------------------

    install.packages(
      "rlecuyer",
      dependencies = TRUE,
      repo = "https://cloud.r-project.org/"
    )

# stringr 1.4.0 ----------------------------------------------------------------

    install.packages(
      "stringr",
      dependencies = TRUE,
      repo = "https://cloud.r-project.org/"
    )

# miceadds 3.13-12 -------------------------------------------------------------

    install.packages(
      "miceadds",
      dependencies = TRUE,
      repo = "https://cloud.r-project.org/"
    )

# pls 2.8-1 --------------------------------------------------------------------

    install.packages(
      "pls",
      dependencies = TRUE,
      repo = "https://cloud.r-project.org/"
    )

# mice 3.14.7.9*** (local experimental version)---------------------------------

    install.packages(
      "../input/mice_3.14.7.9006.tar.gz",
      repos = NULL,
      type = "source"
    )
