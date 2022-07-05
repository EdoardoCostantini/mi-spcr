#!/bin/bash
# Project:  mi-spcr
# Topic:    Bash script to compile any version of the paper
# Author:   Edoardo Costantini
# Created:  2022-07-05
# Modified: 2022-07-05
# Notes:    It allows to compile a track changes version of a manuscript

# What is the entry point (i.e., the main file)?
FILENAME=$1

# The `.git` references to compare (i.e., second is assumed to be more recent).
REF_ONE=$2
REF_TWO=$3

# Get the temporary directory location.
TMP_DIR=./tmp

# Define a name for the track changes tex file

# Extract file name without extension
TEXNAME=$(basename "$FILENAME" .tex)

# Paste info about comparison
TRACKNAME="$TEXNAME"_diff_"$REF_ONE"_"$REF_TWO".tex

# Create paths.
ref_one_dir=$TMP_DIR/$REF_ONE
ref_two_dir=$TMP_DIR/$REF_TWO

# Make temporary directories.
mkdir -p $ref_one_dir
mkdir -p $ref_two_dir

# Create `git` work trees with changes at respective commits.
git worktree add $ref_one_dir $REF_ONE
git worktree add $ref_two_dir $REF_TWO

# Create the difference `.tex` file.
latexdiff \
    --type=UNDERLINE \
    --append-textcmd="enquote" \
    --allow-spaces \
    --math-markup=3 \
    --flatten \
    $ref_one_dir/$FILENAME $ref_two_dir/$FILENAME > $ref_two_dir/$TRACKNAME

#    --exclude-safecmd="textcite,nocite,ref" \
#    --disable-citation-markup \

# First run of pdflatex
pdflatex -interaction=nonstopmode -shell-escape -output-directory=$ref_two_dir $ref_two_dir/$TRACKNAME

# Find all the newly created auxiliary files:
auxFiles=$(find $ref_two_dir/*.aux)

# Run bibtex on each auxiliary file:
for aux in $auxFiles; do bibtex $aux; done

# Second and third run of pdflatex
pdflatex -interaction=nonstopmode -shell-escape -output-directory=$ref_two_dir $ref_two_dir/$TRACKNAME
pdflatex -interaction=nonstopmode -shell-escape -output-directory=$ref_two_dir $ref_two_dir/$TRACKNAME

# Copy PDF to final destination
mv $ref_two_dir/*.pdf ./pdf/

# Remove the `git`` work trees.
git worktree remove $ref_one_dir
git worktree remove --force $ref_two_dir
