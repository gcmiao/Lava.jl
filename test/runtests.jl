using Test
include("class_method.jl")
include("class_method_benchmark.jl")

println("Testing...")
@test testClassMethod() == 0
@test benchmarkClassMethod() == 0
