using DataFrames

"""
    sim_design(within = [], 
               between = [], 
                n = 100, mu = 0, sd = 1, r = 0, 
                empirical::Bool = false, 
                long::Bool = false, 
                dv::String = "y", 
                id::String = "id",
                vardesc::Dict = Dict(),
                sep::String = "_",
                rep::Int64 = 1)

Simulate data from design

Generates a data table with a specified within and between design. 

# Arguments
* `within`: an array of Pairs for the within-subject factors
* `between`: an array of Pairs for the between-subject factors
* `n`: the number of samples required per between-subject cell
* `mu`: the means of the variables
* `sd`: the standard deviations of the variables
* `r`: the correlations among the variables (can be a single number, full correlation matrix as a matrix or vector, or a vector of the upper right triangle of the correlation matrix
* `empirical`: if true, mu, sd and r specify the empirical not population mean, sd and covariance 
* `long`: Whether the returned tbl is in wide or long format (defaults to value of `faux_options("long")`)
* `dv`: the name of the dv column for long plots (defaults to y)
* `id`: the name of the id column (defaults to id)
* `vardesc`: a Dict of variable descriptions having the names of the within- and between-subject factors
* `rep`: the number of data frames to simulate (default 1); if greater than 1, the returned data frame contains a rep column
* `sep`: separator for factor levels

# Examples
```julia-repl
julia> using Faux, DataStructures
julia> b = ["condition" => ["ctl", "exp"]]
julia> w = ["version" => ["A", "B"]]
julia> df = sim_design(within = w, between = b, n = 10)
```
"""
function sim_design(;within = [], 
                     between = [], 
                     n = 100, mu = 0, sd = 1, r = 0, 
                     empirical::Bool = false, 
                     long::Bool = false, 
                     dv::String = "y", 
                     id::String = "id",
                     vardesc::Dict = Dict(),
                     sep::String = "_",
                     rep::Int64 = 1)
    # define columns
    cells_b = cell_combos(between, dv, sep) 
    cells_w = cell_combos(within, dv, sep)
    within_factors = first.(within)
    between_factors = first.(between)
    nb = length(cells_b)
    nw = length(cells_w)

    # sort out n, mu, sc, r values
    if !isa(n, Dict)
        n_vals = rep_len(n, nb)
        n = Dict(zip(cells_b, n_vals))
    end

    if !isa(mu, Dict)
        mu_vals = rep_len(mu, nb*nw)
        mu_b = [mu_vals[(i - 1) * nw + 1:min(i * nw, end)] for i in 1:nb]
        mu_b_named = Vector{Dict}(undef, nb)
        for i in 1:nb
            mu_b_named[i] = Dict(zip(cells_w, mu_b[i]))
        end
        mu = Dict(zip(cells_b, mu_b_named))
    end

    if !isa(sd, Dict)
        sd_vals = rep_len(sd, nb*nw)
        sd_b = [sd_vals[(i - 1) * nw + 1:min(i * nw, end)] for i in 1:nb]
        sd_b_named = Vector{Dict}(undef, nb)
        for i in 1:nb
            sd_b_named[i] = Dict(zip(cells_w, sd_b[i]))
        end
        sd = Dict(zip(cells_b, sd_b_named))
    end

    if isa(r, Dict)
        # make sure each value is a matrix
        r2 = Dict()
        for k in keys(r) 
            r2[k] = cormat(r[k], nw)
        end
        r = r2
    else
        # assume values are for each cell
        r_mat = cormat(r, nw)
        r = Dict()
        for cell in cells_b
            r[cell] = r_mat
        end
    end

    # simulate data for each between-cell
    df = DataFrame()
    for cell in cells_b
        mu_cell = [mu[cell][key] for key in cells_w]
        sd_cell = [sd[cell][key] for key in cells_w]

        cell_vars = rnorm_multi(
            n = n[cell] * rep, 
            vars = length(cells_w), 
            mu = mu_cell, 
            sd = sd_cell, 
            r = r[cell], 
            varnames = cells_w, 
            empirical = empirical
        )

        # add between columns
        if length(cells_b) > 1
            cols = split(cell, "_")
            for i in 1:length(cols)
                colname = Symbol(between_factors[i])
                cell_vars[!, colname] .= cols[i]
            end
        end

        # add rep value if rep > 1
        if rep > 1
          cell_vars[!, :rep] .= repeat(1:rep, inner = n[cell])
        end

        # concatenate to df
        df = vcat(df, cell_vars)
    end

    # add IDs
    total_n = size(df)[1]
    id_vals = string.(id, lpad.(1:total_n, ndigits(total_n), '0'))
    df[!, Symbol(id)] = id_vals
    select!(df, id, between_factors, Not(id))

    if (long && nw > 1)
        df_long = stack(df, cells_w, variable_name = "_within_", value_name = dv)
        within_cols = split.(df_long._within_, sep)
        m = hcat(within_cols...) |> permutedims
        w_cols = DataFrame(m, :auto)
        rename!(w_cols, within_factors)
        select!(df_long, Not("_within_"))
        df = hcat(df_long, w_cols)
        select!(df, id, between_factors, within_factors, Not(id))
    end

    if rep > 1
        select!(df, :rep, Not(:rep))
    end

    return df
end

# """
#     cell_combos(factors = [], dv = "y", sep = "_")

# Generate cell names from factor levels

# # Arguments
# * `factors`: An OrderedDict of factor levels
# * `dv`: The DV name to use if there are no factors
# * `sep`: The separator to use to combine factor levels

# # Examples
# ```julia-repl
# julia> within = ["cond" => ["ctl", "exp"],
#                  "vers" => ["A", "B"]]
# julia> cell_combos(within)
#   4-element Vector{String}:
#     "ctl_A"
#     "ctl_B"
#     "exp_A"
#     "exp_B"
# ```
# """

function cell_combos(factors = [], 
                     dv::String = "y", 
                     sep::String = "_")
    if isempty(factors)
        cells = [dv]
    else
        names = first.(factors)
        lengths = length.(getfield.(factors, 2))
        celln = foldl(*, lengths)
        cells = DataFrame([repeat([""], celln) for _ = names], names)

        for n in 1:length(names)
            ofold = lengths[1:n-1]
            v = repeat(factors[n][2], outer = foldl(*, ofold))

            if (n < length(lengths))
                ifold = lengths[n+1:length(lengths)]
                v = repeat(v, inner = foldl(*, ifold))
            end

            cells[!, n] = v
        end
    end

    cell_names = [join(row, sep) for row in eachrow(cells)]
    
    return cell_names
end


function anon(factor...)
    n = length(factor)
    names = string.(('A':'Z')[1:n])
    factors = Vector{Pair{String, Vector{String}}}(undef, n)
    for i in 1:n
        lvl_n = factor[i]
        levels = string.(names[i], lpad.(1:lvl_n, ndigits(lvl_n), '0'))
        factors[i] = (names[i] => levels)
    end

    return factors
end

