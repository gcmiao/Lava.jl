export @class

macro class(Type, MethodList = [])
    esc(quote
        local methodMap = Set{Symbol}($MethodList)

        function Base.propertynames(obj::$Type)
            return vcat(collect(keys(methodMap)), collect(fieldnames($Type)))
        end

        function Base.hasproperty(obj::$Type, sym::Symbol)
            if (hasfield($Type, sym))
                return true
            else
                return in(sym, methodMap)
            end
        end

        function Base.getproperty(obj::$Type, sym::Symbol)
            #if in(sym, methodMap)
            if hasfield($Type, sym)
                return getfield(obj, sym)
            else
                # assumes unknown properties are methods
                return (args...;kwargs...) -> begin
                    getfield(@__MODULE__, sym)(obj, args...;kwargs...)
                end
            end
            # else
            #     return getfield(obj, sym)
            # end
        end
    end)
end
