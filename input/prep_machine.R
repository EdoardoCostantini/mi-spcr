# Project:   mi-spcr
# Objective: Install packages required for running simulation
# Author:    Edoardo Costantini
# Created:   2022-07-05
# Modified:  2022-07-12

# 1. Install all packages you need

    install.packages("MASS")
    install.packages("lavaan")
    install.packages("tidyverse")

# 2. Install MICE development version

    install.packages("./input/mice_3.14.7.9000.tar.gz",
        repos = NULL,
        type = "source",
        lib = "./input/rlib/"
    )