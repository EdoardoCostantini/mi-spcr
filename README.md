# MI-SPCR

[![DOI](https://zenodo.org/badge/510762412.svg)](https://zenodo.org/badge/latestdoi/510762412)

## Simulation study outline

Here is a recap of what I'm doing with this simulation study.

### Compared methods

We want to compare the performance of four methods univariate imputation methods that automatically address the problem of choosing the imputation model predictors.
We use these methods as univariate imputation models in a mice algorithm.
The methods are:

- mi-pcr
- mi-spcr
- mi-plsr
- mi-pcvor

We use as reference methods:

- mi-am
- mi-qp
- mi-all
- cc

### Research questions

1. Does supervised MI-PCA need at least the true number of latent variables as unsupervised PCA does?

2. Does supervised MI-PCA perform better than MI-QP?

### Data generation

We generate data according to a confirmatory factor analysis model.
We want there to be a latent structure, but we don't want to use PCA as a data generation model to avoid using a single model for both data generation and imputation (see Oberman Vink 0000).

### Missing data imposition

We impose multivariate missing data on 3 items, measuring the first latent variable, according to a general missing data pattern (i.e., not monotone).
We use predictors measuring the second latent variable:

- We want to have a multivariate problem because that's what happens in reality.
- We don't want too many variables because it would complicate the design and increase imputation time without adding interesting information.
- We want to have MAR predictors (if required) measuring a different latent variable.
We use the observed items because if we use the latent variables there would be some unpredictable "spurious" MAR:
we would use a proxy of the actual MAR predictor in the imputation models, generating an imputation situation closer to MNAR than MAR.

These are the **missing data mechanisms** we want to use:

```
     X1 X2 X3 X4 X5 X6
MCAR  0  0  0  0  0  0
MAR   0  0  0  1  1  1
```

where 0 indicates a variable with no weight in the linear combination making up the linear predictor for the logit(p) of missingness, and 1 indicates a weight of 1.

The **type of missing data** is fixed to right, left, tails respectively for variables `X1`, `X2`, and `X3` to create realistic missing data patterns.

### Experimental conditions

We vary the following factors:

- The **proportion of missing cases** (`pm = .1, .25, .50`):
  - imposed as stepwise univariate amputation
  - levels chosen based on literature recommendations (Oberman Vink 0000)
- **Missing data mechanism** (`mech = MCAR, MAR`):
    It's important to have all of these situations because:
  - MCAR - a good method should at least work here
  - MAR - the basic assumption everyone makes
- The **number of latent variables** (`nla = 2, 10, 50`):
    From previous work, we know the unsupervised PCA methods require to use of enough PCs as there are latent variables in the data generating model.
    We want to vary the true number of latent variables to verify this.
    The values chosen will reflect:
  - 2 - simple case where we only have the two latent variables that are important for imputation (1 latent variable measured by items receiving amputation and imputation; 1 latent variable measured by the MAR predictors) to show
  - 10 - small dimensionality
  - 50 - large dimensionality
- The **number of principal components** used by the approach (`npcs`);
  To verify the point described for the number of noisy auxiliary variables we need to use the imputation methods with different numbers of PCs.
  These numbers depend of the number of latent variables used:
  - `nla = 2`, `p = 6` -> `npcs = [1:5]`
  - `nla = 10`, `p = 30` -> `npcs = [1:12, 20, 29]`
  - `nla = 50`, `p = 150` -> `npcs = [1:10, 20, 30, 40, 48:52, 60, 149]`
  
### Performance measures

We are interested in:

- item 1 mean: a univariate parameter of interest
- item 1 sd: a univariate parameter of interest
- item 1 and 2 correlation coefficient: bivariate parameter of interest

For these parameters, we want to compute the following performance measures:

- Bias
- Confidence interval coverage
- Confidence interval width

## How to replicate results

To replicate the study, you first need to make sure you have installed all the packages used.
You can use the `./input/prep_machine.R` script to install them.
In the following guide, it is assumed that the machine on which the simulation is run already has all packages installed.

### Convergence checks

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