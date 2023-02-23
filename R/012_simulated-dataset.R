## Estimate the average treatment effect on a simulated dataset

library(tidyverse)

load('data/simulated_dataset.RData')


lm1 <- lm(Y~Tr, data = data)
summary(lm1)


lm2 <- lm(Y ~ Tr + X1 + X2, data = data)
summary(lm2)



library(Matching)

X <- cbind(data$X1, data$X2) # here's a matrix with the confounders

m <- Match(Y = data$Y,
           Tr = data$Tr,
           X = X)


# did we do a good job matching?

# here's the balance on the unmatched dataset
data |>
  group_by(Tr) |>
  summarize(mean_X1 = mean(X1),
            mean_X2 = mean(X2))

# instead of just looking at means, we can look at the entire distribution
ggplot(data = data,
       mapping = aes(x=X1, fill = factor(Tr))) +
  geom_histogram(color = 'black')

ggplot(data = data,
       mapping = aes(x=X2, fill = factor(Tr))) +
  geom_histogram(color = 'black')


# now compare treated group with matched control group
data_treated <- data[m$index.treated,]
data_control <- data[m$index.control,]
data_matched <- bind_rows(data_treated, data_control)

data_matched |>
  group_by(Tr) |>
  summarize(mean_X1 = mean(X1),
            mean_X2 = mean(X2))

# instead of just looking at means, we can look at the entire distribution
ggplot(data = data_matched,
       mapping = aes(x=X1, fill = factor(Tr))) +
  geom_density(color = 'black', alpha = 0.2)

ggplot(data = data_matched,
       mapping = aes(x=X2, fill = factor(Tr))) +
  geom_density(color = 'black')

# I'm satisfied with my balance, so....

summary(m)


# Why did regression do so poorly?

ggplot(data = data,
       mapping = aes(x=X1, y = Y, color = factor(Tr))) +
  geom_point()

ggplot(data = data,
       mapping = aes(x=X2, y = Y, color = factor(Tr))) +
  geom_point()


# what if we add polynomial terms?
lm3 <- lm(Y ~ Tr + X1 + I(X1^2) + I(X1^3) + X2 + I(X2^2) + I(X2^3),
          data = data)
summary(lm3)

# regression got a bit of a handicap here, because I literally used
# quadratic/cubic functions to generate the data, so
# lm3 matched the data generating process exactly.
