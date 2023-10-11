module Faux

export tovector, rep_len, select_by_type
include("utilities.jl")

export rnorm_multi, get_params
export cormat_from_triangle, cormat
include("mvn.jl")

export sim_design, anon, cell_combos
include("design.jl")

end
