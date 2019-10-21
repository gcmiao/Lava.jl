module Utils

using LinearAlgebra
using StaticArrays
include("MathUtils.jl")

memmove(d, doff, s, soff, n) = ccall(:memmove, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Int), d + doff - 1, s + soff - 1, n)
#memmove(d, doff, s, soff, n) = ccall(:memcpy, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Int), d + doff - 1, s + soff - 1, n)

function sizeof_obj(x)
    total = 0;
    fieldNames = fieldnames(typeof(x));
    if length(fieldNames) == 0
        return sizeof(x);
    else
        for fieldName in fieldNames
            total += sizeof_obj(getfield(x, fieldName));
        end
        return total;
    end
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

function object_to_pointer(type::Type, pointer)
    pointer == nothing ? C_NULL : Base.unsafe_convert(Ptr{type}, pointer)
end

end #module