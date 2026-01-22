## Mediators: Direct and Indirect Effects


# we think that parent's education influences their kid's SES,
# but mostly by increasing the parent's SES

# P_Educ -> P_SES
# P_Educ -> K_SES
# P_SES -> K_SES

N <- 1e4 # create ten thousand parent-kid combos
parent_education <- rnorm(N)
parent_ses <- parent_education + rnorm(N)

# kid's SES is some combination of
# (1) the *direct* effect of parent's education
# (2) the *indirect* effect of parent's education through SES
kid_ses <- 0.5*parent_education + 3*parent_ses + rnorm(N)

# if I wanted to estimate the *total* effect of parent's education
# on kid's SES, what would I do?
lm(kid_ses ~ parent_education)

# if I want just the *direct* effect of parent's education
# on kid's SES, how do I estimate it?
lm(kid_ses ~ parent_education + parent_ses)


