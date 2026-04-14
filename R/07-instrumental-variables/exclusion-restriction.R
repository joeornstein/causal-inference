## illustrating an exclusion restriction violation
library(dagitty)
library(ggdag)

# simulating a data-generating process that looks like this:
dagify(Y ~ X + U,
       X ~ Z,
       Z ~ U) |>
  ggdag() +
  theme_dag()


# set.seed(42)
n <- 500 # number of observations
U <- rnorm(n) # unobserved confounder
Z <- 0.5 * U + rnorm(n) # proposed instrument
X <- 0.5 * Z + rnorm(n)
Y <- X - U + rnorm(n)

plot(X,Y)
lm(Y~X) # should equal 1, but...biased by confounder U

lm(Y ~ X + U) # if we can measure U, hooray!

# 2SLS
first_stage <- lm(X ~ Z)
lm( Y ~ fitted(first_stage) ) # even worse!


# but...does this remind you of any other design we looked at previously???


# .
# .
# .
# .
# .
# .

# what about the "front door method?" (03-experiments)

# I can estimate the effect of Z on X
lm1 <- lm(X ~ Z)
lm1

# and estimate the effect of X on Y (conditioning on Z blocks the other backdoor paths)
lm2 <- lm(Y ~ X + Z)
lm2

# the effect of Z on Y is:
lm1$coefficients['Z'] * lm2$coefficients['X']
# which should be in the neighborhood of 0.5, given the DGP.
