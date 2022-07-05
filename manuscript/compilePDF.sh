#!/bin/bash
# Project:  mi-spcr
# Topic:    Bash script to compile any version of the paper
# Author:   Edoardo Costantini
# Created:  2022-07-05
# Modified: 2022-07-05
# Notes:    It allows to compile all versions: draft and and journal submission.
#           To run it type "./compile_pdf.sh texFileName.ext" in a bash terminal
#           window.
#           Basic workflow from: http://linuxcommand.org/lc3_wss0010.phpc.w

# Store the time for easy clean up
timestamp=$(date +"%Y-%m-%d %H:%M:%S")
sleep 1 # make sure that files created differ by at least 1 sec form timestamp

R --vanilla -e '
  # Packages
  library(knitr)
  library(kableExtra)
  library(mice)
  library(mvtnorm)
  library(grDevices)   # for plotting gray.colors function
  library(ggplot2)     # results analysis
  library(ggpubr)      # for combining plots
  library(dplyr)       # for mutate

  # Source plotting functions
  source("./code/plot-functions.R")

  # Knit all .Rnw to .tex
  file_names <- list.files()
  file_Rnw <- grep(".Rnw", file_names)
  lapply(file_names[file_Rnw], knit)
'

# Store the time for easy clean up
timestamp=$(date +"%Y-%m-%d %H:%M:%S")
sleep 1 # make sure that files created differ by at least 1 sec form timestamp

# Deploy smart pdflatex
latexmk -pdf $1

# Move pdf file to correct location
mv *.pdf ./pdf/

# Remove anything else created after this script started
tput bold
printf "These files were created and deleted: \n"
tput sgr0
find . -maxdepth 1 -type f -newerBt "$timestamp" # show what you are deleting
find . -maxdepth 1 -type f -newerBt "$timestamp" -delete
# -newerBt checks files that were created after the timestamp (B for birth)
# -maxdepth 1 avoids scans of subfolders
