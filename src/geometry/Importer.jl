using FileIO
using GeometryTypes

mutable struct Importer
end
@class Importer

function load(this::Importer, filename::String, callbackPerVertex)::Vector{UInt32}
    model = FileIO.load(filename)
    vertices = decompose(Point{3, Float32}, model)
    fcs = decompose(Face{3, UInt32}, model)
    normals = decompose(Normal{3, Float32}, model)

    indices = Vector{UInt32}()
    for face in fcs
        append!(indices, face)
    end

    if callbackPerVertex != nothing
        vN = length(vertices)
        for i = 1 : vN
            callbackPerVertex(vertices[i], normals[i])
        end
    end
    return indices
end
