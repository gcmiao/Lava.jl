using Test

println("Testing...")
@test include("class_method.jl") == nothing
