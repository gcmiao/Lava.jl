include("ClassMacro.jl")
include("AutodestroyMacro.jl")

export destroy

function destroy(objList::Vector{T}) where T
    for obj in objList
        destroy(obj)
    end
end

function Base.getproperty(objList::Vector{T}, sym::Symbol) where T
    if sym == :destroy
        return () -> begin
            destroy(objList)
        end
    end
end
