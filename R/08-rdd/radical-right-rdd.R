# replicate and extend Abou-Chadi & Krause (2018)

library(tidyverse)

df <- read_tsv('data/rrp_rdd.tab')

ggplot(data = df,
       mapping = aes(x = er.v.c_l,
                     y = multic.logit_fd)) +
  geom_point() +
  geom_vline(xintercept = 0, linetype = 'dashed') +
  theme_minimal()


library(rdrobust)

mod <- rdrobust(y = df$multic.logit_fd,
                x = df$er.v.c_l,
                c = 0)

summary(mod)

## balance tests ------

# are the 10 observations on the right broadly similar to
# the 24 observations on the left?

load('data/rrp_rdd_wrangled.RData')

ggplot(data = df,
       mapping = aes(x = ack_x,
                     y = cultposition_lowe_lag)) +
  geom_point() +
  geom_vline(xintercept = 0, linetype = 'dashed') +
  theme_minimal() +
  labs(x = 'Radical Right Vote Share Relative to Cutoff',
       y = 'Cultural Protectionism (Previous Election)')

mod <- rdrobust(y = df$cultposition_lowe_lag,
                x = df$ack_x,
                c = 0,
                h = 1.071)

summary(mod)


mod <- rdrobust(y = df$gdp_per_capita_ppp,
                x = df$ack_x,
                c = 0)

summary(mod)

mod <- rdrobust(y = df$migrant_stock_interpolated,
                x = df$ack_x,
                c = 0)

summary(mod)

# note that "do we fail to reject the null hypothesis?" is not an
# adequate test here. Instead, the researcher should provide
# sufficient evidence to conclude that these covariates do not
# differ significantly between treated and control groups.
# Hartman & Hidalgo suggest using "equivalence tests".


## Placebo Tests ---------------------


mod <- rdrobust(y = df$cultposition_lowe_change,
                x = df$ack_x,
                c = 3)

summary(mod)

mod <- rdrobust(y = df$cultposition_lowe_change,
                x = df$ack_x,
                c = -1)

summary(mod)

