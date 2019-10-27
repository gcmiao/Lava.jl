import Base.*
import Base.getproperty
export vec3, mat3, mat4,
        make_vec4, make_vec3, make_mat4,
        col_multiple, isOrthonormalMatrix, isApproxEqual,
        distance, rotate,
        getRow

const vec3 = SVector{3, Float32}
const vec4 = SVector{4, Float32}
const u8vec4 = SVector{4, UInt8}
const mat3 = SMatrix{3, 3, Float32}
# mat3(11, 21, 31, 12, 22, 32, 13, 23, 33) # column-major
# mat3([11 12 13; 21 22 23; 31 32 33]) # row-major
const mat4 = MMatrix{4, 4, Float32}

function make_vec3(v::vec4)::vec3
    vec3(v[1], v[2], v[3])
end

function make_vec4(v::vec3, d::AbstractFloat)::vec4
    vec4(v[1], v[2], v[3], d)
end

function make_mat4(m::mat3)::mat4
    mat4([m[1, 1] m[1, 2] m[1, 3] 0;
          m[2, 1] m[2, 2] m[2, 3] 0;
          m[3, 1] m[3, 2] m[3, 3] 0;
          0 0 0 1])
end

function make_mat4(r1::vec4, r2::vec4, r3::vec4, r4::vec4)
    mat4([r1[1] r1[2] r1[3] r1[4];
          r2[1] r2[2] r2[3] r2[4];
          r3[1] r3[2] r3[3] r3[4];
          r4[1] r4[2] r4[3] r4[4]])
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


function isApproxEqual(_v1::mat4, _v2::mat4, _eps::Float32 = Float32(.01))::Bool
    diff =-(_v1, _v2)
    d::Float32 = 0
    d += abs(diff[1, 1])
    d += abs(diff[1, 2])
    d += abs(diff[1, 3])
    d += abs(diff[1, 4])
    d += abs(diff[2, 1])
    d += abs(diff[2, 2])
    d += abs(diff[2, 3])
    d += abs(diff[2, 4])
    d += abs(diff[3, 1])
    d += abs(diff[3, 2])
    d += abs(diff[3, 3])
    d += abs(diff[3, 4])
    d += abs(diff[4, 1])
    d += abs(diff[4, 2])
    d += abs(diff[4, 3])
    d += abs(diff[4, 4])
    return d < _eps
end

function getproperty(v::vec3, sym::Symbol)
    if (sym === :x)
        return getindex(v, 1)
    elseif (sym === :y)
        return getindex(v, 2)
    elseif (sym === :z)
        return getindex(v, 3)
    else
        return getfield(v, sym)
    end
end

function *(m::mat3, v::vec3)
    error("Use explicit matrix multiplication!")
end

function *(m::mat4, v::vec4)
    error("Use explicit matrix multiplication!")
end

function *(m::mat4, v::mat4)
    error("Use explicit matrix multiplication!")
end

function col_multiple(m::mat3, v::vec3)::vec3
    vec3(m[1, 1] * v[1] + m[2, 1] * v[2] + m[3, 1] * v[3],
    m[1, 2] * v[1] + m[2, 2] * v[2] + m[3, 2] * v[3],
    m[1, 3] * v[1] + m[2, 3] * v[2] + m[3, 3] * v[3])
end

function col_multiple(m::mat4, v::vec4)::vec4
    vec4(m[1, 1] * v[1] + m[2, 1] * v[2] + m[3, 1] * v[3] + m[4, 1] * v[4],
         m[1, 2] * v[1] + m[2, 2] * v[2] + m[3, 2] * v[3] + m[4, 2] * v[4],
         m[1, 3] * v[1] + m[2, 3] * v[2] + m[3, 3] * v[3] + m[4, 3] * v[4],
         m[1, 4] * v[1] + m[2, 4] * v[2] + m[3, 4] * v[3] + m[4, 4] * v[4])
end

function col_multiple(m1::mat4, m2::mat4)::mat4
    r1 = col_multiple(m1, getRow(m2, 1))
    r2 = col_multiple(m1, getRow(m2, 2))
    r3 = col_multiple(m1, getRow(m2, 3))
    r4 = col_multiple(m1, getRow(m2, 4))
    make_mat4(r1, r2, r3, r4)
end

function getRow(m::mat3, i::Integer)::vec3
    return vec3(m[i:3:9])
end

function getRow(m::mat4, i::Integer)::vec4
    return vec4(m[i:4:16])
end 

function getColumn(m::mat3, i::Integer)::vec3
    st = (i - 1) * 3 + 1;
    return vec3(m[st:(st + 3)])
end

function getColumn(m::mat4, i::Integer)::vec4
    st = (i - 1) * 4 + 1;
    return vec4(m[st:(st + 4)])
end

function distance(_v1::vec3, _v2::vec3)::Float32
    return norm(-(_v1 - _v2))
end

function rotate(m::mat4, angle::AbstractFloat, v::vec3)::mat4
    a = angle
    c = cos(a)
    s = sin(a)

    axis = normalize(v)
    temp = (1 - c) * axis

    Rotate = mat4(1I)
    Rotate[1, 1] = c + temp[1] * axis[1];
    Rotate[1, 2] = temp[1] * axis[2] + s * axis[3];
    Rotate[1, 3] = temp[1] * axis[3] - s * axis[2];

    Rotate[2, 1] = temp[2] * axis[1] - s * axis[3];
    Rotate[2, 2] = c + temp[2] * axis[2];
    Rotate[2, 3] = temp[2] * axis[3] + s * axis[1];

    Rotate[3, 1] = temp[3] * axis[1] + s * axis[2];
    Rotate[3, 2] = temp[3] * axis[2] - s * axis[1];
    Rotate[3, 3] = c + temp[3] * axis[3];

    Result = mat4(1I)
    Result[1] = m[1] * Rotate[1, 1] + m[2] * Rotate[1, 2] + m[3] * Rotate[1, 3];
    Result[2] = m[1] * Rotate[2, 1] + m[2] * Rotate[2, 2] + m[3] * Rotate[2, 3];
    Result[3] = m[1] * Rotate[3, 1] + m[2] * Rotate[3, 2] + m[3] * Rotate[3, 3];
    Result[4] = m[4];
    return Result;
end
