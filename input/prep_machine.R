# Project:   mi-spcr
# Objective: Install packages required for running simulation
# Author:    Edoardo Costantini
# Created:   2022-07-05
# Modified:  2022-07-05
# Notes:     Assuming working directory ./code/

# Load init script to list the names of the packages required
source("init.R")

# 1. Install all packages you can
# ...

# 2. Instal MICE development version
install.packages("/Users/Work/projects/R-packages/mice",
    repos = NULL,
    type = "source",
    lib = "./input/rlib/"
)