struct BottomLevelAccelerationStructureCreateInfo
    mBuffers::Set
    mHandleRef::Ref{vk.VkAccelerationStructureCreateInfoNV}

    function BottomLevelAccelerationStructureCreateInfo(geometries::Vector{vk.VkGeometryNV}, refBuffers::Set)
        this = new(refBuffers,
            Ref(vk.VkAccelerationStructureCreateInfoNV(
                vk.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_NV, # sType::VkStructureType
                C_NULL, # pNext::Ptr{Cvoid}
                0, # compactedSize::VkDeviceSize
                vk.VkAccelerationStructureInfoNV(
                    vk.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_INFO_NV, # sType::VkStructureType
                    C_NULL, # pNext::Ptr{Cvoid}
                    vk.VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_NV, # type::VkAccelerationStructureTypeNV
                    vk.VkFlags(0), # flags::VkBuildAccelerationStructureFlagsNV
                    UInt32(0), # instanceCount::UInt32
                    length(geometries), # geometryCount::UInt32
                    pointer(geometries) # pGeometries::Ptr{VkGeometryNV}# info::VkAccelerationStructureInfoNV
                ) # info::VkAccelerationStructureInfoNV
            ))
        )
        return this
    end
end
@class BottomLevelAccelerationStructureCreateInfo

function handleRef(this::BottomLevelAccelerationStructureCreateInfo)::Ref{vk.VkAccelerationStructureCreateInfoNV}
    return this.mHandleRef
end

# Adds a triangle geometry with the given buffers, offsets, counts,
# strides. vbuffer == ibuffer is allowed.
function addTriangleGeometry(geometries::Vector{vk.VkGeometryNV}, refBuffers::Set,
                             vbuffer, voffset::UInt32, vcount::UInt32, vstride::UInt32, vformat::vk.VkFormat,
                             ibuffer, ioffset::UInt32, icount::UInt32, itype::vk.VkIndexType)
    push!(refBuffers, vbuffer)
    push!(refBuffers, ibuffer)

    geo = vk.VkGeometryNV(
        vk.VK_STRUCTURE_TYPE_GEOMETRY_NV, # sType::VkStructureType
        C_NULL, # pNext::Ptr{Cvoid}
        vk.VK_GEOMETRY_TYPE_TRIANGLES_NV, # geometryType::VkGeometryTypeNV
        vk.VkGeometryDataNV(
            vk.VkGeometryTrianglesNV(
                vk.VK_STRUCTURE_TYPE_GEOMETRY_TRIANGLES_NV, # sType::VkStructureType
                C_NULL, # pNext::Ptr{Cvoid}
                vbuffer.handle(), # vertexData::VkBuffer
                voffset, # vertexOffset::VkDeviceSize
                vcount, # vertexCount::UInt32
                vcount, # vertexStride::VkDeviceSize
                vformat, # vertexFormat::VkFormat
                ibuffer.handle(), # indexData::VkBuffer
                ioffset, # indexOffset::VkDeviceSize
                icount, # indexCount::UInt32
                itype, # indexType::VkIndexType
                C_NULL, # transformData::VkBuffer
                vk.VkDeviceSize(0) # transformOffset::VkDeviceSize
            ), # triangles::VkGeometryTrianglesNV
            vk.VkGeometryAABBNV(
                vk.VK_STRUCTURE_TYPE_GEOMETRY_AABB_NV, # sType::VkStructureType
                C_NULL, # pNext::Ptr{Cvoid}
                C_NULL, # aabbData::VkBuffer
                UInt32(0), # numAABBs::UInt32
                UInt32(0), # stride::UInt32
                vk.VkDeviceSize(0), # offset::VkDeviceSize
            ) # aabbs::VkGeometryAABBNV
        ), # geometry::VkGeometryDataNV
        vk.VkFlags(0) # flags::VkGeometryFlagsNV
    )
    push!(geometries, geo)
end

# Expects vbuffer to be a densely packed buffer of 3 floats per vertex and
# uses he whole of vbuffer and ibuffer for the geometry
function addTriangleGeometry(geometries::Vector{vk.VkGeometryNV}, refBuffers::Set,
                             vbuffer, ibuffer, itype::vk.VkIndexType = vk.VK_INDEX_TYPE_UINT32)
    vec3bytes = 3 * sizeof(Float32);
    n_verts = vbuffer.getSize() / vec3bytes
    n_indices = ibuffer.getSize() / (itype == vk.VK_INDEX_TYPE_UINT16 ? 2 : 4)

    return addTriangleGeometry(vbuffer, 0, n_verts, vec3bytes, vk.VK_FORMAT_R32G32B32_SFLOAT,
                               ibuffer, 0, n_indices, itype)
end

function addAabbGeometry(geometries::Vector{vk.VkGeometryNV}, refBuffers::Set,
                         aabbBuffer, count::UInt32, offset::UInt32 = UInt32(0), stride::UInt32 = UInt32(6 * sizeof(Float32)))
    insert!(refBuffers, aabbbuffer)

    geo = vk.VkGeometryNV(
        vk.VK_STRUCTURE_TYPE_GEOMETRY_NV, # sType::VkStructureType
        C_NULL, # pNext::Ptr{Cvoid}
        vk.VK_GEOMETRY_TYPE_AABBS_NV, # geometryType::VkGeometryTypeNV
        vk.VkGeometryDataNV(
            vk.VkGeometryTrianglesNV(
                vk.VK_STRUCTURE_TYPE_GEOMETRY_TRIANGLES_NV, # sType::VkStructureType
                C_NULL, # pNext::Ptr{Cvoid}
                C_NULL, # vertexData::VkBuffer
                vk.VkDeviceSize(0), # vertexOffset::VkDeviceSize
                UInt32(0), # vertexCount::UInt32
                vk.VkDeviceSize(0), # vertexStride::VkDeviceSize
                vk.VkFormat(0), # vertexFormat::VkFormat
                C_NULL, # indexData::VkBuffer
                vk.VkDeviceSize(0), # indexOffset::VkDeviceSize
                UInt32(0), # indexCount::UInt32
                vk.VkIndexType(0), # indexType::VkIndexType
                C_NULL, # transformData::VkBuffer
                vk.VkDeviceSize(0) # transformOffset::VkDeviceSize
            ), # triangles::VkGeometryTrianglesNV
            vk.VkGeometryAABBNV(
                vk.VK_STRUCTURE_TYPE_GEOMETRY_AABB_NV, # sType::VkStructureType
                C_NULL, # pNext::Ptr{Cvoid}
                aabbBuffer.handle(), # aabbData::VkBuffer
                count, # numAABBs::UInt32
                stride, # stride::UInt32
                offset, # offset::VkDeviceSize
            ) # aabbs::VkGeometryAABBNV
        ), # geometry::VkGeometryDataNV
        vk.VkFlags(0) # flags::VkGeometryFlagsNV
    )

    push!(geometries, geo)
end
