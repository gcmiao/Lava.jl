using Revise
using Test
using VulkanCore
using LinearAlgebra
using GeometryTypes
using Lava
using Lava: @class, @scope, @autodestroy

const u8vec4 = Vec{4, UInt8}
struct Vertex
    position::Vec3f0
    normal::Vec3f0
    color::u8vec4

    Vertex(pos::Vec3f0, normal::Vec3f0) = new(pos, normal)
end

include("TestAPIs.jl")

# include("class_method.jl")
# include("class_method_benchmark.jl")
#
# println("Testing...")
# @test testClassMethod() == 0
# @test benchmarkClassMethod() == 0

# include("AutoDestroyTest.jl")
