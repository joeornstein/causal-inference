library(tidyverse)
library(dagitty) # for making DAGs
library(ggdag) # for visualization

variable_labels <- c(
  X = 'presidential approval rating',
  Y = 'executive orders',
  Z = 'divided government',
  P = 'personality',
  XZ = 'interaction of X and Z'
)

# we're interested in the effect of X on Y, moderated by Z.
# do we need to condition on P?

p <- dagify(Y ~ X + Z + P + XZ, # approval rating, divided gov, and personality all affect outcome
            X ~ P,
            XZ ~ X + Z,
            exposure = 'X', # treatment variable is X
            outcome = 'Y',
            labels = variable_labels)

ggdag(p) +
  theme_dag()

ggdag_status(p, use_labels = 'label', text = FALSE) +
  theme_dag()

# what do we have to condition on to recover the effect of X on Y?
adjustmentSets(p)



# adding fixed effects to a DAG?
variable_labels <- c(
  X = 'democracy',
  Y = 'happiness',
  Z = 'country',
  t = 'year'
)

p <- dagify(Y ~ X + Z + t,
            X ~ Z + t,
            exposure = 'X', # treatment variable is X
            outcome = 'Y',
            labels = variable_labels)



ggdag_status(p, use_labels = 'label', text = FALSE) +
  theme_dag()




