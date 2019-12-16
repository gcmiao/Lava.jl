macro class(Type, MethodList)
    esc(quote
        local methodMap = Set{Symbol}($MethodList)

        function Base.propertynames(t::$Type)
            return vcat(collect(keys(methodMap)), collect(fieldnames($Type)))
        end

        function Base.getproperty(obj::$Type, sym::Symbol)
            #if in(sym, methodMap)
                return (args...) -> begin
                    getfield(Main, sym)(obj, args...)
                end
            # else
            #     return getfield(obj, sym)
            # end
        end
    end)
end

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

function funA(this::B, b::Integer, c::Float32)
    println("------ funA ", this, " ", b, " ", c)
end

function funA(this::B, b::Integer)
    println("------ funA ", this, " ", b)
end

function funB(this::B)
    println("------ funB ", this)
end

function testClassMethod()
    a = A(1.2f0, 3, false)
    a.test3(11, 1.f0)
    a.test3(22)
    a.test()


    b = B(4.5f0, 6, true)
    b.funA(33, 3.f0)
    b.funA(44)
    b.funB()

    return 0
end
