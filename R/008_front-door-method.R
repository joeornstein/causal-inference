

# create 10,000 people
N <- 1e4


# Lots of reasons these people might be more
# likely to smoke and also get cancer
LotsOfThings <- rnorm(N)

# the amount you smoke is caused by lots of things
Smoking <- 2 * LotsOfThings + rnorm(N)

# crucial assumption here:
# smoking causes you to get Tar in your lungs
# and the tar in your lungs is the thing that causes cancer
TarInLungs <- 2 * Smoking + rnorm(N)

# and then cancer is caused by Lots of Things
# (environmental and genetic factors)
# and also Tar In Lungs
Cancer <- 3 * TarInLungs + 4 * LotsOfThings + rnorm(N)


# Step 2: Estimate the effect of Smoking on Cancer ---------

# this estimate will biased! because of the LotsOfThings
lm(Cancer ~ Smoking)

# one way to fix that is to laboriously condition on
# all the things
lm(Cancer ~ Smoking + LotsOfThings)


# BUT, I can't do that. It's really hard.
# There's got to be an easier way!

# Well, I can estimate the effect of Smoking on TarInLungs
lm1 <- lm(TarInLungs ~ Smoking)
lm1

lm2 <- lm(Cancer ~ TarInLungs + Smoking)
lm2

# so, our estimate of the effect of Cancer on Smoking:
lm1$coefficients['Smoking'] * lm2$coefficients['TarInLungs']
