
mtcars

# do 1974 cars with manual transmissions get better
# gas mileage?

model1 <- lm(mpg ~ am, data = mtcars)
summary(model1)


# is weight a confounding variable?
# weight -> am
# weight -> mpg

lm(mpg ~ wt, data = mtcars) # heavier cars get worse gas mileage
lm(wt ~ am, data = mtcars) # manual transmission cars are 1,300 pounds lighter on average


# chuck it into the regression?
model2 <- lm(mpg ~ am + wt, data = mtcars)
summary(model2)
# success? did I show that transmission has no impact on mileage?


# regression makes two identifying assumptions:
# 1. selection on observables (we've identified and conditioned on all confounders)
# 2. functional form. the relationship between weight and mpg is *linear*

# is the second assumption reasonable?

library(tidyverse)

ggplot(data = mtcars,
       mapping = aes(x = wt,
                     y = mpg)) +
  geom_point() +
  geom_smooth()

# so...maybe linearity is a sensible assumption, but maybe not.
# perhaps there's some diminishing returns to making your car
# lighter or heavier.

# one thing we could do is just make the model more complicated.
mtcars$wt_sq <- mtcars$wt^2
model3 <- lm(mpg ~ am + wt + wt_sq, data = mtcars)
summary(model3)

# but the problem is....where does this end?
# how complicated should we make the model?

# we could LASSO it; and let the model decide.


# or....we could forego functional assumptions entirely!

## 2. Matching --------------------------

ggplot(data = mtcars,
       mapping = aes(x = wt,
                     y = mpg,
                     color = factor(am))) +
  geom_point()


library(Matching)

m <- Match(Y = mtcars$mpg,
           Tr = mtcars$am,
           X = mtcars$wt, # confounder variables
           M = 1) # one-to-one matching

m$index.treated # row numbers for treated observations in original dataset
m$index.control # row numbers for matched control observations

# which cars are in this matched control group?
rownames(mtcars)[m$index.control]

# I call this "The Toyota Corona Problem"
# but...in the textbook it's called
# the "Common Support Problem"

# The issue here is that there are several lightweight cars
# that we are all comparing to the Toyota Corona. It's the closest match
# but that doesn't mean it's a good match.

# When we fit a regression model, we just ignored this problem.
# The way it "solved" the Common Support problem
# was to extrapolate, and guess what mpg the lightweight
# cars *should* have.


## Balance Tests ------------

data_control <- mtcars[m$index.control,]
data_treated <- mtcars[m$index.treated,]

matched_dataset <- rbind(data_control, data_treated)

# in this matched dataset, the balance on wt variable
# should be much better

mtcars |>
  group_by(am) |>
  summarize(mean_wt = mean(wt))

matched_dataset |>
  group_by(am) |>
  summarize(mean_wt = mean(wt))

summary(lm(wt ~ am, data = matched_dataset))

ggplot(data = matched_dataset,
       mapping = aes(x = wt,
                     y = mpg,
                     color = factor(am))) +
  geom_point()

# to perform these balance tests, consider
# something called an "Equivalence Test" (Hartman & Hidalgo 2018)

# we want a statistical test where we can confidently claim
# that the difference between the two group is *negligible*

# but...don't continue to this diagnostic if we failed the common
# support test. that's a crucial identifying assumption!



## Estimating ATT -------

## definitely don't proceed to this step if you've failed
# the common support assumption or the balance tests!

# but, if you have good reason to believe that you have common
# support and good balance on your pretreatment covariates, then...


summary(m) # notice: nothing broke! it gives a result.
# I just don't believe it.


## Matching on multiple variables ---------

ggplot(data = mtcars,
       mapping = aes(x=wt,
                     y=hp,
                     color = factor(am))) +
  geom_point()

# Mahalanobis distance tries to find the "closest" control
# observation for each treated observation. But to do so,
# it rescales the hp dimension, because the variance in hp
# is so much larger than the variance in wt.
# it also considers pairs of observations to be "farther" if
# they move in a direction that is not what we would expect,
# given the correlation between hp and wt.

# formal definitio of Mahalanobis distance:
# sqrt((x1 - x2)' * S^-1 * (x1 - x2))
# where S is the variance-covariance matrix
# Euclidean distance just gets rid of that S^-1 term.

# thank goodness, the package does all this for us:


m <- Match(Y = mtcars$mpg,
           Tr = mtcars$am,
           X = cbind( mtcars$wt, mtcars$hp ), # confounder variables
           Weight = 2, # Mahalanobis Distance
           M = 1)

m$index.treated
m$index.control

data_control <- mtcars[m$index.control,]
data_treated <- mtcars[m$index.treated,]

matched_dataset <- rbind(data_control, data_treated)

# in this matched dataset, the balance on wt and hp variable
# should be much better

mtcars |>
  group_by(am) |>
  summarize(mean_wt = mean(wt),
            mean_hp = mean(hp))

matched_dataset |>
  group_by(am) |>
  summarize(mean_wt = mean(wt),
            mean_hp = mean(hp))


