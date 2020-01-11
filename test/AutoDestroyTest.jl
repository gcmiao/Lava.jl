using BenchmarkTools
using Lava: @scope, @autodestroy, @class

mutable struct A
    a
    function A(a)
        this = new(a)
        # println("Create ", this)
        return this
    end
end
@class A

function destroy(a::A)
    # println("Destroy ", a)
    a.a = 0
end


function testAutodestroy()
    @scope begin
        a = @autodestroy(A(1))
        a = @autodestroy(A(2))
        a = @autodestroy(A(3))
        b = @autodestroy(A(10))
        @scope begin
            local a = @autodestroy(A(4))
            local a = @autodestroy(A(5))
            local a = @autodestroy(A(6))
        end
    end
end

function testManualDestroy()
    a1 = A(1)
    a2 = A(2)
    a3 = A(3)
    b1 = A(10)
    a4 = A(4)
    a5 = A(5)
    a6 = A(6)
    destroy(a6)
    destroy(a5)
    destroy(a4)
    destroy(b1)
    destroy(a3)
    destroy(a2)
    destroy(a1)
end

function test()
    println("----Call auto destroy:")
    b = @benchmarkable testAutodestroy()
    tune!(b)
    display(run(b))

    println("\n----Call manual destroy:")
    b = @benchmarkable testManualDestroy()
    tune!(b)
    display(run(b))
    println()
end

test()
