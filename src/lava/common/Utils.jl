using LinearAlgebra
using StaticArrays

memmove(d, doff, s, soff, n) = ccall(:memmove, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Int), d + doff - 1, s + soff - 1, n)

const vec3 = SVector{3, Float32}
const u8vec4 = SVector{4, UInt8}
const mat3 = SMatrix{3, 3, Float32}
const mat4 = MMatrix{4, 4, Float32}

#function mat4(_m1::mat3)

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

function isOrthonormalMatrix(_matrix::mat3)::Bool
    return isApproxEqual(inv(_matrix), transpose(_matrix))
end

function isApproxEqual(_v1::mat3, _v2::mat3, _eps::Float32 = Float32(.01))::Bool
    diff =-(_v1, _v2)
    d::Float32 = 0
    d += abs(diff[1, 1])
    d += abs(diff[1, 2])
    d += abs(diff[1, 3])
    d += abs(diff[2, 1])
    d += abs(diff[2, 2])
    d += abs(diff[2, 3])
    d += abs(diff[3, 1])
    d += abs(diff[3, 2])
    d += abs(diff[3, 3])
    return d < _eps
end

function distance(_v1::vec3, _v2::vec3)::Float32
    return norm(-(_v1 - _v2))
end