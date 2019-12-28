module MA
include("../src/common/ClassMacro.jl")
export A, benchmark, benchmark2
struct A
    x::Float32
    y::Integer
    z::Bool
    function A(x::Float32, y::Integer, z::Bool)
        this = new(x, y, z)
        return this
    end
end
@class A [:test, :test3, :benchmark, :benchmark2]

function test(this::A)
    println("------ test ", this)
end

function test3(this::A, b::Integer, c::Float32)
    println("------ test3 ", this, " ", b, " ", c)
end

function test3(this::A, b::Integer)
    println("------ test3 ", this, " ", b)
end

function benchmark(this::A)
    return 1
end

function benchmark2(this::A, b::Integer, c::Float32)
    return b + c
end

function benchmark2(this::A, b::Integer)
    return b - 1
end
end

module MB
include("../src/common/ClassMacro.jl")
export B
mutable struct B
    x::Float32
    y::Integer
    z::Bool
    function B(x::Float32, y::Integer, z::Bool)
        this = new(x, y, z)
        return this
    end
end
@class B [:funA, :funB]

function funA(this::B, b::Integer, c::Float32)
    println("------ funA ", this, " ", b, " ", c)
end

function funA(this::B, b::Integer)
    println("------ funA ", this, " ", b)
end

function funB(this::B)
    println("------ funB ", this)
end

end

using .MA, .MB
function testClassMethod()
    a = A(1.2f0, 3, false)
    println(Base.hasfield(A, :test3))
    println(Base.hasproperty(a, :test3))
    println(Base.hasproperty(a, :test33))
    a.test3(11, 1.f0)
    a.test3(22)
    a.test()
    println(a.x)


    b = B(4.5f0, 6, true)
    b.funA(33, 3.f0)
    b.funA(44)
    b.funB()

    return 0
end
