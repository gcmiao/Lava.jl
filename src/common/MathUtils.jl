import Base.*
import Base.getproperty
export make_vec4, make_vec3, make_mat4,
        col_multiple, isOrthonormalMatrix, isApproxEqual,
        distance, rotate,
        getRow
using GeometryTypes
using Rotations

# mat3(11, 21, 31, 12, 22, 32, 13, 23, 33) # column-major
# mat3([11 12 13; 21 22 23; 31 32 33]) # row-major

function make_vec3(v::Vec4f0)::Vec3f0
    Vec3f0(v[1], v[2], v[3])
end

function make_vec4(v::Vec3f0, d::AbstractFloat)::Vec4f0
    Vec4f0(v[1], v[2], v[3], d)
end

function make_mat4(m::Mat3f0)::Mat4f0
    Mat4f0([m[1, 1] m[1, 2] m[1, 3] 0;
          m[2, 1] m[2, 2] m[2, 3] 0;
          m[3, 1] m[3, 2] m[3, 3] 0;
          0 0 0 1])
end

function make_mat4(m::Mat3f0, m41::Float32, m42::Float32, m43::Float32, m44::Float32)::Mat4f0
    Mat4f0([m[1, 1] m[1, 2] m[1, 3] 0;
          m[2, 1] m[2, 2] m[2, 3] 0;
          m[3, 1] m[3, 2] m[3, 3] 0;
          m41 m42 m43 m44])
end

function make_mat4(r1::Vec4f0, r2::Vec4f0, r3::Vec4f0, r4::Vec4f0)
    Mat4f0([r1[1] r1[2] r1[3] r1[4];
          r2[1] r2[2] r2[3] r2[4];
          r3[1] r3[2] r3[3] r3[4];
          r4[1] r4[2] r4[3] r4[4]])
end

function isOrthonormalMatrix(_matrix::Mat3f0)::Bool
    return isApproxEqual(inv(_matrix), transpose(_matrix))
end

function isApproxEqual(_v1::Mat3f0, _v2::Mat3f0, _eps::Float32 = Float32(.01))::Bool
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


function isApproxEqual(_v1::Mat4f0, _v2::Mat4f0, _eps::Float32 = Float32(.01))::Bool
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

function getproperty(v::Vec3f0, sym::Symbol)
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

function *(m::Mat3f0, v::Vec3f0)
    error("Use explicit matrix multiplication!")
end

function *(m::Mat4f0, v::Vec4f0)
    error("Use explicit matrix multiplication!")
end

function *(m::Mat4f0, v::Mat4f0)
    error("Use explicit matrix multiplication!")
end

function col_multiple(m::Mat3f0, v::Vec3f0)::Vec3f0
    Vec3f0(m[1, 1] * v[1] + m[2, 1] * v[2] + m[3, 1] * v[3],
    m[1, 2] * v[1] + m[2, 2] * v[2] + m[3, 2] * v[3],
    m[1, 3] * v[1] + m[2, 3] * v[2] + m[3, 3] * v[3])
end

function col_multiple(m::Mat4f0, v::Vec4f0)::Vec4f0
    Vec4f0(m[1, 1] * v[1] + m[2, 1] * v[2] + m[3, 1] * v[3] + m[4, 1] * v[4],
         m[1, 2] * v[1] + m[2, 2] * v[2] + m[3, 2] * v[3] + m[4, 2] * v[4],
         m[1, 3] * v[1] + m[2, 3] * v[2] + m[3, 3] * v[3] + m[4, 3] * v[4],
         m[1, 4] * v[1] + m[2, 4] * v[2] + m[3, 4] * v[3] + m[4, 4] * v[4])
end

function col_multiple(m1::Mat4f0, m2::Mat4f0)::Mat4f0
    r1 = col_multiple(m1, getRow(m2, 1))
    r2 = col_multiple(m1, getRow(m2, 2))
    r3 = col_multiple(m1, getRow(m2, 3))
    r4 = col_multiple(m1, getRow(m2, 4))
    make_mat4(r1, r2, r3, r4)
end

function getRow(m::Mat3f0, i::Integer)::Vec3f0
    return Vec3f0(m[i:3:9])
end

function getRow(m::Mat4f0, i::Integer)::Vec4f0
    return Vec4f0(m[i:4:16])
end

function getColumn(m::Mat3f0, i::Integer)::Vec3f0
    st = (i - 1) * 3 + 1;
    return Vec3f0(m[st:(st + 3)])
end

function getColumn(m::Mat4f0, i::Integer)::Vec4f0
    st = (i - 1) * 4 + 1;
    return Vec4f0(m[st:(st + 4)])
end

function distance(_v1::Vec3f0, _v2::Vec3f0)::Float32
    return norm(-(_v1 - _v2))
end

function rotate(m::RotMatrix, angle::AbstractFloat, v::Vec3f0)::RotMatrix
    result = AngleAxis(angle, v[1], v[2], v[3]) * m;
    return result
end
