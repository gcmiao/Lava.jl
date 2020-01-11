export @scope, @autodestroy

macro autodestroy(obj)
    esc(quote
        o = $obj
        push!(autoDestroyPool, o)
        o
    end)
end

macro scope(args...)
    local autoDestroyPool = []
    esc(quote
        pool = $autoDestroyPool
        (autoDestroyPool->$(args[end]))(pool)
        for i = length(pool) : -1 : 1
            pool[i].destroy()
        end
        empty!(pool)
    end)
end
