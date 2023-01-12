
# create objects like this

a <- 1
b <- 2


# then you can do stuff with the objects

a + b


# and you can create new objects from the stuff you do to objects

c <- a + b
d <- a^2


# functions work like this

sqrt(a)

c <- sqrt(a^2 + b^2)


# you can create vectors (aka lists) with the c() function

my_vector <- c(0,2,5,1,2)

my_vector

# and you can also apply functions to vectors

my_vector + 1
sum(my_vector)
mean(my_vector)


# library() function imports a package,
# which contains functions and objects that other people created

library(tidyverse)



# dataframes are a bunch of vectors squished together

mtcars

# this is the list of all the cars' mpg
mtcars$mpg


# you can apply functions to dataframes too.
# separate multiple inputs with commas
filter(mtcars, mpg < 15)


# pipes are useful for applying multiple functions one
# after another
mtcars |>
  filter(mpg < 15) |>
  select(mpg, cyl)


















