# Clustered Standard Errors (The Parable of The Bunny Races)



library(tidyverse)

set.seed(42)

# 10 bunnies get carrots
# 10 bunnies don't get carrots

# spoiler alert: carrots don't matter
bunnies <- tibble(
  bunny_id = 1:20,
  carrot = c(rep(0, 10),
             rep(1, 10)),
  race_time = rnorm(n = 20,
                    mean = 10,
                    sd = 2)
)

bunnies |>
  mutate(carrot = factor(carrot)) |>
  ggplot(mapping = aes(x=carrot,
                       y=race_time)) +
  geom_jitter(alpha = 0.5,
              width = 0.1) +
  theme_bw() +
  labs(x = 'Carrot?',
       y = 'Race Time')

lm1 <- lm(race_time ~ carrot, data = bunnies)
# not statistically significant :-(

summary(lm1)

# wait a minute.....
# what if *bunny* isn't the unit of observation?
# what if bunny foot is the unit of observation?

# I've quadrupled my sample size!

bunny_feet <- bunnies |>
  # two hind legs
  bind_rows(bunnies |>
              mutate(race_time = race_time + 0.1)) |>
  bind_rows(bunnies |>
              mutate(race_time = race_time + 0.1)) |>
  bind_rows(bunnies)

bunny_feet |>
  mutate(carrot = factor(carrot)) |>
  ggplot(mapping = aes(x=carrot,
                       y=race_time)) +
  geom_jitter(alpha = 0.5,
              width = 0.1) +
  theme_bw() +
  labs(x = 'Carrot?',
       y = 'Race Time')

lm2 <- lm(race_time ~ carrot, data = bunny_feet)

summary(lm2)

# why is this cheating?

# because the residual for bunny foot 1 is almost perfectly correlated with the
# residual for bunny foot 2!
# they are not *independent* of one another, like we assume with vanilla standard errors


# so we *cluster* our standard errors, to let R know that some observation's
# residuals will be more strongly correlated than others.

library(estimatr)

lm3 <- lm_robust(race_time ~ carrot,
                 data = bunny_feet,
                 clusters = bunny_id)

summary(lm3)

# notice that the standard error is identical to...
summary(lm1)
