set.seed(1908)
N <- 2e3 # number of pairs

# first three variables to simulate are variables
# that are not caused by anything else in the DAG
# these are the *exogenous* variables

U <- rnorm(N) # simulate unobserved confounders

# birth order and family sizes
B1 <- rbinom(N,size=1,prob=0.5) # 50% first borns
B2 <- rbinom(N,size=1,prob=0.5)

# simulate the *endogenous* variables
M <- rnorm( N , 2*B1 + U + 5.1 )
# mom's family size has ZERO effect on daughter's family size
D <- rnorm( N , 2*B2 + U + 1*M + 5.1) # change the 0 to turn on causal influence of mom


## first, always, I suggest making graphs
library(tidyverse)
ggplot(mapping = aes(x = D,
                     y = M)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = 'lm') +
  labs(x = 'Mom Family Size', y = 'Daughter Family Size')

# the most basic linear regression
lm1 <- lm(D ~ M)
summary(lm1)

# causal salad
lm2 <- lm(D ~ M + B1 + B2)
summary(lm2)

# can matching rescue us?
df <- data.frame(M, D, B1, B2)
ggplot(data = df,
       mapping = aes(x = D,
                     y = M)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = 'lm') +
  labs(x = 'Mom Family Size', y = 'Daughter Family Size') +
  facet_grid(B1 ~ B2)
# no. sorry.



# option 3. instrumental variables estimator

b <- cov(M, B1) / var(B1)
b

# estimate the effect of M on D (see whiteboard for derivation)
# or McElreath's article :-D
m <- cov(B1, D) / cov(M, B1)
m
