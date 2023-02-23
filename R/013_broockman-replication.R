## Replicating Broockman (2013). Are black legislators more
## intrinsically motivated to respond to black constituents?

library(tidyverse)
library(causaldata)

d <- black_politicians



# look at the distributions of some potential confounders

ggplot(data = d,
       mapping = aes(x=blackpercent,
                     fill = factor(leg_black))) +
  geom_density(alpha = 0.4)

# notice where the overlap is!!

ggplot(data = d,
       mapping = aes(x=medianhhincom,
                     fill = factor(leg_black))) +
  geom_density(alpha = 0.4)


ggplot(data = d,
       mapping = aes(x=totalpop,
                     fill = factor(leg_black))) +
  geom_density(alpha = 0.4)

ggplot(data = d,
       mapping = aes(x=leg_democrat,
                     fill = factor(leg_black))) +
  geom_density(alpha = 0.4)


## A few matching methods ---------------

library(Matching)

# basic default is nearest neighbor matching (M=1) using
# Mahalanobis distance (Weight = 2)
m <- Match(Y = d$responded,
           Tr = d$leg_black,
           X = cbind(d$medianhhincom, d$blackpercent, d$leg_democrat),
           Weight = 2)

# check balance on m
data_treated <- d[m$index.treated,]
data_control <- d[m$index.control,]

data_matched <- bind_rows(data_treated, data_control)


ggplot(data = data_matched,
       mapping = aes(x=blackpercent,
                     fill = factor(leg_black))) +
  geom_density(alpha = 0.4) # is this a Toyota Corona Situation?



ggplot(data = data_matched,
       mapping = aes(x=medianhhincom,
                     fill = factor(leg_black))) +
  geom_density(alpha = 0.4)


ggplot(data = data_matched,
       mapping = aes(x=totalpop,
                     fill = factor(leg_black))) +
  geom_density(alpha = 0.4)

ggplot(data = data_matched,
       mapping = aes(x=leg_democrat,
                     fill = factor(leg_black))) +
  geom_density(alpha = 0.4)

## TODO: Look at other covariates + other matching algorithms