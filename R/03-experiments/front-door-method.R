
# create 10,000 people
N <- 1e4


# Lots of reasons these people might be more
# likely to smoke and also get cancer;
# unobserved (U)
U <- rnorm(N)

# the amount you smoke is caused by lots of things
Smoking <- 2 * U + rnorm(N)
# we called that last term "Z" on the diagram

# crucial assumption here:
# smoking causes you to get Tar in your lungs
# and the tar in your lungs is the thing that causes cancer
TarInLungs <- 2 * Smoking + rnorm(N)

# and then cancer is caused by Lots of Things
# (environmental and genetic factors)
# and also Tar In Lungs
Cancer <- 3 * TarInLungs + 4 * U + rnorm(N)

# treatment effect of Smoking on Cancer is 6
# (smoking increases Tar by 2, and Tar increases cancer by 3).

# Step 2: Estimate the effect of Smoking on Cancer ---------

# this estimate will biased! because of all the unobserved confounders
lm(Cancer ~ Smoking)

# one way to fix that is to laboriously condition on
# all the things
lm(Cancer ~ Smoking + U)


# BUT, I can't do that. It's really hard.
# There's got to be an easier way!

# Well, I can estimate the effect of Smoking on TarInLungs
lm1 <- lm(TarInLungs ~ Smoking)
lm1

lm2 <- lm(Cancer ~ TarInLungs + Smoking)
lm2

# so, our estimate of the effect of Cancer on Smoking:
lm1$coefficients['Smoking'] * lm2$coefficients['TarInLungs']



## Make the data-generating process slightly more complicated ----

# complication 1: what if your parents smoking both increases your
# odds of smoking and increases the tar in your lungs (secondhand smoke)?
U <- rnorm(N)
ParentsSmoke <- rnorm(N)
Smoking <- 2 * U + 1 * ParentsSmoke + rnorm(N)
TarInLungs <- 2 * Smoking + 0.3 * ParentsSmoke + rnorm(N)
Cancer <- 3 * TarInLungs + 4 * U + rnorm(N)

# now we have to condition on ParentsSmoke to close the backdoor
# paths
lm1 <- lm(TarInLungs ~ Smoking + ParentsSmoke)
lm2 <- lm(Cancer ~ TarInLungs + Smoking + ParentsSmoke)
lm1$coefficients['Smoking'] * lm2$coefficients['TarInLungs']

# complication 2: what if there are multiple mediators?
U <- rnorm(N)
Smoking <- 2 * U + rnorm(N)
TarInLungs <- 2 * Smoking + rnorm(N)
Inflammation <- 1 * Smoking + rnorm(N)
Cancer <- 2 * TarInLungs + 2 * Inflammation + 4 * U + rnorm(N)

# to estimate the effect of smoking on cancer,
# multiply estimates across all causal paths!
lm1 <- lm(TarInLungs ~ Smoking)
lm2 <- lm(Cancer ~ TarInLungs + Smoking)
lm3 <- lm(Inflammation ~ Smoking)
lm4 <- lm(Cancer ~ Inflammation + Smoking)
lm1$coefficients['Smoking'] * lm2$coefficients['TarInLungs'] +
  lm3$coefficients['Smoking'] * lm4$coefficients['Inflammation']

