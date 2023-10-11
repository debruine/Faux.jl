# Tutorial

```@example Main
using Faux # for data simulation (under development!)
using DataFrames # for data wrangling
using CairoMakie # for plots
import Random
using GLM # to calculate regression lines (why doesn't Makie do this?)

rng = Random.seed!(8675309); # make randomness predictable :)
```

## Simulate by Design

By default, `sim_design()` gives you a data frame with n = 100 observations of a single normally distributed variable called `y`, with mean = 0 and sd = 1. Here, we will simulate smaller n to make tables easier to see.

```@example Main
df = sim_design(n = 5)
```

You can change the name of the dependent variable or the id column.

```@example Main
df = sim_design(n = 5, dv = "score", id = "subj")
```

You can add between-subject variables.

```@example Main
b = ["pet" => ["dog", "cat"]]
df = sim_design(n = 3, between = b)
```

And within-subject variables.

```@example Main
w = ["cond" => ["ctl", "exp"]]
df = sim_design(n = 3, within = w)
```

You can return a long version of your data.

```@example Main
df = sim_design(n = 3, within = w, long = true)
```

Set the means, standard deviations, and correlations. Set `empirical = true` to set the sample parameters, rather than the population parameters.

```@example Main
b = ["pet" => ["dog", "cat"]]
w = ["cond" => ["ctl", "exp1", "exp2"]]
mu = Dict("dog" => Dict("ctl" => 10, "exp1" => 20, "exp2" => 30),
          "cat" => Dict("ctl" => 40, "exp1" => 50, "exp2" => 60))
sd = Dict("cat" => Dict("exp1" => 5, "exp2" => 6, "ctl" => 4),
          "dog" => Dict("ctl" => 1, "exp1" => 2, "exp2" => 3))
r = Dict("dog" => [.1, .2, .3],
         "cat" => [.4, .5, .6])

df = sim_design(n = 5, within = w, between = b,
                 mu = mu, sd = sd, r = r,
                 empirical = true)
```


```@example Main
dogs = filter(row -> row.pet == "dog", df)
get_params(dogs)
```


```@example Main
cats = filter(row -> row.pet == "cat", df)
get_params(cats)
```


```@example Main
df = sim_design(n = 1000,
                within = ["axis" => ["x", "y"]], 
                mu = [0, 100], 
                sd = [1, 10],
                r = 0.5);

# ugh, I want ggplot2 :(
f = Figure()
hist(f[1,1], df.x)
hist(f[1,2], df.y)
scatter(f[2,1],df.x, df.y, alpha = 0.25)
m = GLM.lm(@formula(y ~ x), df)
ablines!(f[2,1], coef(m)...)
f

```