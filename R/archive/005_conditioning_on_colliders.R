# Conditioning on colliders


# I'm interested in whether parents being highly educated
# causes their kids to be highly educated

# simulate 10,000 pairs of parents and kids
N <- 10000

parents_education <- rnorm(N)

# parent's education DOESN'T cause kids' education
kids_education <- 0*parents_education + rnorm(N)

# parents who are more educated have higher SES
parents_ses <- parents_education + rnorm(N)

# kids inherit money
kids_ses <- parents_ses + kids_education + rnorm(N)


# if I wanted to estimate the effect of parents_education on kids_education,
# then this is all I need
lm(kids_education ~ parents_education)

# would it hurt if I conditioned on parents' SES?
lm(kids_education ~ parents_education + parents_ses)


# would it hurt if I conditioned on kid's SES?
summary(lm(kids_education ~ parents_education + kids_ses))


