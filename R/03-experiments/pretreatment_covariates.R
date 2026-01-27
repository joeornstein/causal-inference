# okay, we know not to condition on post-treatment variables
# (mediators, colliders)
# but what about pre-treatment covariates,
# even if the treatment is randomized?

## Simulate Survey Experiment

set.seed(1000)

N <- 5e3 # 5,000 participants

# randomly assigned to small or large class
Tr <- sample(c(0,1), size = N, replace = TRUE)

# half of them are boys, half girls
boy <- sample(c(0,1), size = N, replace = TRUE)

# half rich, half poor
rich <- sample(c(0,1), size = N, replace = TRUE)

# grades are affected by:
# (1) the class size treatment
# (2) gender
# (3) family income
# (4) and a bunch of other things we don't measure (rnorm)
grade <- 0.1*Tr - 1*boy + 3*rich + rnorm(N)


# this is an unbiased estimator of the treatment effect
lm1 <- lm(grade ~ Tr)

summary(lm1)

# the treatment has a relatively small effect, compared to
# all the other things that are affecting the outcome,
# which is why it has a relatively large standard error

# the *precision* of the estimator is one rationale
# for including some of those other pre-treatment covariates
# that affect the outcome in our model

lm2 <- lm(grade ~ Tr + boy + rich)
summary(lm2)



# graphically:

library(tidyverse)

# this is what we're doing when we don't condition on the
# pre-treatment covariates
ggplot(mapping = aes(x = grade,
                     fill = factor(Tr))) +
  geom_density(alpha = 0.5) +
  labs(fill = 'Treatment Group')

# this is what we're doing when we condition on
# the pre-treatment covariates
ggplot(data = tibble(grade, Tr, boy, rich),
       mapping = aes(x = grade,
                     fill = factor(Tr))) +
  geom_density(alpha = 0.5) +
  labs(fill = 'Treatment Group') +
  facet_grid(boy~rich)



