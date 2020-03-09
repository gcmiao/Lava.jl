struct RayTracingInstance
    bottomLevelAS::BottomLevelAccelerationStructure
    transform::RigidTransform

    instanceCustomIndex::UInt32 # appears as gl_InstanceCustomIndexNV in shader
    hitgroupOffset::UInt32
    flags::UInt8
    mask::UInt8

    function RayTracingInstance(bottomLevelAS::BottomLevelAccelerationStructure,
                                transform::RigidTransform = RigidTransform(),
                                instanceCustomIndex::UInt32 = UInt32(0),
                                hitgroupOffset::UInt32 = UInt32(0),
                                flags::UInt8 = UInt8(0), mask::UInt8 = UInt8(0xff))
        return new(bottomLevelAS, transform, instanceCustomIndex, hitgroupOffset, flags, mask)
    end
end

mutable struct TopLevelAccelerationStructure
    mHandle::vk.VkAccelerationStructureNV
    mCreateInfo::vk.VkAccelerationStructureCreateInfoNV
    mDevice::Device
    mMemory::MemoryChunk
    mInstanceBuffer::Buffer
    mBottomLevels::Set{BottomLevelAccelerationStructure}

    function TopLevelAccelerationStructure(device::Device, num_instances::UInt32)
        this = new()
        this.mDevice = device
        this.mBottomLevels = Set{BottomLevelAccelerationStructure}()

        infoRef = Ref(vk.VkAccelerationStructureCreateInfoNV(
                        vk.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_NV, # sType::VkStructureType
                        C_NULL, # pNext::Ptr{Cvoid}
                        0, # compactedSize::VkDeviceSize
                        vk.VkAccelerationStructureInfoNV(
                            VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_INFO_NV, # sType::VkStructureType
                            C_NULL, # pNext::Ptr{Cvoid}
                            vk.VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_NV, # type::VkAccelerationStructureTypeNV
                            vk.VkFlags(vk.VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_NV), # flags::VkBuildAccelerationStructureFlagsNV
                            num_instances, # instanceCount::UInt32
                            UInt32(0), # geometryCount::UInt32
                            C_NULL # pGeometries::Ptr{VkGeometryNV}# info::VkAccelerationStructureInfoNV
                        )
                    ))
        this.mCreateInfo = infoRef[]
        vkDevice = this.mDevice.getLogicalDevice()
        asRef = Ref{vk.VkAccelerationStructureNV}()
        vk.vkCreateAccelerationStructureNV(vkDevice, ref_to_pointer(infoRef), C_NULL, asRef)
        this.mHandle = asRef[]

        memInfoRef = Ref(vk.VkAccelerationStructureMemoryRequirementsInfoNV(
            vk.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_MEMORY_REQUIREMENTS_INFO_NV, # sType::VkStructureType
            C_NULL, # pNext::Ptr{Cvoid}
            vk.VK_ACCELERATION_STRUCTURE_MEMORY_REQUIREMENTS_TYPE_OBJECT_NV, # type::VkAccelerationStructureMemoryRequirementsTypeNV
            this.mHandle # accelerationStructure::VkAccelerationStructureNV
        ))

        reqsRef = Ref{vk.VkMemoryRequirements2KHR}()
        vk.vkGetAccelerationStructureMemoryRequirementsNV(vkDevice, memInfoRef, reqsRef)

        this.mMemory = device.getSuballocator().allocate(reqsRef[].memoryRequirements, VRAM)
        binds = [vk.VkBindAccelerationStructureMemoryInfoNV(
            vk.VK_STRUCTURE_TYPE_BIND_ACCELERATION_STRUCTURE_MEMORY_INFO_NV, # sType::VkStructureType
            C_NULL, # pNext::Ptr{Cvoid}
            this.mHandle, # accelerationStructure::VkAccelerationStructureNV
            this.mMemory.handle(), # memory::VkDeviceMemory
            this.mMemory.getOffset(), # memoryOffset::VkDeviceSize
            UInt32(0), # deviceIndexCount::UInt32
            C_NULL # pDeviceIndices::Ptr{UInt32}
        )]

        vk.vkBindAccelerationStructureMemoryNV(vkDevice, length(binds), pointer(binds))

        return this
    end
end

function destroy(this::TopLevelAccelerationStructure)
    vk.vkDestroyAccelerationStructureNV(this.mDevice.getLogicalDevice(), this.mHandle, C_NULL)
end

function handle(this::TopLevelAccelerationStructure)::vk.VkAccelerationStructureNV
    return this.mHandle
end

struct BufferInstance
    transform::SVector{12,Float32} # row-major
    instanceId::UInt32 # 24 bits
    mask::UInt8 # 8 bits
    instanceOffset::UInt32 # 24 bits
    flags::UInt8 # 8 bits
    accelerationStructureHandle::UInt64
end

function build(this::TopLevelAccelerationStructure, instances::Vector{RayTracingInstance})
    cmd = this.mDevice.graphicsQueue().beginCommandBuffer()
    this.build(instances, cmd)
    cmd.endCommandBuffer()
end

function build(this::TopLevelAccelerationStructure, instances::Vector{RayTracingInstance}, cmd::RecordingCommandBuffer)
    empty!(this.mBottomLevels)

    deviceInstances = Vector{BufferInstance}(undef, length(instances))
    for i in instances
        insert!(this.mBottomLevels, i.bottomLevelAS)

        # RTX wants the matrix in row-major order
        transform = [1.0f0, 0.0f0, 0.0f0, 0.0f0,
                     0.0f0, 1.0f0, 0.0f0, 0.0f0,
                     0.0f0, 0.0f0, 1.0f0, 0.0f0]
        for col = 0 : 3
            for row = 0 : 2
                transform[4 * row + col + 1] = i.transform.matrix[3 * col + row + 1]
            end
        end

        push!(deviceInstances, BufferInstance(
            transform, i.instanceCustomIndex, i.mask,
            i.hitgroupOffset, i.flags, i.bottomLevelAS.deviceHandle()
        ))
    end

    bytes_needed = sizeof(BufferInstance) * length(deviceInstances)
    if (!isdefined(this, :mInstanceBuffer) || this.mInstanceBuffer.getSize() < bytes_needed)
        this.mInstanceBuffer = this.mDevice.createBuffer(raytracingBuffer())
    end
    this.mInstanceBuffer.setDataVRAM(deviceInstances, cmd)

    scratchBuffer = this.mDevice.createBuffer(raytracingBuffer(this.scratchSize()))
    scratchBuffer.realizeVRAM()

    barrs = [vk.VkMemoryBarrier(
        vk.VK_STRUCTURE_TYPE_MEMORY_BARRIER, # sType::VkStructureType
        C_NULL, # pNext::Ptr{Cvoid}
        vk.VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_NV, # srcAccessMask::VkAccessFlags
        vk.VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_NV |
        vk.VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_NV # dstAccessMask::VkAccessFlags
    )]

    vk.vkCmdPipelineBarrier(cmd.handle(),
                            vk.VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_NV,
                            vk.VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_NV,
                            vk.VkFlags(0), length(barrs), pointer(barrs),
                            0, C_NULL, 0, C_NULL)

    info = this.mCreateInfo.handleRef()[].info
    # TODO info is readonly
    # @assert (length(instances) <= info.instanceCount) "TLAS too small"
    # info.setInstanceCount(length(instances))
    @assert (length(instances) == info.instanceCount) "TLAS must has the same length"

    vk.vkCmdBuildAccelerationStructureNV(cmd.handle(), Ref(info),
                                        this.mInstanceBuffer.handle(), 0, VkExt.VK_FALSE,
                                        this.mHandle, C_NULL, scratchBuffer.handle(), 0)

    cmd.attachResource(scratchBuffer)
end

function scratchSize(this::TopLevelAccelerationStructure)::UInt32
    memInfoRef = Ref(vk.VkAccelerationStructureMemoryRequirementsInfoNV(
        vk.VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_MEMORY_REQUIREMENTS_INFO_NV, # sType::VkStructureType
        C_NULL, # pNext::Ptr{Cvoid}
        vk.VK_ACCELERATION_STRUCTURE_MEMORY_REQUIREMENTS_TYPE_BUILD_SCRATCH_NV, # type::VkAccelerationStructureMemoryRequirementsTypeNV
        this.mHandle # accelerationStructure::VkAccelerationStructureNV
    ))

    reqsRef = Ref{vk.VkMemoryRequirements2KHR}()
    vk.vkGetAccelerationStructureMemoryRequirementsNV(this.mDevice.getLogicalDevice(), memInfoRef, reqsRef)

    return reqsRef[].memoryRequirements.size
end
