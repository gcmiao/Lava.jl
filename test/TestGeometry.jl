using FileIO

const dataFolder = String(@__DIR__) * "/data/"

function testImporter()
    vertices = Vector{Vertex}()
    indices = geometry.Importer().load(dataFolder * "/models/cube.off",
        (pos, normal, others...)->begin
            push!(vertices, Vertex(Vec3f0(pos), Vec3f0(normal)))
        end)
    return true
end

@test testImporter()
