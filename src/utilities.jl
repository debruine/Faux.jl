
using DataFrames

"""
    tovector(x)

Convert a UnitRange or single value to a vector

# Arguments
- `x`: The value to convert

# Examples
```julia-repl
julia> tovector(1)
[1]
julia> tovector(1:3)
[1,2,3]
```
"""
function tovector(x)
  if isa(x, UnitRange)
    x = collect(x)
  elseif !isa(x, Vector) 
    x = [x]
  end
  return x
end

"""
    rep_len(x, len)

Repeat a value or vector to create a vector of specified length

# Arguments
* `x`: The value or vector to repeat
* `len`: The length of the resulting vector

# Examples
```julia-repl
julia> rep_len(1, 3)
[1, 1, 1]
julia> rep_len(1:2, 3)
[1, 2, 1]
julia> rep_len([1,2,3], 2)
[1,2]
```
"""
function rep_len(x, len)
  # make sure x is a Vector
  x = tovector(x)
  if length(x) < len
    rep = (len / length(x)) |> ceil |> Int
    x = repeat(x, outer = rep)
  end
  
  return x[1:len]
end


"""
    select_by_type(df)

Select columns from a DataFrame of a specific type

# Arguments
* `df`: The DataFrame
* `type`: The type of column to select

# Examples
```julia-repl
julia> df = DataFrame(s = ["A", "B"], 
                      i = [1,2], 
                      n = [1.1, 2.2], 
                      b = [true, false]);
julia> select_by_type(df)
julia> select_by_type(df, Int64)
julia> select_by_type(df, String)
julia> select_by_type(df, Bool)
```
"""
function select_by_type(df::DataFrame, type = Number)
  subdf = select(df, findall(col -> eltype(col) <: type, eachcol(df)))

  return subdf
end


function setNames(names, values)
  x = NamedTuple(Symbol.(names) .=> values)

  return x
end