
library(tidyverse)
library(causaldata)
library(fixest)
library(modelsummary)


# so the syntax is outcome ~ controls | endogenous ~ instrument
# it's stage 2 | stage 1 (minus controls?)! (*thanks*, Jeff!)

social_insure |>
  count(takeup_survey)

# is the instrument a good instrument?

# 1. Exclusion Restriction (no open paths between instrument and outcome except through treatment)

# *if* treatment was randomized, then exclusion restriction checks out
# we can gain some confidence by assessing balance between the
# treated and control groups

social_insure |>
  group_by(default) |>
  summarize(mean(age, na.rm = TRUE),
            mean(literacy, na.rm = TRUE),
            mean(disaster_prob, na.rm = TRUE),
            mean(male, na.rm = TRUE),
            mean(risk_averse, na.rm = TRUE))

# 2. Relevant (strong, causal predictor of treatment)
first_stage <- lm(pre_takeup_rate ~ default,
                  data = social_insure)
summary(first_stage)


## Now that we're confident in our validity assumptions,
## we can estimate the effect w/ 2SLS

# if you wanted to do it manually, here's the play:
# first, get the predicted values from the first_stage
social_insure$xhat <- first_stage$fitted.values

# then use those xhats to predict the outcome
second_stage <- lm(takeup_survey ~ xhat,
                   data = social_insure)

summary(second_stage)

# let's see if fixest replicates that
tsls <- feols(takeup_survey ~ 1 | pre_takeup_rate ~ default,
              data = social_insure)
# (note the 1 as a placeholder for "no control variables; just intercept")

summary(tsls)

msummary(list('First Stage' = tsls$iv_first_stage[[1]],
              'Second Stage' = tsls),
         coef_map = c(default = 'First Round Default',
                      fit_pre_takeup_rate = 'Friends Purchase Behavior'),
         stars = c('*' = .1, '**' = .05, '***' = .01))



# adding pre-treatment covariates *should* improve the
# precision of our estimates
tsls <- feols(takeup_survey ~ disaster_prob + age | pre_takeup_rate ~ default,
              data = social_insure)

summary(tsls)
