struct RigidTransform
    matrix::SVector{12, Float32}

    function RigidTransform()
        return new(SVector{12, Float32}(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0))
    end
    
    # Expects a 4x3 values (column-major order)
    function RigidTransform(vals::Vector{Float32})
        this = new(vals)
        return this
    end
end
