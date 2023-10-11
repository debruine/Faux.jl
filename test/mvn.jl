using Faux, Test
using DataFrames
using Statistics

@testset "cormat_from_triangle" begin
    obs = cormat_from_triangle([.1, .2, .3]);
    exp = [1.0 0.1 0.2; 0.1 1.0 0.3; 0.2 0.3 1.0];
    @test obs == exp

    # error on incorrect number of correlations
    msg = "You don't have the right number of correlations";
    @test_throws msg cormat_from_triangle([.1, .3])
end

@testset "cormat" begin
    m1 = cormat((1:6)/10, 4);
    m2 = cormat(m1, 4);
    @test m1 == m2
    
    obs = cormat(.5, 3);
    exp = [1.0 0.5 0.5; 0.5 1.0 0.5; 0.5 0.5 1.0];
    @test obs == exp
    
    obs = cormat([.1, .2, .3]);
    exp = [1.0 0.1 0.2; 0.1 1.0 0.3; 0.2 0.3 1.0];
    @test obs == exp
    
    msg = "correlation matrix not positive definite";
    @test_throws msg cormat([0.9, 0.9, -0.9], 3)
    
    msg = "cors matrix not symmetric";
    @test_throws msg cormat([1.0 0.1; 0.2 1.0], 2)

    # single value
    @test cormat(0, 1) == [1][:,:]
end

@testset "rnorm_multi" begin
    default = rnorm_multi()
    @test isa(default, DataFrames.DataFrame)
    @test size(default) == (100, 1)
    @test names(default) == ["X"]

    m = rnorm_multi(vars = 3, empirical = true, as_matrix = true)
    @test isa(m, Matrix)
    @test size(m) == (100, 3)
    @test mean(m, dims=1) ≈ [0 0 0] atol=0.0001
    @test std(m, dims=1) ≈ [1 1 1] atol=0.0001

    v = ["A", "B", "C"]
    df = rnorm_multi(varnames = v, as_matrix = false)
    @test isa(df, DataFrames.DataFrame)
    @test size(df) == (100, 3)
    @test names(df) == v

    # default names
    df = rnorm_multi(vars = 3)
    @test names(df) == ["X1", "X2","X3"]

    df = rnorm_multi(vars = 3, varnames = "A")
    @test names(df) == ["A1", "A2","A3"]

    # vector values for mu, sd, r
    m = rnorm_multi(mu = [1, 2, 3], sd = [4,5,6], r = [.1, .2, .3], empirical = true, as_matrix = true)
    @test mean(m, dims=1) ≈ [1 2 3] atol=0.0001
    @test std(m, dims=1) ≈ [4 5 6] atol=0.0001
    
    @test cor(m) ≈ [1.0 0.1 0.2; 0.1 1.0 0.3; 0.2 0.3 1.0] atol=0.0001

    # single values for mu, sd, r
    m = rnorm_multi(vars = 3, mu = 1, sd = 2, r = .3, empirical = true, as_matrix = true)
    @test mean(m, dims=1) ≈ [1 1 1] atol=0.0001
    @test std(m, dims=1) ≈ [2 2 2] atol=0.0001
    @test cor(m) ≈ [1.0 0.3 0.3; 0.3 1.0 0.3; 0.3 0.3 1.0] atol=0.0001
end

@testset "get_params" begin
    m = rnorm_multi(vars = 3, mu = 1, sd = 2, r = .3, 
                    empirical = true, as_matrix = true)
    pm = get_params(m)

    df = rnorm_multi(vars = 3, mu = 1, sd = 2, r = .3, 
                     varnames = ["X1", "X2", "X3"],
                     empirical = true, as_matrix = false)
    pdf = get_params(df)

    @test pm == pdf
end
