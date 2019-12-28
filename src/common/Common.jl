include("ClassMacro.jl")

export destroy

function destroy(objList::Vector{T}) where T
    for obj in objList
        destroy(obj)
    end
end
