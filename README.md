# Multiple imputation with the use of supervised principal component regression as a univariate imputation method (MI-SPCR)

[![DOI](https://zenodo.org/badge/510762412.svg)](https://zenodo.org/badge/latestdoi/510762412)

## Summary of project

The goal of the study was to understand how different approaches to **supervised principal component analysis** (PCA) can help to specify the **imputation models** in a Multivariate Imputation by Chained Equation (MICE) procedure to handle missing values.
In particular, I wanted to compare the performance of four univariate imputation methods based on supervised principal component regression (PCR).
We refer to this use of supervised PCR as supervised MI-PCR.
The **purpose of this study** was to evaluate the statistical properties of MI-PCR in several settings that differed in the complexity of the data latent structure, the proportion of missing cases, the missing data mechanism, and the number of principal components PCs used by the imputation models.

### Simulation study procedure

We used a Monte Carlo simulation study.
The simulation study procedure involved four steps:

- **Data generation**: We generated 500 data sets from a confirmatory factor analysis model.
- **Missing data imposition**: We imposed missing values on three target items in each generated data set.
- **Imputation**: We generated $d$ multiple imputed data tables for each generated data set using each of the different imputation methods.
- **Analysis**: We estimated the mean, variance, covariance, and correlation of the three items with missing values on the $d$ differently imputed data tables, and we pooled the estimates according to Rubin's rules (1987, p. 76.)

We then assessed the **performance** of each imputation method by computing the following outcome measures:

- RB: raw estimation bias;
- PRB: percent relative estimation bias;
- CIC: confidence interval coverage of the true parameter value;
- CIW: average confidence interval width;
- mcsd: standard deviation of the estimate across the Monte Carlo simulations;

for the following statistics:

- cor: correlation between two items with missing values;
- cov: covariance between two items with missing values;
- mean: mean of an item with missing values;
- var: variance of an item with missing values.

### Simulation study fixed factors

These parameters were kept constant to generate the data:

- dataset sample size (1000);
- number of items per latent variable (3);
- mean and variance of observed items (mu = 5, sd = 2.5);
- factor loadings (0.85);
- correlation between the first two latent variables (0.8);
- correlation between the first two latent variables and the others (0.1);
- number of items receiving missing values (3);
- "shape" of missing values imposed on the three variables with missing values (right, left, tails, respectively).

These parameters were kept constant to impute the data:

- number of multiple imputations ($d = 5$)
- MICE algorithm iterations (25)

### Simulation study experimental factors

The simulation study procedure is repeated for each of the conditions resulting by the crossing of the following experimental factors:

- **number of latent variables** (nla = 2, 10, 50)

  From previous work, we know the unsupervised PCA methods require to use of enough PCs as there are latent variables in the data generating model. We want to vary the true number of latent variables to verify this.
  The chosen values reflect:
  - a simple case where we only have the two latent variables: 1 latent variable measured by items receiving amputation and imputation; 1 latent variable measured by the MAR predictors (nla = 2, for a total of 6 items)
  - a small dimensionality setup (nla = 10, for a total of 30 items)
  - a large dimensionality setup (nla = 50, for a total of 150 items)

- **proportion of missing data** per variable (pm = 0.1, 0.25, 0.5, levels chosen based on literature recommendations)
- **missing data mechanism** (mech = MCAR, MAR)

  These can be described by the following matrix describing which predictors are involved (no = 0, yes = 1) in the generation of the missing values on items X1 to X3:

  ```
        X1 X2 X3 X4 X5 X6
  MCAR  0  0  0  0  0  0
  MAR   0  0  0  1  1  1
  ```

- **missing data treatment**

  - **pcr**: mice with principal component regression as univariate imputation method;
  - **spcr**: mice with supervised principal component regression (Bair et. al., 2006) as univariate imputation method;
  - **plsr**: mice with partial least squares regression (Wold, 1975) as univariate imputation method;
  - **pcovr**: mice with principal covariates regression (De Jong and Kiers, 1992) as univariate imputation method;
  - **qp**: mice with the normal linear model with bootstrap as univariate imputation method and quickpred() used to select the predictors as described by Van Buuren, Boshuizen, and Knook (1999, pp. 687–688);
  - **am**: mice with the normal linear model with bootstrap as univariate imputation method and the analysis model variables used as predictors;
  - **all**: mice with the normal linear model with bootstrap as univariate imputation method and all available items used as predictors;
  - **cc**: complete case analysis;
  - **fo**: fully observed data (results if there had been no missing values).

- **number of principal components** (npcs) used by the approaches based on PCA

  These numbers depend of the number of latent variables used:
  - for nla = 2, I chose npcs = 1 to 5
  - for nla = 10, I chose npcs = 1 to 12, 20, 29
  - for nla = 50, I chose npcs = 1 to 10, 20, 30, 40, 48:52, 60, 149
  

### Results

Check out the results by playing with the [Shiny app](https://edoardocostantini.shinyapps.io/mi-pcr-plot/?_ga=2.193807589.95894774.1658930327-1213691852.1658930327).
## How to replicate results

To replicate the study, you first need to make sure you have installed all the packages used.
You can use the `./input/prep_machine.R` script to install them.
In the following guide, it is assumed that the machine on which the simulation is run already has all packages installed.

#### Before running the simulation study

To assess the lack of convergence issues, I recommend using the script `./code/prep-convergence-check.R` before running the simulation study.
This script runs the simulation study for the subset of most complex conditions and stores the mids objects so that trace-plots can be easily obtained.

To **perform the convergence checks**, perform the following steps:

1. Run the first and second sections of the `./code/prep-convergence-check.R`
2. Once the results have been stored, run the third section to read the results and manually check the combinations of `npcs` and `methods` that you desire to check. You can do so by changing the values of the `npcs` and `method` object defined in this script.
3. Update the `parms$mice_iters` value in `init.R` file to match the number of iterations that your think is sufficient to avoid non-convergence with all methods. 

Please note the following:

- The object `cindex` in the script can be used to specify the desired subset of conditions to check convergence. It is acceptable to check convergence for the more challenging conditions and draw conclusions for the entire simulation study.
- The number of iterations is set to 100, so that a possible lack of convergence for every multiple imputation method can be assessed.
- The run is parallelized over the conditions.
- The seed is set per condition.
- Every condition is meant to be repeated only once.

#### After running the simulation study

The simulation study stores mids objects for a small number of repetitions. 
You may assess the lack of non-convergence directly on these.
You may unzip the results form the simulation study, select the files that contain mids in their name and check convergence as in the third section of `./code/prep-convergence-check.R`.

### Running the simulation study on Lisa

Lisa Cluster is a cluster computer system managed by SURFsara, a cooperative association of Dutch educational and research institutions.
Researchers at most Dutch universities can request access to this cluster computer.
Here it is assumed that you know how to access Lisa and upload material to the server.
In the following, I list the specific tasks you should go through to replicate the results.
Bullet points starting with "PC" and "Lisa" indicate that the task should be performed in a terminal session on either your personal computer or on Lisa, respectively.
The idea is that you want (1) to prepare the simulation scripts on your computer, (2) upload the results to lisa and (3) run the simulation on Lisa.

1. **Prepare run** *on a personal computer*:
   - PC: Open `0-init-objects.R`:
      - check/define the seed in `parms$seed`
      - check the fixed parameters and experimental factor levels are set to the desired values.
      - set `run_descr` to a meaningful description
   - PC: Open `0-prep-estimate-time-per-rep.R`:
     - Run it to check how long it takes to perform a single run across all the conditions with the chosen simulation study setup.
       This will create an R object called `wall_time`.
   - PC: Open `lisa-js-normal.sh`:
     - replace the wall time in the header (`#SBATCH -t`) with the value of `wall_time`.
   - PC: Open `1-sim-lisa-run.R`: 
     - Under the header `Define stopos lines`, define the number of cores to use per node, and the first and last repetitions.
        For example:
        ```

        # Define how many cores will be used on a node
        ncores    <- 16

        # Define repetitions
        first_rep <- 49
        last_rep <- 256

        ```
        This will run the repetitions from 49 to 256 (usually you would start from 1, but you don't need to) and it will use 16 cores on every node.

   - PC: Open `lisa-do-runRep.R`
     - check the `# Subset conditions?` if-statement is set to `FALSE` if you want to run the full simulation study, or to `TRUE` if you want to run a smaller trial study with just a few conditions.
   - PC: Run `prep-lisa-direcotry.sh`:
     - In your terminal, run
       ```
       . code/0-prep-lisa-directory.sh run-name
       ```
       This script creates a folder on your computer by the name `run-name` in the `lisa/` folder.
    - PC: upload the folder `lisa/run-name` to lisa with a commend like
      ```
      scp -r path/to/local/project/lisa/date-run user@lisa.surfsara.nl:mi-spcr
      ```

3. **Prepare and run** *on lisa*:
   - Lisa: run `prep-install.R` to install all R-packages if it's the first time you are running it.
     ```
     Rscript mi-pcr/code/prep-install.R
     ```
   - Lisa: Check all the packages are available by running
      ```
      Rscript mi-pcr/code/init-software.R
      ```
      If you don't get any errors, you are good to go.
   - Lisa: Run the simulation by using the following bash script
     ```
     . mi-spcr/code/1-sim-lisa-1-run.sh partition narray
     ```
     where:
     - `partition` should either be `short` if you are running a small trial or `normal` if you are running the complete simulation study
     - `narray` should be the size of the array of jobs; its value should be the one returned by the `narray` object in the script `1-sim-lisa-1-run.sh` (`ceiling(goal_reps/ncores)`)
   
4. **Store the results**
   - PC: When the array of jobs is done, you can pull the results to your machine by
     ```
     scp -r user@lisa.surfsara.nl:mi-pcr/output/folder path/to/local/project/output/folder
     ```
     For example, from a terminal session in the main folder
     ```
     scp -r user@lisa.surfsara.nl:mi-pcr/output/9829724 ./output/
     ```
    
5. Read the results on your computer:
   - PC: The script `1-sim-lisa-2-unzip.R` goes through the Lisa result folder, unzips tar.gz packages, and puts results together.
   - PC: Finally, you can use the script `2-res-1-shape-results.R` to compute bias, CIC, and all the outcome measures and prepare the RDS objects that can be plotted with the shiny app in `2-res-2-plots.R`.
   - Open and run the script `2-res-1-patchwork.R` to combine results from different results files.

### Running the simulation on a PC / Mac

You can also replicate the simulation on a personal computer by following these steps:

1. **Prepare run**:
    - Open and run `0-prep-install.R` to install all the packages you need to run the simulation
      This will override your `mice` installation. If this is undesirable, you can always install all these packages in a local library for this project.
    - Open `0-init-objects.R`:
      - check/define the seed in `parms$seed`
      - check the fixed parameters and experimental factor levels are set to the desired values.
      - set `run_descr` to a meaningful description
2. **Run the simulation**:
    - Open `1-sim-pc-1-run.R`
      - set the object `reps` to be an integer vector with values from 1 to the number of target repetitions you want to run
      - set the object `clusters` to the number of cores you want to use for parallelization
3. Read the results:
   - Open and run the script `1-sim-pc-2-unzip.R` which unzips the results and creates a unique file with all of the important results.
   - Open and run the script `2-res-1-shape-results.R` to compute bias, CIC, and all the outcome measures and prepare the RDS objects that can be plotted with the shiny app in `2-res-2-plots.R`.
   - Open and run the script `2-res-1-patchwork.R` to combine results from different results files.

### Convergence checks

COMING SOON

## Result files

### For anyone

The final results used for writing up the report are stored in `20221202-105949-results.rds`.
You can read this file and use the plotting functionalities in `2-res-2-plots.R` to interact as you wish with the results. There you can find a shiny app to interact freely with the results in this file. You also have a couple of regular plots.

### For housekeeping of the project

Unfortunately, projects get big, people are not shy with the feedback, parts need to be re-run, and it all becomes a mess. The final result file is the result of pasting together results from different runs. Here is a guide to correctly managing them. The current important files are:

- `9945538-9944296-9943298` (Folder) with the following main results files associated
  - `20220827-094950-run-lisa-9945538-9944296-9943298-unzipped.rds` containing unzipped raw data
  - `20220827-094950-run-lisa-9945538-9944296-9943298-main-res.rds`
  containing processed data (bias, cic, ciw computed)
- `20221126-121849-pcovr-correct-alpha-tuning.tar.gz` which contains the re-run of the PCovR method with the correct alpha tuning. This archive has the following main results files associated:
  - `20221126-121849-pcovr-correct-alpha-tuning-pc-unzipped.rds` containing unzipped raw data
  - `20221126-121849-pcovr-correct-alpha-tuning-pc-main-res.rds` containing processed data (bias, cic, ciw computed)
- `20221202-105949-results.rds` contains the combined results you are using this is the only file that can be found on GitHub. The rest is too big to be stored here.
- `20220729-151828-check-time-per-rep.tar.gz` stores the time to impute for the version with the old alpha PCovR approach
- `20221222-075917-check-time-per-rep.tar.gz` stores the time to impute for the version with the new alpha PCovR approach (taking longer for npcs = ncol(X), but more robust)


## References

Bair, E., Hastie, T., Paul, D., & Tibshirani, R. (2006). Prediction by supervised principal components. Journal of the American Statistical Association, 101(473), 119–137.

De Jong, S., & Kiers, H. A. (1992). Principal covariates regression: part i. theory. Chemometrics and Intelligent Laboratory Systems, 14(1-3), 155–164.

Wold, H. (1975). Path models with latent variables: The nipals approach. In Quantitative sociology (pp. 307–357). Elsevier.

Rubin, D. B. (1987). Multiple imputation for nonresponse in surveys (Vol. 519). New York, NY: John Wiley & Sons.

Van Buuren, S., Boshuizen, H. C., & Knook, D. L. (1999). Multiple imputation of missing blood pressure covariates in survival analysis. Statistics in Medicine, 18(6), 681–694.

