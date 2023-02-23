# Regression does this


mtcars

# what's the effect of manual transmission on fuel efficiency?

lm1 <- lm(mpg ~ am, data = mtcars)
summary(lm1)


# are manual transmission cars heavier?
lm2 <- lm(wt ~ am, data = mtcars)
summary(lm2)
# no, they're a bit lighter....

# are heavier cars more fuel efficient?
lm3 <- lm(mpg ~ wt, data = mtcars)
summary(lm3)
# very much no. heavier cars, on average, are less fuel efficient.


# we have to condition on this thing somehow....

# we're trained to just add it to the model:
lm4 <- lm(mpg ~ wt + am, data = mtcars)
summary(lm4)

## So what the heck did we just do there?



# first thing we do is predict whether or not a car will be automatic or manual
# based on its weight
lm5 <- lm(am ~ wt, data = mtcars)
summary(lm5)

# save the residuals
lm5$residuals

am_residuals <- lm5$residuals

# the next thing I'll do is predict the gas mileage of cars based on their weight
# good news: i did that in lm3
mpg_residual <- lm3$residuals

# now, I'm interested in this question:
# do the cars where I'm surprised that it's a manual given its weight
# also have higher gas mileage than I would expect given its weight?
lm(mpg_residual ~ am_residuals)

# are we surprised by the relationship that's left over after we
# take out all of the predictions based on everything else we know?


# that's regression

# but there's a problem.....
# (non-overlapping covariates)
View(mtcars)

# notice that there are basically no light cars that are automatics
# and basically no heavy cars that are manuals
# and so regression is basing its conclusions off a small slice of the data
# (but we would never know that if we didn't LOOK AT THE DATA)

library(ggplot2)


ggplot(data = mtcars,
       mapping = aes(x=wt)) +
  geom_histogram() +
  facet_wrap(~am)
# the only place where we have covariate overlap
# is in that 2.5-3.5 wt range.


# what about a matching approach?
library(Matching)

m <- Match(Y = mtcars$mpg,
           Tr = mtcars$am,
           X = as.matrix(mtcars$wt))

# these are the cars in the treatment group
m$index.treated

# these are the cars in the matched control group
m$index.control

# that's a lot of Toyota Coronas!

# could we match without replacement?
m2 <- Match(Y = mtcars$mpg,
           Tr = mtcars$am,
           X = as.matrix(mtcars$wt),
           replace = FALSE)

m2$index.treated

m2$index.control

# on the one hand, great, because we're estimating based on more cars

# on the other hand....let's look at our balance statistics

# average weight in the treatment group
mean( mtcars[m$index.treated,]$wt )

# average weight in the matched control group (with replacement)
mean( mtcars[m$index.control,]$wt )

# average weight in the matched control group (without replacement)
mean( mtcars[m2$index.control,]$wt )

# the first one is not very efficient, because it's all based on
# one Toyota Corona

# the second one is likely biased, because we got more, but worse matches


# note to self: don't look at the results until you're happy with your balance...

# but if you wanted to, here's the code
summary(m) # good balance, but few unique observations

summary(m2) # more efficient, but biased

