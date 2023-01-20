## is 30 observations enough data?
## spoiler alert: depends on your question

library(tidyverse)

truth <- rnorm(1e6, 0, 1)

hist(truth)

ggplot(mapping = aes(x=truth)) +
  geom_density()


# but I don't have the money to talk to all 1 million people,
# so I'm just going to interview 30.

data <- sample(truth, size = 30, replace = FALSE)

ggplot() +
  geom_density(mapping = aes(x=truth), color = 'black') +
  geom_density(mapping = aes(x=data), color = 'red')

# if you're interested in the theoretical distribution,
# then 30 is no guarantee that you'll get a good sense of it.

# the thing that 30 does is makes your *sampling distribution*
# approximately normally distributed

sampling_distribution <- replicate(10000,
                                   mean(sample(truth, size = 30,
                                               replace = FALSE)))

ggplot(mapping = aes(x=sampling_distribution)) +
  geom_density()

# so....30 is okay if the only thing you care about is
# estimating the population mean.

# if you want to know more than that, you probably need more data.


