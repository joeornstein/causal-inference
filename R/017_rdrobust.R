
# simulate some data and estimate local average treatment effects
# using rdrobust

library(tidyverse)
library(rdrobust)

## 1. Simulate Data ---------------------------

treatment_effect <- 1
nobs <- 1000

# our running variable (score variable) is uniformly randomly distributed
X <- runif(nobs, -1, 1)

# treatment is assigned at a cutoff (0)
Tr <- as.numeric(X > 0)

# Y is some crazy function of X plus the treatment effect,
# plus some random error
Y <- 3 + 4*X - 6*X^2 + 3*X^3 + treatment_effect * Tr +
  rnorm(nobs, 0, 1)


ggplot(mapping = aes(x=X, y=Y,
                     color = Tr)) +
  geom_point()

## 2. Estimate the Local Average Treatment Effect (LATE) -----------------------

rd <- rdrobust(y = Y, x = X, c = 0)

summary(rd)

# this is the default plot from rdrobust package, which plots a binned scatter plot
rdplot(y = Y,
       x = X,
       c = 0)

# here's the one I like a little better
devtools::install_github('joeornstein/rdviz')
library(rdviz)

rdviz(x = X, y = Y) +
  theme_classic()

## 3. A few robustness tests that are really useful here ----------------

# one is bandwidth robustness. set the bandwidth manually
# and make sure that you end up with similar results
rd_bw_robustness <- rdrobust(y = Y, x = X, c = 0, h = 0.2)
summary(rd_bw_robustness)

# ideally, you want to loop through a bunch of different bandwidth choices

# create a sequence of bandwidths
bws <- seq(0.05, 0.4, 0.01)

# create three empty vectors to hold your estimates and confidence intervals
lates <- numeric(length(bws))
ci_upper <- numeric(length(bws))
ci_lower <- numeric(length(bws))

for(i in 1:length(bws)){

  # for each bandwidth, estimate a new treatment effect and 95% CI
  rd_new <- rdrobust(y = Y, x = X, c = 0, h = bws[i])

  lates[i] <- rd_new$coef['Robust', 'Coeff']
  ci_upper[i] <- rd_new$ci['Robust', 'CI Upper']
  ci_lower[i] <- rd_new$ci['Robust', 'CI Lower']

}

bws
lates
ci_upper
ci_lower

ggplot(mapping = aes(x = bws,
                     y = lates,
                     ymax = ci_upper,
                     ymin = ci_lower)) +
  geom_pointrange() +
  theme_classic() +
  geom_hline(yintercept = 0, linetype = 'dashed') +
  labs(x = 'Bandwidth', y = 'Estimate and 95% CI')



