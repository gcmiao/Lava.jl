module Utils

using LinearAlgebra
export ref_to_pointer, indexOfField, memmove, sizeofObj, fieldOffset

include("MathUtils.jl")
include("StringUtils.jl")

memmove(dest, src, n) = ccall(:memmove, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Int), dest, src, n)

function sizeofObj(x)
    total = 0;
    fieldNames = fieldnames(typeof(x));
    if length(fieldNames) == 0
        return sizeof(x);
    else
        for fieldName in fieldNames
            total += sizeofObj(getfield(x, fieldName));
        end
        return total;
    end
end

function sizeofField(type, field)
    return sizeof(fieldtype(type, field))
end

function indexOfField(type, field)
    names = fieldnames(type)
    count = length(names)
    for i = 1 : count
        if names[i] == field
            return i
        end
    end
    return 0
end

function fieldOffset(type, member)
    idx = indexOfField(type, member)
    if idx == 0
        error("Cannot find field '", member, "' in type '", type, "'")
    end
    return fieldoffset(type, idx)
end

function ref_to_pointer(type::Type, ref)
    ref == nothing ? C_NULL : Base.unsafe_convert(Ptr{type}, ref)
end

function ref_to_pointer(ref::Ref{T}) where T
    type = typeof(T)
    ref == nothing ? C_NULL : Base.unsafe_convert(Ptr{T}, ref)
end

end #module
