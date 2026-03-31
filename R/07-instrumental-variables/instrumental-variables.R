## Instrumental Variables Tutorial
##
## We build up to 2SLS through a simulated cross-national study of the
## political resource curse: does oil wealth cause political repression?

library(tidyverse)
library(fixest)


## 1. Setup ---------------------------------------------------------------

set.seed(1042)

n <- 500  # countries

# Scenario: we want to estimate the causal effect of oil revenue on
# political repression. Does resource wealth allow authoritarian rulers
# to better fund coercive capacity?
#
# The problem: oil revenue is endogenous. Countries with higher overall
# economic development have better extraction infrastructure, attract
# more foreign energy investment, and consequently generate more oil
# revenue. But development is also independently associated with lower
# repression (modernization theory). Economic development confounds
# the relationship: it pushes oil revenue UP and repression DOWN
# at the same time, making the resource curse hard to see in raw data.

# Unobserved: overall economic development from non-oil sources
# (institutions, human capital, etc.)
development <- rnorm(n, mean = 0, sd = 1)

# True causal effect of oil revenue on repression: positive (resource curse)
# Oil revenue raises repression, on average, by 0.1 points.
true_effect <- 0.1

# Geological oil reserves: exogenous endowment, independent of development.
# Most countries have low reserves; a few are geologically fortunate.
reserves <- rexp(n, rate = 1)

# Oil revenue (expressed as % of GDP, rescaled):
# Driven by geology, but also by how well a state can extract and sell it.
# development -> extraction capacity -> higher revenue (this is the confounder)
oil_revenue <- pmax(
  0.9 * reserves +       # reserves -> revenue
  0.7 * development +    # development -> extraction (CONFOUNDER)
  rnorm(n, mean = 4, sd = 0.9),  # baseline + idiosyncratic noise; mean shifts revenue to ~5% of GDP
  0
)

# Repression index (0 = free, 10 = fully repressive)
# development -> LESS repression
# oil revenue -> MORE repression (resource curse -- what we want to identify)
repression <- pmin(pmax(
  5 - 1.5 * development +
  true_effect * oil_revenue +
  rnorm(n, sd = 1),
  0), 10)

df <- tibble(development, reserves, oil_revenue, repression)

# True ATE -- what IV should recover
true_effect


## 2. The endogeneity problem ---------------------------------------------

# Naive OLS: what does oil revenue appear to do to repression?
feols(repression ~ oil_revenue, data = df) |> summary()

# The estimate is negative -- the opposite of the truth!
# This is the confound at work: development drives oil revenue up and
# repression down simultaneously. A naive regression mistakes this
# correlation for a causal story.
#
# The bias is systematic, not random:
df |>
  mutate(dev_group = ifelse(development > 0, "High development", "Low development")) |>
  group_by(dev_group) |>
  summarize(mean_revenue    = mean(oil_revenue),
            mean_repression = mean(repression))

# High-development countries generate more oil revenue but have less repression.
# OLS reads this as "oil reduces repression" when really both are driven by development.
# We need to isolate the part of oil revenue variation that *isn't* driven by development.

library(ggdag)

# The DAG makes the identification problem concrete.
# Development sits above, creating backdoor paths to both Oil Revenue and Repression.
# Geological Reserves sits to the left -- connected to Oil Revenue but with
# no path to Repression except through Oil Revenue (the exclusion restriction).
dagify(
  oil_rev    ~ reserves + development,
  repression ~ oil_rev  + development,
  latent     = "development",
  exposure   = "oil_rev",
  outcome    = "repression",
  labels = c(
    reserves    = "Geological\nReserves",
    oil_rev     = "Oil\nRevenue",
    repression  = "Political\nRepression",
    development = "Development\n(unobserved)"
  ),
  coords = list(
    x = c(reserves = 0, oil_rev = 1, repression = 2, development = 1.5),
    y = c(reserves = 0, oil_rev = 0, repression = 0, development = 1)
  )
) |>
  ggdag_status(use_labels = "label", text = FALSE) +
  guides(color = "none") +
  theme_dag()


## 3. The instrument: geological oil reserves -----------------------------

# Reserves were laid down by geological processes over millions of years.
# They are not caused by a country's modern institutions, development level,
# or political system. And they affect repression only insofar as they translate
# into actual oil revenue -- not through any direct channel.

# For reserves (Z) to work as an instrument for oil revenue (D),
# three assumptions must be met:
#
#  (1) RELEVANCE: reserves must predict oil revenue.
#      Countries with larger geological endowments generate more revenue.
#      We can (and should) check this directly.
#
#  (2) VALIDITY (exclusion restriction): reserves can only affect repression
#      *through* oil revenue. A country's geological endowment has no direct
#      effect on how repressive its government is -- only through the revenue
#      that endowment enables. This is a substantive argument, not a test.
#
#      Food for thought: How might the exclusion restriction be violated here?
#
#  (3) MONOTONICITY: more reserves should never *reduce* oil revenue for any
#      country. Hard to imagine a violation: more oil underground means more
#      oil to extract, even if a given country can't extract all of it.


## 4. 2SLS by hand -----------------------------------------------------------

# Before using feols(), it may be helpful to walk through
# two stage least squares by hand, to see what's
# going on "under the hood".
# The goal is to isolate the variation in oil revenue that is driven by
# reserves -- the only part free of the development backdoor.

# FIRST STAGE: regress oil revenue on reserves.
# This tests for relevance of the instrument.
first_stage <- feols(oil_revenue ~ reserves, data = df)
summary(first_stage)

ggplot(df, aes(x = reserves, y = oil_revenue)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(x = "Geological Oil Reserves (Z)",
       y = "Oil Revenue (D)",
       title   = "First stage: reserves predict oil revenue",
       subtitle = "IV uses only this variation — purged of the development confound")

# Extract fitted values: the country's oil revenue you would predict if you
# only knew how much reserves it had.
df$oil_revenue_hat <- fitted(first_stage)

# SECOND STAGE: regress repression on the 'uncontaminated' oil revenue values.
# Because oil_revenue_hat is uncorrelated with development by construction,
# its coefficient is free of the backdoor that biased naive OLS.
second_stage <- feols(repression ~ oil_revenue_hat,
                      data = df)
summary(second_stage)

# The coefficient on oil_revenue_hat is our 2SLS estimate: it should be
# positive and close to the true effect (+0.1), unlike the naive OLS estimate.

# One important caveat: the standard errors above are wrong.
# The second stage treats oil_revenue_hat as observed data, ignoring
# the estimation uncertainty carried over from the first stage.
# Always use a dedicated IV estimator for inference -- next section.


## 5. 2SLS with fixest ----------------------------------------------------

# feols() implements IV with:
#   feols(outcome ~ exogenous_controls | endogenous ~ instrument, data)

iv <- feols(repression ~ 1 | oil_revenue ~ reserves, data = df)
summary(iv)

# The 2SLS estimate should be close to the true effect (+0.1).
# Standard errors are larger than OLS -- we are using only the reserves-driven
# slice of oil revenue variation, which is less than the total variation.

# Side-by-side comparison
naive <- feols(repression ~ oil_revenue, data = df)

# "Reduced Form" is the estimated effect of the the instrument on your outcome
reduced_form <- feols(repression ~ reserves, data = df)

etable(naive, reduced_form, iv,
       coefstat = "se",
       dict     = c(oil_revenue = "Oil Revenue",
                    reserves    = "Oil Reserves (Z)",
                    "fit_oil_revenue" = "Oil Revenue (2SLS)"),
       fitstat  = ~ n)

# OLS:          negative (development confounds)
# Reduced form: positive coefficient on reserves (the instrument)
# 2SLS:         positive, close to the true effect of +0.1
#
# The contrast between OLS and 2SLS tells the resource curse story:
# once we remove the variation in oil revenue driven by development
# and retain only the geology-driven variation, oil wealth clearly
# increases political repression.


## 6. Checking the first stage: weak instruments -------------------------

# If reserves barely predicted oil revenue, we'd have a weak instrument problem.
# A weak first stage means we're dividing by something near zero in our
# ratio estimator -- the 2SLS estimate becomes noisy and biased.
#
# Standard check: the first-stage F-statistic. fixest reports it automatically.

summary(iv$iv_first_stage$oil_revenue)

# A strong instrument (F >> 10) gives us confidence that the
# reserves-driven variation in oil revenue is substantial enough to
# work with. Countries differ meaningfully in geological endowment,
# and that difference meaningfully changes their oil revenue.

# Try going back to the simulation setup and see what happens if you
# significantly weaken the effect of reserves on oil revenue.


## 7. LATE: what does the IV estimate identify? --------------------------

# Unlike OLS, which uses all variation in oil revenue, 2SLS uses only the
# variation driven by geological reserves. This has implications for
# *what population* the estimate applies to.
#
# With a continuous treatment and instrument, the LATE framing is:
# IV gives us a weighted average of marginal causal effects, weighted by
# how strongly each country's oil revenue responds to its reserves endowment.
# Countries whose revenue is barely affected by their reserves (low weight)
# contribute little to the estimate; countries whose revenue closely tracks
# their geological endowment (high weight) drive the estimate.

# In this simulation, the first-stage response is linear and homogeneous --
# every country gets the same per-unit bump from reserves. So the IV estimate
# approximates the average treatment effect across the whole sample.
# In real data, the response varies: some countries can't monetize their
# reserves (sanctions, weak state, conflict), others can. IV would then
# identify the resource curse specifically for countries where reserves
# actually translate into revenue.

# We can illustrate the LATE weighting from the simulation.
# Define each country's "first-stage weight" as how much an additional
# unit of reserves would shift its oil revenue -- in a linear model,
# this is constant, but we can still verify the intuition.
df <- df |>
  mutate(
    # In the linear simulation, the first-stage shift is the same for all units.
    # With a nonlinear or heterogeneous first stage, this would vary.
    fs_weight = coef(first_stage)["reserves"]
  )

# The IV estimate is a weighted average of tau:
# Since weight is constant here, LATE ≈ ATE ≈ true_effect
weighted.mean(rep(true_effect, n), df$fs_weight)

# In practice, the LATE vs. ATE distinction matters when:
#   (a) Not all countries with reserves can monetize them
#   (b) The resource curse effect varies across countries
#       (e.g., stronger in countries with weak institutions)
# IV would then give us the effect specifically for countries
# where geology shapes revenue -- which may not be the same as
# the effect for countries where revenue comes from other sources.