# Project:   mi-spcr
# Objective: pre-process input data for actual use in shiny app
# Author:    Edoardo Costantini
# Created:   2022-12-16
# Modified:  2022-12-16
# Notes:     This script prepares the input data for the shiny app plotmispcr.

# Data to plot
dataResults <- readRDS("../output/20221202-105949-results.rds")
dataMids <- readRDS("../output/20220729-104900-convergence-check.rds")

# Make names of outcome variables prettier
names(dataResults)[names(dataResults) == "coverage"] <- "CIC"
names(dataResults)[names(dataResults) == "CIW_avg"] <- "CIW"

# Change pls to plsr in the condition tags
for(i in 1:length(names(dataMids$mids))){
    names(dataMids$mids)[i] <- gsub("pls", "plsr", names(dataMids$mids)[i])
}

# Manually compress the mids objects
for (i in 1:length(dataMids$mids)) {

    # Keep the only two objects you need for the trace plots
    dataMids$mids[[i]] <- list(
        chainMean = dataMids$mids[[i]]$chainMean,
        chainVar = dataMids$mids[[i]]$chainVar,
        m = dataMids$mids[[i]]$m,
        iteration = dataMids$mids[[i]]$iteration
    )

    # Get rid of non-imputed values
    dataMids$mids[[i]]$chainMean <- dataMids$mids[[i]]$chainMean[1:3, , ]
    dataMids$mids[[i]]$chainVar <- dataMids$mids[[i]]$chainVar[1:3, , ]

}

# Save the two objects as .rda ready for shiny app
save(dataMids, file = "../output/dataMids.rda")
save(dataResults, file = "../output/dataResults.rda")