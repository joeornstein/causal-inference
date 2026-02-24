## Parable of the Bunnies

set.seed(42)

n <- 1e3 # number of elite, racing bunnies

# data-generating process:

# randomly assign treatment to half of them
Tr <- sample(c(0,1), size = n, replace = TRUE)

# speed at which they run the race depends on
# some bunny-specific characteristics + treatment
race_time <- rnorm(n, mean = 15 - 0.5*Tr, sd = 8)

library(tidyverse)
ggplot(mapping = aes(x = race_time,
                     fill = factor(Tr))) +
  geom_density()

# we know that the treatment works (because we created the simulation)
# but it's kinda hard to see that through the noise in the data

## estimate the Average Treatment Effect
df <- data.frame(Tr, race_time) |>
  mutate(bunny_id = 1:n)
mod1 <- lm(race_time ~ Tr, data = df)
summary(mod1)

## Okay. Sad day for bunny research.
## But I think to myself....why does the *bunny*
## have to be the unit of analysis?


# Why can't the bunny *leg* be the unit of analysis?
df1 <- df |>
  mutate(leg = 'Left Front') |>
  mutate(race_time = race_time + rnorm(n, mean = -0.01, sd = 0.0002))

df2 <- df |>
  mutate(leg = 'Right Front') |>
  mutate(race_time = race_time + rnorm(n, mean = -0.01, sd = 0.0002))

df3 <- df |>
  mutate(leg = 'Left Back') |>
  mutate(race_time = race_time - rnorm(n, mean = -0.01, sd = 0.0002))

df4 <- df |>
  mutate(leg = 'Right Back') |>
  mutate(race_time = race_time - rnorm(n, mean = -0.01, sd = 0.0002))

# our leg-level dataframe
df_leg_level <- bind_rows(df1, df2, df3, df4)

mod2 <- lm(race_time ~ Tr, data = df_leg_level)
summary(mod2) ## PUBLISHABLE!

## Issues with this approach:

## 1. No within-bunny variation in treatment.
## 2. Errors are strongly correlated within bunny.
## and we assumed that errors were independent.

## Note that the denominator of our classical
## standard error estimator is sqrt(n), so when
## we artificially quadruple sample size,
## we cut standard errors in half.

## So, we need a standard error estimate that takes
## this correlation into account.

library(estimatr)
mod3 <- lm_robust(race_time ~ Tr,
                  data = df_leg_level,
                  clusters = bunny_id)
summary(mod3)

## Intuition Check: What happens if we add bunny-level fixed effects?
library(fixest)
mod4 <- feols(race_time ~ Tr | bunny_id,
              data = df_leg_level)
# 'Tr' is collinear with the fixed effects means there's no within-bunny variation in treatment.
# There is only one observation per bunny, so fixed effects is inappropriate.