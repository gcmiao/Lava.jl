export strings2pp, chars2String, getExtName

strings2pp(names::Vector{String}) = (ptr = Base.cconvert(Ptr{Cstring}, names); GC.@preserve ptr Base.unsafe_convert(Ptr{Cstring}, ptr))

function chars2String(chars)::String
    charArray = UInt8[chars...]
    return String(Base.getindex(charArray, 1:Base.findfirst(x->x==0, charArray) - 1))
end

# Parse the extension name from a file name
function getExtName(fileName::String)
    minPosA = findlast('/', fileName)
    if minPosA == nothing
        minPosA = 0
    end

    minPosB = findlast('\\', fileName)
    if minPosB == nothing
        minPosB = 0
    end

    minPos = max(minPosA, minPosB)

    dotPos = findlast('.', fileName)
    if dotPos == nothing
        dotPos = 0
    end

    if dotPos <= minPos
        return ""
    end

    return SubString(fileName, dotPos)
end
