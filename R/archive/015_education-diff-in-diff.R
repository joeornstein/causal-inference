
library(tidyverse)

# here's the dataset from Ralph Scott's paper
d <- read_rds('data/bcs-cc-42.rds')

# what should we do about the dependent variables? normalizing has...problems.


# let's use pct_strongly_agree (/agree_fully) as our outcome

d <- d |>
  mutate(support_deathpen16 = as.numeric(deathpen16 > 0.9),
         support_deathpen26 = as.numeric(deathpen26 > 1),
         support_deathpen30 = as.numeric(deathpen30 > 1.1),
         support_deathpen42 = as.numeric(deathpen42 > 1.2))


# we need to format the data "long", with one row for each person-time
d_long <- d |>
  mutate(numeric_id = 1:n()) |>
  select(numeric_id, bcsid, support_deathpen16:support_deathpen42) |>
  pivot_longer(cols = support_deathpen16:support_deathpen42,
               values_to = 'support_deathpen',
               names_to = 'age') |>
  mutate(age = age |>
           str_replace_all('support_deathpen', '') |>
           as.numeric()) |>
  left_join(d |>
              select(bcsid, deg26, deg30, deg42, parscr, pared),
            by = 'bcsid') |>
  mutate(Treated = as.numeric(deg26 == 1 & age > 16))

# people whose parents went to college are much more likely to be in the treatment group
d_long |>
  group_by(pared) |>
  summarize(mean(deg26))


# this is the diff-in-diff, in a nutshell. The gap gets bigger for the college graduates.
d_long |>
  group_by(deg26, age) |>
  summarize(pct_support = mean(support_deathpen))


d_long |>
  group_by(deg26, age) |>
  summarize(pct_support = mean(support_deathpen)) |>
  ggplot(mapping = aes(x=age, y=pct_support, linetype = factor(deg26))) +
  geom_line() +
  geom_point()

# hold parental education constant (parents went to college)
d_long |>
  filter(pared == 3) |>
  group_by(deg26, age) |>
  summarize(pct_support = mean(support_deathpen)) |>
  ggplot(mapping = aes(x=age, y=pct_support, linetype = factor(deg26))) +
  geom_line() +
  geom_point()

# estimating Average Treatment Effect on the Treated (ATT)

# we want to know the difference between these two slopes.
# one option: interaction term between group and time
mod1 <- lm(support_deathpen ~ factor(age) * factor(deg26), data = d_long)

summary(mod1)
# this works to get the estimate (coefficient on interaction term),
# but......the standard errors are wrong.


# so, here's the other way (and I'll say the correct way) to do it
library(fixest)
# what is the effect of treatment, holding person and time constant (fixed effects)
mod2 <- feols(support_deathpen ~ Treated | bcsid + factor(age),
              data = d_long |> filter(age %in% c(16, 26)))
summary(mod2)
# clusters by default at the level of that first fixed effect


# we can estimate it a third way, with the did package
# This is Callaway & Santa'Ana

library(did)

# 1. allows us to match on pre-treatment covariates
# 2. if the treatment "rolls out" over multiple periods, we can split the data into groups
#    and estimate separate group-time ATTs for each group that gets treated at a different time

d_long <- d_long |>
  mutate(treatment_group = case_when(deg26 == 1 ~ 26,
                                     deg30 == 1 ~ 30,
                                     deg42 == 1 ~ 42,
                                     TRUE ~ 0))

# make sure the levels are in the correct order
levels(d_long$age)
levels(d_long$treatment_group)


mod3 <- att_gt(yname = 'support_deathpen', # outcome variable
               tname = 'age', # time period variable
               idname = 'numeric_id', # unit-level id
               gname = 'treatment_group', # the treatment group (0 if never treated)
               data = d_long)

summary(mod3)

# we can include pre-treatment variables to match on like this:
mod4 <- att_gt(yname = 'support_deathpen', # outcome variable
               tname = 'age', # time period variable
               idname = 'numeric_id', # unit-level id
               gname = 'treatment_group', # the treatment group (0 if never treated)
               xformla = ~pared+parscr, # match on parent's education and socioeconomic status
               data = d_long)

summary(mod4)

ggdid(mod4)

aggte(mod4)

# notice that when we do it this way, we've stopped being super careful about the matching
# like we were a few weeks ago (checking for Toyota Corona problems)

# I'd suggest poking at the data a bit to make sure that there's common support before you do
# this.



### Now let's go back and estimate the full set of group-time ATTs ----------------












