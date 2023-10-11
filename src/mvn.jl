# multivariate normal distribution functions
using LinearAlgebra
using DataFrames
using Statistics

"""
    rnorm_multi(n = 100, vars = 1, mu = 0, sd = 1, r = 0, 
                varnames = "X", 
                empirical = false,
                as_matrix = false)

Make normally distributed vectors with specified relationships.

# Arguments
* @`n`: the number of samples required
* @`vars`: the number of variables to return
* @`mu`: a vector giving the means of the variables (numeric vector of length 1 or vars)
* @`sd`: the standard deviations of the variables (numeric vector of length 1 or vars)
* @`r`: the correlations among the variables (can be a single number, vars*vars matrix, vars*vars vector, or a vars*(vars-1)/2 vector)
* @`varnames`: optional names for the variables (string vector of length vars) defaults if r is a matrix with column names
* @`empirical`: logical. If true, mu, sd and r specify the empirical not population mean, sd and covariance 
* @`as.matrix`: logical. If true, returns a matrix

# Examples
```julia-repl
julia> tovector(1) == [1]
julia> tovector(1) != 1
julia> tovector(1:3) == [1,2,3]
```
"""
function rnorm_multi(;n=100, vars=1, mu=0, sd=1, r=0, 
                     varnames="X", 
                     empirical=false, 
                     as_matrix=false)

    mu = tovector(mu)
    sd = tovector(sd)
    varnames = tovector(varnames)
  
    # how many variables
    p = max(vars, length(varnames), length(mu), length(sd))
    mu = rep_len(mu, p)
    sd = rep_len(sd, p)
    if length(unique(varnames)) == 1 && p > 1
        v = varnames[1]
        varnames = ["$v$i" for i in 1:p]
    else
        varnames = rep_len(varnames, p)
    end
  
    # multivariate normal generation
    cor_mat = cormat(r, p)
    sigma = (sd .* transpose(sd)) .* cor_mat
    eS = eigen(LinearAlgebra.Symmetric(sigma))
    ev = eS.values
    
    if !all(ev .>= -1e-06 * abs(ev[1]))
        error("The correlation matrix is not positive semidefinite.")
    end
    
    X = randn(n, p)
    
    # set means and SDs to exactly 0 and 1, keeping 
    if empirical
        X = (X .- Statistics.mean(X, dims=1))  # Centering without scaling
  
        # Perform SVD and keep only the right singular vectors
        U, S, V = svd(X)
        X = U[:, 1:p] * Diagonal(S[1:p])
        
        X = (X ./ std(X, dims=1))  # Scaling without centering
    end
    
    X = mu .+ eS.vectors * Diagonal(sqrt.(max.(ev, 0))) * transpose(X)
    
    mvn = transpose(X) |> Matrix
    if !as_matrix
      mvn = DataFrame(mvn, :auto)
      if length(varnames) == p
        rename!(mvn, varnames, makeunique = true)
      end
    end
    
    return mvn
  end

  function get_params(x; digits = 2)
    if isa(x, DataFrame)
      x = select_by_type(x)
      names = DataFrames.names(x)
      x = Matrix(x)
    else 
      names = ["X$i" for i in 1:size(x, 2)]
    end
      
    # recover sample parameters
    cors = cor(x)
    cors = round.(cors, digits = digits)
    means = Statistics.mean(x, dims=1) |> vec
    means = round.(means, digits = digits)
    sds = Statistics.std(x, dims=1) |> vec
    sds = round.(sds, digits = digits)
    
    df = DataFrame(cors, :auto)
    rename!(df, names)
    df.var = names;
    df.mean = means;
    df.sd = sds;
    
    select!(df, :var, Not(:var))
    
    df
  end

function cormat_from_triangle(cors)
    # calculate number of variable from number of correlations
    vars = Int(ceil(sqrt(2 * length(cors))))
    
    if length(cors) != Int(vars * (vars - 1) / 2)
        error("You don't have the right number of correlations")
    end

    cor_mat = Matrix{Float64}(undef, vars, vars)
    idx = 1
    for i in 1:vars
        cor_mat[i, i] = 1.0
        for j in i+1:vars
            cor_mat[i, j] = cors[idx]
            cor_mat[j, i] = cors[idx]
            idx += 1
        end
    end
    return cor_mat
end

function cormat(cors = 0, vars = 3)
    # Correlation matrix
    if isa(cors, Number) && length(cors) == 1
        if cors >= -1 && cors <= 1
            cors = fill(cors, Int(vars * (vars - 1) / 2))
        else
            error("cors must be between -1 and 1")
        end
    end
    
    if vars == 1
        cor_mat = [1][:,:]
    elseif isa(cors, Matrix)
        if !isa(cors, AbstractMatrix{<:Number})
            error("cors matrix not numeric")
        elseif size(cors) != (vars, vars)
            error("cors matrix wrong dimensions")
        elseif cors != Transpose(cors)
            error("cors matrix not symmetric")
        else
            cor_mat = cors
        end
    elseif length(cors) == vars * vars
        cor_mat = reshape(cors, vars, vars)
    elseif length(cors) == Int(vars * (vars - 1) / 2)
        cor_mat = cormat_from_triangle(cors)
    else
        error("Invalid input for cors")
    end

    # Check matrix is positive definite
    ev = eigen(LinearAlgebra.Symmetric(cor_mat)).values
    if !all(ev .≥ 1e-08)
        error("correlation matrix not positive definite")
    end

    return cor_mat
end

