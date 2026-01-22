## THIS IS A BONUS SCRIPT

# Playing around with part 3 from Richard McElreath's
# series of blog posts:
# https://elevanth.org/blog/2021/06/29/regression-fire-and-dangerous-things-3-3/

# In part 1, we showed that the Causal Salad OLS
# does not recover your parameter of interest

# In part 2, we used the causal model (DAG) to think about
# a statistical estimator that *would* produce the
# parameter of interest

# In part 3, we say "why not just use the causal model itself
# to produce our estimates?"


## Step 1: Simulate the data ----------------

set.seed(42) # set the random seed so that we get the same random data


N <- 20000 # number of pairs


U <- rnorm(N) # simulate confounds

# birth order and family sizes
B1 <- rbinom(N,size=1,prob=0.5) # 50% first borns

M <- rnorm( N , 2*B1 + U ) # first-born moms have more kids on average, and so do moms with high values of U

B2 <- rbinom(N,size=1,prob=0.5)

# mom's family size has ZERO effect on daughter's family size
D <- rnorm( N , 2*B2 + U + 0*M ) # change the 0 to turn on causal influence of mom


## Step 2: Express the causal model as a joint probability distribution  ----------------------

# full-luxury bayesian inference
library(rethinking)
library(cmdstanr)
dat <- list(N=N,M=M,D=D,B1=B1,B2=B2)
set.seed(1908)
flbi <- ulam(
  alist(
    # mom model
    M ~ normal( mu , sigma ),
    mu <- a1 + b*B1 + k*U[i],
    # daughter model
    D ~ normal( nu , tau ),
    nu <- a2 + b*B2 + m*M + k*U[i],
    # B1 and B2
    B1 ~ bernoulli(p),
    B2 ~ bernoulli(p),
    # unmeasured confound
    vector[N]:U ~ normal(0,1),
    # priors
    c(a1,a2,b,m) ~ normal( 0 , 0.5 ),
    c(k,sigma,tau) ~ exponential( 1 ),
    p ~ beta(2,2)
  ), data=dat , chains=4 , cores=4 , iter=2000 , cmdstan=TRUE )

