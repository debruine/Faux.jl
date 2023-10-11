var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = Faux","category":"page"},{"location":"#Faux","page":"Home","title":"Faux","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for Faux.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [Faux]","category":"page"},{"location":"#Faux.rep_len-Tuple{Any, Any}","page":"Home","title":"Faux.rep_len","text":"rep_len(x, len)\n\nRepeat a value or vector to create a vector of specified length\n\nArguments\n\nx: The value or vector to repeat\nlen: The length of the resulting vector\n\nExamples\n\njulia> rep_len(1, 3)\n[1, 1, 1]\njulia> rep_len(1:2, 3)\n[1, 2, 1]\njulia> rep_len([1,2,3], 2)\n[1,2]\n\n\n\n\n\n","category":"method"},{"location":"#Faux.rnorm_multi-Tuple{}","page":"Home","title":"Faux.rnorm_multi","text":"rnorm_multi(n = 100, vars = 1, mu = 0, sd = 1, r = 0, \n            varnames = \"X\", \n            empirical = false,\n            as_matrix = false)\n\nMake normally distributed vectors with specified relationships.\n\nArguments\n\n@n: the number of samples required\n@vars: the number of variables to return\n@mu: a vector giving the means of the variables (numeric vector of length 1 or vars)\n@sd: the standard deviations of the variables (numeric vector of length 1 or vars)\n@r: the correlations among the variables (can be a single number, varsvars matrix, varsvars vector, or a vars*(vars-1)/2 vector)\n@varnames: optional names for the variables (string vector of length vars) defaults if r is a matrix with column names\n@empirical: logical. If true, mu, sd and r specify the empirical not population mean, sd and covariance \n@as.matrix: logical. If true, returns a matrix\n\nExamples\n\njulia> tovector(1) == [1]\njulia> tovector(1) != 1\njulia> tovector(1:3) == [1,2,3]\n\n\n\n\n\n","category":"method"},{"location":"#Faux.select_by_type","page":"Home","title":"Faux.select_by_type","text":"select_by_type(df)\n\nSelect columns from a DataFrame of a specific type\n\nArguments\n\ndf: The DataFrame\ntype: The type of column to select\n\nExamples\n\njulia> df = DataFrame(s = [\"A\", \"B\"], \n                      i = [1,2], \n                      n = [1.1, 2.2], \n                      b = [true, false]);\njulia> select_by_type(df)\njulia> select_by_type(df, Int64)\njulia> select_by_type(df, String)\njulia> select_by_type(df, Bool)\n\n\n\n\n\n","category":"function"},{"location":"#Faux.sim_design-Tuple{}","page":"Home","title":"Faux.sim_design","text":"sim_design(within = [], \n           between = [], \n            n = 100, mu = 0, sd = 1, r = 0, \n            empirical::Bool = false, \n            long::Bool = false, \n            dv::String = \"y\", \n            id::String = \"id\",\n            vardesc::Dict = Dict(),\n            sep::String = \"_\",\n            rep::Int64 = 1)\n\nSimulate data from design\n\nGenerates a data table with a specified within and between design. \n\nArguments\n\nwithin: an array of Pairs for the within-subject factors\nbetween: an array of Pairs for the between-subject factors\nn: the number of samples required per between-subject cell\nmu: the means of the variables\nsd: the standard deviations of the variables\nr: the correlations among the variables (can be a single number, full correlation matrix as a matrix or vector, or a vector of the upper right triangle of the correlation matrix\nempirical: if true, mu, sd and r specify the empirical not population mean, sd and covariance \nlong: Whether the returned tbl is in wide or long format (defaults to value of faux_options(\"long\"))\ndv: the name of the dv column for long plots (defaults to y)\nid: the name of the id column (defaults to id)\nvardesc: a Dict of variable descriptions having the names of the within- and between-subject factors\nrep: the number of data frames to simulate (default 1); if greater than 1, the returned data frame contains a rep column\nsep: separator for factor levels\n\nExamples\n\njulia> using Faux, DataStructures\njulia> b = [\"condition\" => [\"ctl\", \"exp\"]]\njulia> w = [\"version\" => [\"A\", \"B\"]]\njulia> df = sim_design(within = w, between = b, n = 10)\n\n\n\n\n\n","category":"method"},{"location":"#Faux.tovector-Tuple{Any}","page":"Home","title":"Faux.tovector","text":"tovector(x)\n\nConvert a UnitRange or single value to a vector\n\nArguments\n\nx: The value to convert\n\nExamples\n\njulia> tovector(1)\n[1]\njulia> tovector(1:3)\n[1,2,3]\n\n\n\n\n\n","category":"method"},{"location":"tutorial/#Tutorial","page":"Tutorial","title":"Tutorial","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"using Faux # for data simulation (under development!)\nusing DataFrames # for data wrangling\nusing CairoMakie # for plots\nimport Random\nusing GLM # to calculate regression lines (why doesn't Makie do this?)\n\nrng = Random.seed!(8675309); # make randomness predictable :)","category":"page"},{"location":"tutorial/#Simulate-by-Design","page":"Tutorial","title":"Simulate by Design","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"By default, sim_design() gives you a data frame with n = 100 observations of a single normally distributed variable called y, with mean = 0 and sd = 1. Here, we will simulate smaller n to make tables easier to see.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"df = sim_design(n = 5)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"You can change the name of the dependent variable or the id column.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"df = sim_design(n = 5, dv = \"score\", id = \"subj\")","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"You can add between-subject variables.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"b = [\"pet\" => [\"dog\", \"cat\"]]\ndf = sim_design(n = 3, between = b)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"And within-subject variables.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"w = [\"cond\" => [\"ctl\", \"exp\"]]\ndf = sim_design(n = 3, within = w)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"You can return a long version of your data.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"df = sim_design(n = 3, within = w, long = true)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Set the means, standard deviations, and correlations. Set empirical = true to set the sample parameters, rather than the population parameters.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"b = [\"pet\" => [\"dog\", \"cat\"]]\nw = [\"cond\" => [\"ctl\", \"exp1\", \"exp2\"]]\nmu = Dict(\"dog\" => Dict(\"ctl\" => 10, \"exp1\" => 20, \"exp2\" => 30),\n          \"cat\" => Dict(\"ctl\" => 40, \"exp1\" => 50, \"exp2\" => 60))\nsd = Dict(\"cat\" => Dict(\"exp1\" => 5, \"exp2\" => 6, \"ctl\" => 4),\n          \"dog\" => Dict(\"ctl\" => 1, \"exp1\" => 2, \"exp2\" => 3))\nr = Dict(\"dog\" => [.1, .2, .3],\n         \"cat\" => [.4, .5, .6])\n\ndf = sim_design(n = 5, within = w, between = b,\n                 mu = mu, sd = sd, r = r,\n                 empirical = true)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"dogs = filter(row -> row.pet == \"dog\", df)\nget_params(dogs)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"cats = filter(row -> row.pet == \"cat\", df)\nget_params(cats)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"df = sim_design(n = 1000,\n                within = [\"axis\" => [\"x\", \"y\"]], \n                mu = [0, 100], \n                sd = [1, 10],\n                r = 0.5);\n\n# ugh, I want ggplot2 :(\nf = Figure()\nhist(f[1,1], df.x)\nhist(f[1,2], df.y)\nscatter(f[2,1],df.x, df.y, alpha = 0.25)\nm = GLM.lm(@formula(y ~ x), df)\nablines!(f[2,1], coef(m)...)\nf\n","category":"page"}]
}