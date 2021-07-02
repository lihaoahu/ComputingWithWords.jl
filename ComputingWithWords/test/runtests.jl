using ComputingWithWords
using Test

@testset "ComputingWithWords.jl" begin
    @test Interval(0,1) + Interval(1,2) == Interval(1,3)

end
