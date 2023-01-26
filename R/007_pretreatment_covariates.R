# okay, we know not to condition on post-treatment variables
# (mediators, colliders)
# but what about pre-treatment covariates,
# even if the treatment is randomized?

## Simulate Tennessee STAR

N <- 1e4 # 10,000 kids

# randomly assigned to small or large class
Tr <- sample(c(0,1), size = N, replace = TRUE)

# half of them are boys, half girls
boy <- sample(c(0,1), size = N, replace = TRUE)

# grades are affected by both the class size
# treatment and gender, and a bunch of other things
grade <- 0.2*Tr - 1*boy + rnorm(N, mean = 0, sd = 5)


# this is an unbiased estimator of the treatment effect
lm1 <- lm(grade ~ Tr)

summary(lm1)

# the treatment has a relatively small effect, compared to
# all the other things that are affecting the outcome,
# which is why it has a relatively large standard error

# the *precision* of the estimator is one rationale
# for including some of those other things that affect the outcome
# in our model

lm2 <- lm(grade ~ Tr + boy)
summary(lm2)





