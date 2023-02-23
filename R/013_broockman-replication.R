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

## Linear model approach ---------------

# this will be useful as a comparison
lm1 <- glm(responded ~ leg_black + medianhhincom + blackpercent +
             leg_democrat, data = d)

summary(lm1)


## A few matching methods ---------------

library(Matching)

# basic default is nearest neighbor matching (M=1) using
# Mahalanobis distance (Weight = 2)
m <- Match(Y = d$responded,
           Tr = d$leg_black,
           X = cbind(d$medianhhincom, d$blackpercent, d$leg_democrat),
           Weight = 2,
           replace = TRUE)

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

## I'm unhappy with matching observation 1499 22 times and observation
## 4981 17 times. We're using the non-black legislators in majority-black
## districts TOO much

# So, let's restrict our estimand. Intead of the ATT,
# let's look at the Average Treatment Effect just in
# minority-black districts


d2 <- d |>
  filter(blackpercent < 0.5)

d |>
  count(leg_black)

d2 |>
  count(leg_black)

# so here's the bias-variance tradeoff again.
# in an effort to get better (unique) matches,
# we had to throw out 2/3 of our black state legislators

# alright. so we're going to content ourselves with the
# matching with replacement!


## Next question: what about some of the covariates we *didn't* match on?

# is professionalism balanced across groups?

ggplot(data = data_matched,
       mapping = aes(x=statessquireindex,
                     fill = factor(leg_black))) +
  geom_density(alpha = 0.4)

data_matched |>
  group_by(leg_black) |>
  summarize(median(statessquireindex),
            quantile(statessquireindex, 0.25),
            quantile(statessquireindex, 0.75))


# alright, so let's throw it in the stew

m2 <- Match(Y = d$responded,
           Tr = d$leg_black,
           X = cbind(d$medianhhincom, d$blackpercent, d$leg_democrat,
                     d$statessquireindex),
           Weight = 2,
           replace = TRUE)

# check balance on m
data_treated <- d[m2$index.treated,]
data_control <- d[m2$index.control,]

data_matched <- bind_rows(data_treated, data_control)


ggplot(data = data_matched,
       mapping = aes(x=statessquireindex,
                     fill = factor(leg_black))) +
  geom_density(alpha = 0.4)

data_matched |>
  group_by(leg_black) |>
  summarize(median(statessquireindex),
            quantile(statessquireindex, 0.25),
            quantile(statessquireindex, 0.75))


# did we make the Toyota Corona problem worse?
m2$index.control |>
  table() |>
  sort()


summary(m2)
# this is a start with the MatchIt package.....
# library(MatchIt)
# m3 <- matchit(responded ~ leg_black + medianhhincom + blackpercent +
#                 leg_democrat + statessquireindex,
#               data=d,
#               distance='mahalanobis')



## Entropy Balancing ---------------

# find a *weighted* control group that perfectly
# matches the treatment group

library(ebal)

eb <- ebalance(Treatment = d$leg_black,
               X = cbind(d$medianhhincom,
                         d$blackpercent,
                         d$leg_democrat,
                         d$statessquireindex))


# just like before, all the treated observations have weight = 1
d_treat <- d |>
  filter(leg_black == 1)|>
  mutate(weights = 1)

# each of the control observations has some weight (eb$w)
d_con <- d |>
  filter(leg_black == 0) |>
  mutate(weights = eb$w)

d_eb <- bind_rows(d_treat, d_con)

# verify that the groups are balanced
d_eb |>
  group_by(leg_black) |>
  summarize(weighted.mean(leg_democrat, weights),
            weighted.mean(blackpercent, weights))

library(modelsummary)
m <- lm(responded ~ leg_black, data = d_eb, weights = weights)
msummary(m, stars = c('*' = .1, '**' = .05, '***' = .01))


