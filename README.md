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

### Experimental conditions

We vary the following factors:

- The **proportion of missing cases** (`pm = .1, .25, .50`):
  - imposed as stepwise univariate amputation
  - levels chosen based on literature recommendations (Oberman Vink 0000)
- **Missing data mechanism** (`mech = MCAR, MAR, MNAR`):
    It's important to have all of these situations because:
  - MCAR - a good method should at least work here
  - MAR - the basic assumption everyone makes
- The **shape of missing data** (`loc = right, left, tail`): defined as a fixed random factor with levels sampled from
- The **number of noisy auxiliary variables** (`nla = 2, 10, 100`):
    From previous work, we know the unsupervised PCA methods require to use of enough PCs as there are latent variables in the data generating model.
    We want to vary the true number of latent variables to verify this.
    The values chosen will reflect:
  - 2 - simple case where we only have the two latent variables that are important for imputation (1 latent variable measured by items receiving amputation and imputation; 1 latent variable measured by the MAR predictors) to show
  - 10 - small dimensionality
  - 100 - large dimensionality
- The **number of principal components** used by the approach (`npcs`);
  To verify the point described for the number of noisy auxiliary variables we need to use the imputation methods with different numbers of PCs.
  These numbers depend of the number of latent variables used:
  - `nla = 2` -> `npcs = [1:6]`
  - `nla = 10` -> `npcs = [1:12, 20, 30]`
  - `nla = 50` -> `npcs = [1:12, 20, 30, 30, 40, 48:52, 60, 100, 150]`
  - `nla = 100` -> `npcs = [1:10, seq(20, 90, by = 10), 98, 99, 100, 101, 102, 110, 300]`
  
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

### Running the simulation on Lisa

Lisa Cluster is a cluster computer system managed by SURFsara, a cooperative association of Dutch educational and
research institutions.
Researchers at most Dutch universities can request access to this cluster computer.

COMING SOON

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
????????? LICENSE
????????? README.md
????????? code
???   ????????? checks
???   ????????? functions
???   ????????? helper
???   ????????? plots
???   ????????? subroutines
????????? input
???   ????????? prep_machine.R
????????? lisa
????????? manuscript
???   ????????? Makefile
???   ????????? bib
???   ????????? code
???   ????????? compile_pdf.sh
???   ????????? figure
???   ????????? makearxiv.sh
???   ????????? pdf
???   ????????? poolBib.sh
???   ????????? rds
???   ????????? style
???   ???   ????????? asj.bst
???   ???   ????????? sagej.cls
???   ????????? submissions
???   ????????? trackChanges.sh
????????? output
???   ????????? checks
???   ????????? freezed
???   ????????? lisa
???   ????????? trash
????????? tests
    ????????? testthat

```

Here is a brief description of the folders:

COMING SOON
