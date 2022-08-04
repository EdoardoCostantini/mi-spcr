# MI-SPCR

Here I describe the content of this repository and how to replicate the simulation study.

## Simulation study outline

Here is a recap of what I'm doing with this simulation study.

### Compared methods

We want to compare the performance of four methods univariate imputation methods that automatically address the problem of choosing the imputation model predictors.
We use these methods as univariate imputation models in a mice algorithm.
The methods are:

- mi-pcr
- mi-spcr
- mi-pls
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

### Running the simulation on Lisa

Lisa Cluster is a cluster computer system managed by SURFsara, a cooperative association of Dutch educational and
research institutions.
Researchers at most Dutch universities can request access to this cluster computer.
Here it is assumed that you know how to access Lisa and upload material to the server.
Bullet points starting with "PC" and "Lisa" indicate that the task should be performed in a terminal session on either your personal computer or on Lisa, respecively.

1. **Define run** and perform parameter checks:
   - PC: Open `init-objects.R`:
     - check the fixed parameters and experimental factor levels are set to the desired values.
     - set `run_descr` to a meaningful description
   - PC: Open `prep-software.R`:
     - set the vector `R_pack_lib` to its "lisa" value.
   - PC: Open `prep-install.R`:
     - set the vector `destDir` to its "lisa" value.
   
2. **Prepare run** *on a personal computer*:
   - PC: Open `prep-estimate-time-per-rep.R`:
     - Run it to check how long it takes to perform a single run across all the conditions with the chosen simulation study set up.
       This will create an R object called `wall_time`.
   - PC: Open `sim-lisa-js-normal.sh`:
     - replace the wall time in the header (`#SBATCH -t`) with the value of `wall_time`.
   - PC: Open `prep-lisa-stopos-define.R`: 
     - Decide the number of repetitions, cores, and arrays in the preparatory script 
       For example:
       ```
       goal_reps <- 250
       ncores    <- 15 # Lisa nodes have 16 cores available (16-1 used)
       narray    <- ceiling(goal_reps/ncores) # number of arrays/nodes to use 
       ```
       Once you have specified these values, *run the script on your computer*.
       ```
       Rscript prep-lisa-stopos-define.R 
       ```
       This will create a `stopos-lines` text file in the `input` folder that will define the repetition index for lisa.
   - PC: Open `sim-lisa-step1-storeInfo.R`
     - check `subset_cond` set to `TRUE` if you want a short run, `FALSE` if you want the full run
   - PC: Open `sim-lisa-step2-run-doRep.R`
     - check `subset_cond` set to `TRUE` if you want a short run, `FALSE` if you want the full run
   - PC: Run `prep-lisa-direcotry.sh`:
     - In your terminal, run
       ```
       . code/prep-lisa-directory.sh run-name
       ```
       This script creates a folder on your computer by the name `run-name` in the `lisa/` folder.

3. **Prepare run** *on lisa*:
   - PC/Lisa: Authenticate on Lisa
   - PC: Upload the folder `lisa/run-name` to the lisa cluster by running the following command in your terminal
     ```
     scp -r path/to/local/project/lisa/date-run user@lisa.surfsara.nl:mi-spcr
     ```
     For example:
     ```
     scp -r lisa/20211116 ******@lisa.surfsara.nl:mi-spcr
     ```
   - Lisa: run `prep-install.R` to install all R-packages if it's the first time you are running it.
     ```
     Rscript mi-pcr/code/prep-install.R
     ```
   - Lisa: Check all the packages called by the `init-software.R` script are available by running
     ```
     Rscript mi-pcr/code/init-software.R
     ```
   
   - Lisa: Load the following modules
     ```
     module load 2021
     module load R/4.1.0-foss-2021a
     module load Stopos/0.93-GCC-10.3.0
     ```
     (or their most recent version at the time you are running this)
   - Lisa: go to the code folder in the lisa cloned project
     ``` 
     cd mi-spcr/code/
     ```
   - Lisa: run the prepping script by
     ```
     . prep-lisa-stopos-deploy.sh ../input/stopos-lines
     ```
     
4. **Run simulation**
   - Lisa: submit the jobs by using the following command
     ```
     sbatch -a 1-34 sim-lisa-js-normal.sh 
     ```
     Note that `1-34` defines the dimensionality of the array of jobs. 
     For a short partitioning, only 2 arrays are allowed.
     For other partitioning, more arrays are allowed.
     34 is the result of `ceiling(goal_reps/ncores)` for the chosen parameters in this example.
     You should replace this number with the one that makes sense for your study.
     A trial job, in the short partition, can be sumbitted by:
     ```
     sbatch -a 1-2 sim-lisa-js-short.sh
     ```
   - PC: When the array of jobs is done, you can pull the results to your machine by
     ```
     scp -r user@lisa.surfsara.nl:mi-pcr/output/folder path/to/local/project/output/folder
     ```
     For example, from a terminal session in the main folder
     ```
     scp -r u590194@lisa.surfsara.nl:mi-pcr/output/9829724 ./output/
     ```
    
5. Read the results on your computer:
   - PC: The script `sim-lisa-unzip.R` goes through the Lisa result folder, unzips tar.gz packages, and puts results together.
   - PC: Finally, the script `res-step2-shape-results.R` computes bias, CIC, and all the outcome measures. 
     It also puts together the RDS objects that can be plotted with the shiny app in `res-step3-plots.R`

### Running the simulation on a PC / Mac

You can also replicate the simulation on a personal computer by following these steps:

1. run the `prep_machine.R` script assuming working directory `./code/` - This script will:
    - create a local R library for the R packages needed by this simulation study
    - install the required version of all packages in this local folder, directly from CRAN (note: this will not interfere with the R-packages versions you have installed on your computer)
    - install the required development version of `mice` in this local folder

### Convergence checks

COMING SOON

## Output files

COMING SOON

## Repository structure

Here is the project structure:

```
.
├── LICENSE
├── README.md
├── code
│ ├── checks
│ │ └── check-dataGen.R
│ ├── functions
│ │ ├── dataGen.R
│ │ ├── estimatesComp.R
│ │ ├── estimatesPool.R
│ │ ├── genLaavanMod.R
│ │ └── simMissingness.R
│ ├── helper
│ │ ├── readTarGz.R
│ │ └── writeTarGz.R
│ ├── init-objects.R
│ ├── init-software.R
│ ├── plots
│ ├── prep-convergence-check.R
│ ├── prep-estimate-time-per-cond.R
│ ├── prep-estimate-time-per-rep.R
│ ├── prep-lisa-create-stopos.sh
│ ├── prep-lisa-stopos-lines.R
│ ├── res-step1-evaluate-imputation.R
│ ├── res-step2-shape-results.R
│ ├── res-step3-plots.R
│ ├── sim-lisa-js-normal.sh
│ ├── sim-lisa-js-short.sh
│ ├── sim-lisa-step1-storeInfo.R
│ ├── sim-lisa-step2-run-doRep.R
│ ├── sim-lisa-unzip.R
│ ├── sim-pc-step1-run.R
│ ├── sim-pc-step2-unzip.R
│ └── subroutines
│     ├── runCell.R
│     ├── runCond.R
│     └── runRep.R
├── input
│   └── prep_machine.R
├── lisa
├── manuscript
│   ├── Makefile
│   ├── bib
│   ├── code
│   ├── compile_pdf.sh
│   ├── figure
│   ├── makearxiv.sh
│   ├── pdf
│   ├── poolBib.sh
│   ├── rds
│   ├── style
│   │   ├── asj.bst
│   │   └── sagej.cls
│   ├── submissions
│   └── trackChanges.sh
├── output
│   ├── checks
│   ├── freezed
│   ├── lisa
│   └── trash
└── tests
    └── testthat

```

Here is a brief description of the folders:

COMING SOON
