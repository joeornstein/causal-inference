## Difference-in-Differences Tutorial
##
## We'll build up to DiD through a series of simulations.

library(tidyverse)


## 1. Set Up Simulation ---------------------

set.seed(5280)

n <- 3000  # counties

# Scenario: some counties adopt automatic voter registration (AVR).
# We want to know the effect of AVR on voter turnout.

# Each county has an underlying "civic culture" -- an unobserved propensity
# for political participation. Think: historical organizational density,
# newspaper readership, social trust, etc.
civic_culture <- rnorm(n, mean = 50, sd = 10)

# Treatment effects vary by county, averaging 4 percentage points.
tau <- rnorm(n, mean = 4, sd = 2)

# Potential outcomes (turnout as a percentage)
# Higher civic culture -> higher baseline turnout, regardless of AVR.

# turnout without AVR
Y0 <- 35 + 0.5 * civic_culture + rnorm(n, sd = 5)

# turnout with AVR
Y1 <- Y0 + tau

# True ATE -- we know this because we built the simulation
mean(tau)

# Treatment assignment: counties with stronger civic culture are more likely
# to adopt AVR. This is the key confound -- "better" counties self-select in.
p_treat <- plogis(-5.5 + 0.09 * civic_culture)
Treated <- rbinom(n, size = 1, prob = p_treat)

mean(Treated)  # ~30% of counties adopt

# Observed outcome: we see Y1 for treated counties, Y0 for control
turnout <- ifelse(Treated == 1, Y1, Y0)

df <- tibble(
  county_id      = 1:n,
  civic_culture  = civic_culture,  # unobserved in practice
  Y0             = Y0,
  Y1             = Y1,
  Treated        = Treated,
  turnout        = turnout
)


## 2. Naive difference-in-means estimator -----------------------------------------------

# What's the average turnout in each group?
df |>
  group_by(Treated) |>
  summarize(mean_turnout = mean(turnout))

# The naive estimate of the treatment effect:
summary(lm(turnout ~ Treated, data = df))

# True ATE is ~4 pp -- but the naive estimate is much larger.
# Treated counties were already higher-turnout to begin with.

# We can see this directly: treated counties have higher civic culture on average
df |>
  group_by(Treated) |>
  summarize(mean_civic_culture = mean(civic_culture))

# And civic culture is strongly related to Y0 (baseline turnout)
ggplot(df, aes(x = civic_culture, y = Y0, color = factor(Treated))) +
  geom_point(alpha = 0.4) +
  scale_color_manual(values = c("0" = "#E69F00", "1" = "#0072B2")) +
  labs(x = "Civic Culture (unobserved)", y = "Baseline Turnout (Y0)",
       color = "Adopted AVR")

# The problem in a nutshell: E[Y0 | Treated=1] != E[Y0 | Treated=0]
# Selection into treatment is correlated with the potential outcome.
# This violates the ignorability assumption we need for difference-in-means.

df |>
  group_by(Treated) |>
  summarize(mean_Y0 = mean(Y0))

# If civic_culture were observable, we could match or control for it directly
# (as in module 04). But it usually isn't. What we often DO have is
# repeated observations of the same units over time -- and that's where DiD comes in.


## 3. Adding a time dimension -------------------------------------------------

# Suppose we observe each county in two periods: before and after some counties
# adopt AVR. Treatment "turns on" between periods for treated counties.
#
# There's also a time trend: turnout rises on average 2 pp between periods
# regardless of AVR (e.g., a higher-salience election year), but this trend
# varies by county just as the treatment effect does.
time_trend <- rnorm(n, mean = 2, sd = 1)

df_panel <- bind_rows(
  # Post-period: same as df
  df |> mutate(
    time        = 1,
    treat_group = Treated,
    turnout     = ifelse(Treated == 1, Y1, Y0)
  ),
  # Pre-period: no one is treated yet; we observe Y0 for everyone.
  # Y0 (counterfactual) gains the time trend
  df |> mutate(
    time        = 0,
    treat_group = Treated,  # group membership (will the county eventually adopt AVR?)
    Treated     = 0,         # no one is treated yet
    Y1          = Y1 - time_trend,
    Y0          = Y0 - time_trend,
  ) |>
    mutate(turnout = Y0)
) |>
  arrange(county_id, time)

# True ATT: the average treatment effect among counties that actually adopted AVR.
mean(df$Y1[df$Treated == 1] - df$Y0[df$Treated == 1])

# Now, instead of assuming that treatment is independent of
# potential outcomes (a very strong assumption),
# we can identify the ATT with a much weaker assumption: *parallel trends*


# 4. Visualizaing the parallel trends assumption -------------------------------------------
#
# Plot the potential outcomes to show
# what DiD is actually doing. The counterfactual asks: what would turnout in
# treated counties have looked like had they never adopted AVR?
#
# Parallel trends assumption: that counterfactual trend is the same slope
# as the one we observe for control counties.

att_post <- df_panel |>
  filter(treat_group == 1, time == 1) |>
  summarize(obs = mean(turnout), cf = mean(Y0))


bind_rows(
  df_panel |>
    filter(treat_group == 0) |>
    group_by(time) |>
    summarize(turnout = mean(turnout)) |>
    mutate(series = "Control"),
  df_panel |>
    filter(treat_group == 1) |>
    group_by(time) |>
    summarize(turnout = mean(turnout)) |>
    mutate(series = "Treated (observed)"),
  df_panel |>
    filter(treat_group == 1) |>
    group_by(time) |>
    summarize(turnout = mean(Y0)) |>
    mutate(series = "Treated (counterfactual)")
) |>
  ggplot(aes(x = time, y = turnout, color = series, linetype = series)) +
  geom_line() +
  geom_point(size = 2) +
  annotate("segment",
    x = 1.05, xend = 1.05,
    y = att_post$cf, yend = att_post$obs,
    color = "black",
    arrow = arrow(ends = "both", length = unit(0.08, "inches"), type = "closed")
  ) +
  annotate("label",
    x = 1.07, y = (att_post$obs + att_post$cf) / 2,
    label = paste0("ATT \u2248 ", round(att_post$obs - att_post$cf, 1), " pp"),
    hjust = 0, size = 3, label.size = 0
  ) +
  scale_x_continuous(breaks = c(0, 1), labels = c("Pre", "Post"), limits = c(0, 1.3)) +
  scale_color_manual(
    values = c("Control"                  = "#E69F00",
               "Treated (observed)"       = "#0072B2",
               "Treated (counterfactual)" = "#0072B2")
  ) +
  scale_linetype_manual(
    values = c("Control"                  = "solid",
               "Treated (observed)"       = "solid",
               "Treated (counterfactual)" = "dashed")
  ) +
  labs(x = NULL, y = "Mean Voter Turnout (%)", color = NULL, linetype = NULL)

# The ATT is the vertical gap between the two treated lines in the post period.
# The parallel trends assumption is visible as the equal slopes of the
# control and counterfactual lines.


## 5. Difference-in-differences -------------

# We cannot directly compute the ATT, because we do not observe
# the counterfactual E(Y0[Treated==1]).

# The average post-treatment outcome in the control group
# is a bad counterfactual, for reasons we've discussed.
# And the average pre-treatment outcome in the treated group
# is a bad counterfactual, because it ignores the time trend.

# But, if we're willing to assume parallel trends,
# we can estimate the counterfactual outcome with things
# we *do* observe
did_table <- df_panel |>
  group_by(treat_group, time) |>
  summarize(mean_turnout = mean(turnout), .groups = "drop")
did_table

# the "difference in difference" estimator
# tells us how much more the outcome in the
# treated group increased
# than the outcome in the control group.

## 6. Estimating the ATT with TWFE ---------------

# Under parallel trends, the ATT can be estimated with a two-way fixed effects regression:
#
#   Y_it = alpha_i + lambda_t + tau * D_it + epsilon_it
#
# Unit FEs (alpha_i) absorb time-invariant differences between groups (selection bias);
# time FEs (lambda_t) absorb the common time trend. The coefficient tau on D_it is the
# ATT estimate. In the 2x2 case, it is algebraically identical to the manual DiD
# calculation below.

library(fixest)

twfe <- feols(turnout ~ Treated | county_id + time, data = df_panel)
summary(twfe)

# The coefficient on Treated should match the 2x2 DiD estimate:
did_table |>
  group_by(treat_group) |>
  summarize(time_diff = diff(mean_turnout)) |>
  summarize(did_estimate = diff(time_diff))


## 7. What if parallel trends is violated? ------------------------------------
#
# Parallel trends is untestable in the post-period: we never observe the
# treated group's counterfactual after treatment turns on. But with multiple
# pre-treatment periods, we can check whether the groups were already trending
# differently *before* treatment. This is testing for pretrends.
#
# Here we re-simulate with a violated assumption: counties with stronger civic
# culture (the treated group) also see faster turnout growth, independent of AVR.

civic_slope <- 0.15  # extra pp growth per unit of civic culture per period

# Multi-period panel: t = -3 through t = 2; AVR turns on at t = 0.
# Y0 from the original simulation serves as each county's fixed baseline level.
df_viol <- map_dfr(-3:2, function(t) {
  df |>
    transmute(
      county_id,
      civic_culture,
      treat_group  = Treated,
      time         = t,
      treat_active = as.integer(Treated == 1 & t >= 0),
      # Counterfactual: unit baseline + common time trend + differential civic trend
      Y0_t    = Y0 + t * 2 + t * civic_slope * civic_culture,
      turnout = Y0_t + treat_active * tau
    )
})

# Visualize: are the groups trending in parallel before treatment?
df_viol |>
  group_by(treat_group, time) |>
  summarize(mean_turnout = mean(turnout), .groups = "drop") |>
  mutate(Group = ifelse(treat_group == 1, "Treated", "Control")) |>
  ggplot(aes(x = time, y = mean_turnout, color = Group)) +
  geom_line() +
  geom_point(size = 2) +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
  scale_color_manual(values = c("Control" = "#E69F00", "Treated" = "#0072B2")) +
  labs(x = "Period (0 = treatment onset)", y = "Mean Turnout (%)", color = NULL,
       caption = "Dashed line: treatment begins at t = 0")

# Treated counties are already growing faster before treatment -- the
# slopes are not parallel. TWFE will confound the policy effect with
# the differential trend.

# TWFE estimate on the violated data
twfe_viol <- feols(turnout ~ treat_active | county_id + time, data = df_viol)
summary(twfe_viol)

# True ATT (known from the simulation)
mean(tau[Treated == 1])

# 7a. A possible remedy: unit-specific linear trends --------------------------
#
# If the violation is driven by groups following different *linear* trends,
# we can control for unit-specific linear slopes in time. In fixest, the
# notation county_id[time] adds a separate slope in time for each county.
#
# Caveat: this only helps if the differential trend is approximately linear,
# and it trades bias reduction for increased variance (n extra parameters).

twfe_trends <- feols(turnout ~ treat_active | county_id + time + county_id[time],
                     data = df_viol)
summary(twfe_trends)

# The estimate should recover something close to the true ATT (~4 pp).


## 8. Staggered adoption: Callaway & Sant'Anna --------------------------------
#
# In practice, units often adopt treatment at different times (staggered
# adoption). TWFE handles this by collapsing everything into a single
# treatment dummy -- but it implicitly uses already-treated units as controls
# for later adopters. When treatment effects vary across cohorts, these
# "forbidden comparisons" produce negative weights and a biased estimate.
#
# Callaway & Sant'Anna (2021) avoids this by estimating cohort-specific
# ATTs ("group-time ATTs") using only clean controls -- never-treated or
# not-yet-treated units -- then aggregating in a transparent way.

set.seed(6174)

# Assign counties to three cohorts by civic culture tertiles.
# G = first period of treatment; G = 0 means never treated.
G <- case_when(
  civic_culture > quantile(civic_culture, 2/3) ~ 3,   # early adopters: treated at t=3
  civic_culture > quantile(civic_culture, 1/3) ~ 6,   # late adopters:  treated at t=6
  TRUE                                          ~ 0    # never treated
)

# Heterogeneous effects: high-civic-culture counties benefit more from AVR.
# Early adopters get a large boost (~10 pp); late adopters a modest one (~1 pp).
tau_stag <- case_when(
  G == 3 ~ rnorm(n, mean = 10, sd = 2),
  G == 6 ~ rnorm(n, mean = 1,  sd = 2),
  TRUE   ~ 0
)

# True ATTs -- known because we built the simulation
mean(tau_stag[G == 3])  # early adopters: ~10 pp
mean(tau_stag[G == 6])  # late adopters:  ~1 pp
(sum(tau_stag[G == 3]) + sum(tau_stag[G == 6])) / sum(G > 0)  # overall ATT: ~5.5 pp

# Multi-period panel: 8 periods; treatment turns on at each county's G
df_stag <- map_dfr(1:8, function(t) {
  df |>
    transmute(
      county_id,
      G            = G,
      time         = t,
      treat_active = as.integer(G > 0 & t >= G),
      turnout      = Y0 + (t - 1) * 2 + treat_active * tau_stag
    )
})


# 8a. TWFE on staggered data: biased -------------------------------------

twfe_stag <- feols(turnout ~ treat_active | county_id + time, data = df_stag)
summary(twfe_stag)

# Compare TWFE estimate to the true overall ATT -- it will be off.
# With early adopters getting ~10 pp and late adopters ~1 pp, TWFE averages
# across all 2x2 comparisons, including periods where early adopters
# (already treated) serve as controls for late adopters. Those comparisons
# get negative implicit weights, pulling the estimate noticeably downward.


# 8b. Callaway & Sant'Anna estimator -----------------------------------------

library(did)

cs <- att_gt(
  yname  = "turnout",
  tname  = "time",
  idname = "county_id",
  gname  = "G",   # first treatment period; 0 = never treated
  data   = df_stag
)

# By cohort: recover the true group-specific effects
cs_group <- aggte(cs, type = "group")
cs_group

ggdid(cs_group) +
  labs(x = "ATT estimate (pp)", y = "Year of Treatment")


# Dynamic (event-study) aggregation: ATT by periods since treatment onset
cs_dyn <- aggte(cs, type = "dynamic")
ggdid(cs_dyn) +
  labs(x = "Periods since treatment", y = "ATT estimate (pp)")

# C&S correctly recovers the cohort-specific ATTs and the overall ATT.
# The key: each group-time cell is estimated against clean controls only,
# so no forbidden comparisons, no negative weights.
