#!/bin/bash
# Project:   mi-spcr
# Objective: Create a run directory for Lisa
# Author:    Edoardo Costantini
# Created:   2022-08-04
# Modified:  2022-08-19

# Define a run name

  runName=$1

# Define a location for the lisa directory

  loc=./lisa/

# Create a directory with a desired name in the lisa folder

  mkdir $loc$runName

# Create an empty input folder

  mkdir $loc$runName/input/

# Copy current code folder

  cp -a code $loc$runName/

# Copy the stopos lines

  cp input/stopos-lines $loc$runName/input/

# Copy mice experimental version for installation

  cp ./input/mice\_3.14.7.9006.tar.gz $loc$runName/input/

# Create an empty output folder

  mkdir $loc$runName/output/