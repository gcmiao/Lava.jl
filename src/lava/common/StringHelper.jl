module StringHelper

strings2pp(names::Vector{String}) = (ptr = Base.cconvert(Ptr{Cstring}, names); GC.@preserve ptr Base.unsafe_convert(Ptr{Cstring}, ptr))

function chars2String(chars)::String
    charArray = UInt8[chars...]
    return String(Base.getindex(charArray, 1:Base.findfirst(x->x==0, charArray) - 1))
end

end