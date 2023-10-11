using Faux, Test
using DataFrames, Statistics, Random

@testset "anon" begin
    @test anon(2) == ["A" => ["A1", "A2"]]
    @test anon(2, 3) == ["A" => ["A1", "A2"],
                         "B" => ["B1", "B2", "B3"]]

    df = sim_design(within = anon(2))
    @test names(df) == ["id", "A1", "A2"]

    df = sim_design(within = anon(2), long = true) 
    @test names(df) == ["id", "A", "y"]   
end

@testset "sim_design" begin
    df = sim_design()
    @test isa(df, DataFrame)
    @test size(df) == (100, 2)
    @test names(df) == ["id", "y"]

    # reps
    df = sim_design(rep = 3)
    @test size(df) == (300, 3)
    @test names(df) == ["rep", "id", "y"]

    # change n
    df = sim_design(n = 10)
    @test size(df) == (10, 2)
end

@testset "sim_design empirical" begin
    df = sim_design(empirical = true)
    @test mean(df.y) ≈ 0 atol = 0.0001
    @test std(df.y) ≈ 1 atol = 0.0001

    df = sim_design(n = 10, empirical = true)
    @test mean(df.y) ≈ 0 atol = 0.0001
    @test std(df.y) ≈ 1 atol = 0.0001

    df = sim_design(mu = 25, sd = 10, empirical = true)
    @test mean(df.y) ≈ 25 atol = 0.0001
    @test std(df.y) ≈ 10 atol = 0.0001
end

@testset "sim_design id dv" begin
    df = sim_design(id = "sub", dv = "DV")
    @test names(df) == ["sub", "DV"]
    @test df.sub[1] == "sub001"

    df = sim_design(n = 10, id = "sub")
    @test df.sub[1] == "sub01"

    df = sim_design(n = 5, id = "sub")
    @test df.sub[1] == "sub1"
end

@testset "sim_design long" begin
    # 1 within
    within = ["pet" => ["cat", "dog", "ferret"]]

    df = sim_design(within = within, long = true)
    @test size(df) == (300, 3)
    @test names(df) == ["id", "pet", "y"]

    # 2 within
    within = [
        "pet" => ["cat", "dog", "ferret"],
        "time" => ["day", "night"]
    ]
    df = sim_design(within = within, long = true)
    @test size(df) == (600, 4)
    @test names(df) == ["id", "pet", "time", "y"]
end

@testset "sim_design mu sd" begin
    rnd = Random.seed!(8675309)

    df = sim_design(n = 10000)
    @test mean(df.y) ≈ 0 atol = 1
    @test std(df.y) ≈ 1 atol = 0.1

    df = sim_design(n = 10000, mu = 100)
    @test mean(df.y) ≈ 100 atol = 2
    @test std(df.y) ≈ 1 atol = 0.1

    df = sim_design(n = 10000, mu = 100, sd = 10)
    @test mean(df.y) ≈ 100 atol = 2
    @test std(df.y) ≈ 10 atol = 1

    within = ["pet" => ["cat", "dog", "ferret"]]
    df = sim_design(within = within, 
                    mu = [100, 200, 300],
                    sd = [1, 2, 3], 
                    empirical = true)
   @test mean(df.cat) ≈ 100 atol = 0.1
   @test mean(df.dog) ≈ 200 atol = 0.1
   @test mean(df.ferret) ≈ 300 atol = 0.1
   @test std(df.cat) ≈ 1 atol = 0.1
   @test std(df.dog) ≈ 2 atol = 0.1
   @test std(df.ferret) ≈ 3 atol = 0.1
end

@testset "sim_design between" begin
    # 1 between 
    between = ["pet" => ["cat", "dog", "ferret"]]
    df = sim_design(between = between, mu = [1,2,3], empirical = true)
    @test size(df) == (300, 3)
    @test names(df) == ["id", "pet", "y"]
    
    df_grp = groupby(df, :pet)
    means = combine(df_grp, :y => mean)
    @test means.y_mean ≈ [1,2,3] atol = .0001

    df = sim_design(n = [5, 10, 15], between = between)
    @test size(df) == (30, 3)

    ns = combine(groupby(df, :pet), nrow)
    @test ns.nrow == [5, 10, 15]

    # 3 between
    between = [
        "pet" => ["cat", "dog", "ferret"],
        "time" => ["day", "night"],
        "x" => ["A", "B", "C", "D"]
    ]
    df = sim_design(n = 10, between = between)
    @test size(df) == (2*3*4*10, 5)
    @test names(df) == ["id", "pet", "time", "x", "y"]
end

@testset "sim_design within" begin
    # 1 within 
    within = ["pet" => ["cat", "dog", "ferret"]]
    df = sim_design(within = within)
    @test size(df) == (100, 4)
    @test names(df) == ["id", "cat", "dog", "ferret"]

    # 2 within
    within = [
        "pet" => ["cat", "dog"],
        "time" => ["day", "night"]
    ]
    df = sim_design(within = within)
    @test size(df) == (100, 5)
    @test names(df) == ["id", "cat_day", "cat_night", "dog_day", "dog_night"]
end

@testset "sim_design between and within" begin
    within = ["pet" => ["cat", "dog", "ferret"]]
    between = ["cond" => ["a", "b"]]
    mu = Dict("a" => Dict("ferret" => 30, "dog" => 20, "cat" => 10),
              "b" => Dict("cat" => 15, "dog" => 25, "ferret" => 35))
    sd = Dict("a" => Dict("ferret" => 3, "dog" => 2, "cat" => 1),
              "b" => Dict("cat" => 1.5, "dog" => 2.5, "ferret" => 3.5))
    r = Dict("a" => [.1, .2, .3],
             "b" => [.4, .5, .6])

    df = sim_design(within = within, between = between,
                    mu = mu, sd = sd, r = r,
                    empirical = true)
    df_a = filter(row -> row.cond == "a", df)
    df_b = filter(row -> row.cond == "b", df)
    @test size(df) == (200, 5)
    @test names(df) == ["id", "cond", "cat", "dog", "ferret"]
    @test mean(df_a.cat) ≈ 10 atol = 0.1
    @test mean(df_a.dog) ≈ 20 atol = 0.1
    @test mean(df_a.ferret) ≈ 30 atol = 0.1
    @test mean(df_b.cat) ≈ 15 atol = 0.1
    @test mean(df_b.dog) ≈ 25 atol = 0.1
    @test mean(df_b.ferret) ≈ 35 atol = 0.1
    @test std(df_a.cat) ≈ 1.0 atol = 0.1
    @test std(df_a.dog) ≈ 2.0 atol = 0.1
    @test std(df_a.ferret) ≈ 3.0 atol = 0.1
    @test std(df_b.cat) ≈ 1.5 atol = 0.1
    @test std(df_b.dog) ≈ 2.5 atol = 0.1
    @test std(df_b.ferret) ≈ 3.5 atol = 0.1
    @test cor(df_a.cat, df_a.dog) ≈ 0.1 atol = 0.001
    @test cor(df_a.cat, df_a.ferret) ≈ 0.2 atol = 0.001
    @test cor(df_a.dog, df_a.ferret) ≈ 0.3 atol = 0.001
    @test cor(df_b.cat, df_b.dog) ≈ 0.4 atol = 0.001
    @test cor(df_b.cat, df_b.ferret) ≈ 0.5 atol = 0.001
    @test cor(df_b.dog, df_b.ferret) ≈ 0.6 atol = 0.001


    df = sim_design(within = within, between = between, 
                    mu = mu, sd = sd, r = r,
                    long = true, empirical = true)
    @test size(df) == (600, 4)
    @test names(df) == ["id", "cond", "pet", "y"]

    df_grp = groupby(df, [:cond, :pet])
    means = combine(df_grp, :y => mean)
    @test means.y_mean ≈ [10, 15, 20, 25, 30, 35] atol = .0001
    stds = combine(df_grp, :y => std)
    @test stds.y_std ≈ [1.0, 1.5, 2.0, 2.5, 3.0, 3.5] atol = .0001
end

@testset "cell_combos" begin
    between = [
        "pet" => ["cat", "dog", "ferret"],
        "time" => ["day", "night"],
        "x" => ["A", "B", "C", "D"]
    ]
    cells = cell_combos(between)
    

    @test length(cells) == 2*3*4
    @test cells == unique(cells)
    @test cells[1] == "cat_day_A"
    @test cells[24] == "ferret_night_D"
end