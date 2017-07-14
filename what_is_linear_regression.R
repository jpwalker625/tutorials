library(modelr)
library(tidyverse)

sim1

models <- tibble(a1 = runif(250, -20, 40),
                 a2 = runif(250, -5, 5))

ggplot(sim1, aes(x,y)) +
  geom_point() +
geom_abline(data = models, aes(slope = a2, intercept = a1), alpha = 1/4)
