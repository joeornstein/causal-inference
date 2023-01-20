## Simulate data where moms have daughters
## and we want to know if mom's family size
## causes daughter's family size

set.seed(42) # set the random seed so that we get the same random data


N <- 20000 # number of pairs


U <- rnorm(N) # simulate confounds

# birth order and family sizes
B1 <- rbinom(N,size=1,prob=0.5) # 50% first borns

M <- rnorm( N , 2*B1 + U ) # first-born moms have more kids on average, and so do moms with high values of U

B2 <- rbinom(N,size=1,prob=0.5)

# mom's family size has ZERO effect on daughter's family size
D <- rnorm( N , 2*B2 + U + 0*M ) # change the 0 to turn on causal influence of mom


# So, if I were to naively estimate the effect of M on D
library(tidyverse)
ggplot(mapping = aes(x=M, y=D)) +
  geom_point() +
  geom_smooth(method = 'lm')


lm1 <- lm(D ~ M) # the gluttony lm didn't work
summary(lm1)

lm2 <- lm(D ~ M + B1 + B2) # the greedy garbage can model worked even worse!
summary(lm2)


#
b <- cov(B1, M) / var(B1) # first stage of the instrumental variables estimation
m <- cov(B1, D) / var(B1) / b # second stage of 2sls
m
