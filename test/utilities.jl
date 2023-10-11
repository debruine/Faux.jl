using Faux, Test
using DataFrames

@testset "select_by_type" begin
    df = DataFrame(s = ["A", "B"], 
                   i = [1,2], 
                   n = [1.1, 2.2], 
                   b = [true, false])
    df_num = select_by_type(df)
    df_int = select_by_type(df, Int64)
    df_str = select_by_type(df, String)
    df_bool = select_by_type(df, Bool)

    @test names(df_num) == ["i", "n", "b"]
    @test names(df_int) == ["i"]
    @test names(df_str) == ["s"]
    @test names(df_bool) == ["b"]
end

@testset "tovector" begin
    @test tovector(1:3) == [1,2,3]
    @test tovector(1) == [1]
end

@testset "rep_len" begin
    @test rep_len(1, 3) == [1,1,1]
    @test rep_len([1, 2], 3) == [1,2,1]
    @test rep_len([1,2,3], 3) == [1,2,3]
    @test rep_len([1,2,3], 2) == [1,2]
    @test rep_len([1,2,3], 4) == [1,2,3,1]
    @test rep_len([1,2,3], 5) == [1,2,3,1,2]
    @test rep_len(1:3, 3) == [1,2,3]
end