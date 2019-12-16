using BenchmarkTools

function callMethod(a::A)
    sum = 0
    sum += a.benchmark()
    sum += a.benchmark2(11, 1.f0)
    sum += a.benchmark2(22)
    return sum
end

function callFunction(a::A)
    sum = 0
    sum += benchmark(a)
    sum += benchmark2(a, 11, 1.f0)
    sum += benchmark2(a, 22)
    return sum
end

function benchmarkClassMethod()
    a = A(1.2f0, 3, false)
    
    println("----Call method:")
    b = @benchmarkable callMethod($a)
    tune!(b)
    display(run(b))

    println("\n----Call function:")
    b = @benchmarkable callFunction($a)
    tune!(b)
    display(run(b))
    println()

    return 0
end
