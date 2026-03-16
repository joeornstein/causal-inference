# Causal Inference Course Repository

Graduate seminar on causal inference (POLS 8500) taught at the University of Georgia.

## Repository Structure

```
causal-inference/
├── R/                         # Teaching scripts and demos
│   ├── 01-causal-salads/      # Foundational problems: confounding, naive regression
│   ├── 02-dags/               # DAGs with dagitty and ggdag
│   ├── 03-experiments/        # Experiments, front-door method, VWATE
│   ├── 04-selection-on-observables/  # Matching (e.g., mtcars example)
│   ├── 05-fixed-effects/      # Panel data, Broockman & Kalla replication
│   ├── 06-diff-in-diff/       # DiD from first principles, simulation-based (AVR/turnout example)
│   └── _archive/              # Older/unused scripts
├── data/                      # Datasets
│   ├── simulated_dataset.RData
│   ├── bcs-cc-42.rds
│   └── finkel-et-al/          # Tunisian civic education experiment data (.dta)
├── papers/                    # Course reference PDFs
├── syllabus/                  # Syllabus (LaTeX/PDF), schedule, presentation dates
└── _dross/                    # Archive of older materials
```

## Topics Covered (15-week curriculum)

1. Causal salads / credibility revolution
2. Potential outcomes framework
3. Directed acyclic graphs (DAGs)
4. Experiments and natural experiments
5. Selection on observables (regression, matching, entropy balancing)
6. Fixed effects
7. Difference-in-differences (including staggered adoption)
8. Instrumental variables
9. Regression discontinuity

## Key Packages

- `dagitty`, `ggdag` — causal diagrams
- `Matching` — matching methods
- `fixest` — fixed effects regression
- `haven` — reading Stata .dta files
- `tidyverse`, `broom` — data wrangling and tidy model output

## Data Formats

- `.RData`, `.rds` — R data files
- `.dta` — Stata files (load with `haven::read_dta()`)
