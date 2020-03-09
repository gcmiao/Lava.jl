mutable struct BottomLevelAccelerationStructure
    mCreateInfo::BottomLevelAccelerationStructureCreateInfo
    mDevice::Device
    mASHandle
    mMemory::MemoryChunk
    mHandle::vk.VkAccelerationStructureNV
    mDeviceHandle::UInt64

    function BottomLevelAccelerationStructure(info::BottomLevelAccelerationStructureCreateInfo, device::Device)
        this = new()
        this.mCreateInfo = info
        this.mDevice = device
        vkDevice = device.getLogicalDevice()

        asRef = Ref{vk.VkAccelerationStructureNV}()
        vk.vkCreateAccelerationStructureNV(vkDevice, ref_to_pointer(info.handleRef()), C_NULL, asRef)
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

        dhRef = Ref{UInt64}()
        vk.vkGetAccelerationStructureHandleNV(vkDevice, this.mHandle, sizeof(UInt64), dhRef)
        this.mDeviceHandle = dhRef[]

        return this
    end

end
@class BottomLevelAccelerationStructure

function destroy(this::BottomLevelAccelerationStructure)
    vk.vkDestroyAccelerationStructureNV(this.mDevice.getLogicalDevice(), this.mHandle, C_NULL)
end

function handle(this::BottomLevelAccelerationStructure)::vk.VkAccelerationStructureNV
    return this.mHandle
end

function create(this::BottomLevelAccelerationStructureCreateInfo, device::Device)
    return BottomLevelAccelerationStructure(this, device)
end

# Build the acceleration structure, creates own scratch and commandbuffer
function build(this::BottomLevelAccelerationStructure)
    buf = this.mDevice.createBuffer(raytracingBuffer(this.scratchSize()))
    buf.realizeVRAM()
    this.build(buf)
end

# Build the acceleration structure, using the supplied scratch buffer and
# using a commandbuffer from the graphics queue of the device
function build(this::BottomLevelAccelerationStructure, scratchBuffer::Buffer)
    cmd = this.mDevice.graphicsQueue().beginCommandBuffer()
    this.build(scratchBuffer, cmd)
    cmd.endCommandBuffer()
end

# Build the acceleration structure with the provided scratch and command
# buffers
function build(this::BottomLevelAccelerationStructure, scratchBuffer::Buffer, cmd::RecordingCommandBuffer)
    vk.vkCmdBuildAccelerationStructureNV(cmd.handle(), Ref(this.mCreateInfo.handleRef()[].info),
                                            C_NULL, 0, VkExt.VK_FALSE,
                                            this.mHandle, C_NULL, scratchBuffer.handle(), 0)
end

# Build the acceleration structure with the provided commandbuffer, creates own scratch
function build(this::BottomLevelAccelerationStructure, cmd::RecordingCommandBuffer)
    buf = this.mDevice.createBuffer(raytracingBuffer(this.scratchSize()))
    buf.realizeVRAM()
    this.build(buf, cmd)
end

function scratchSize(this::BottomLevelAccelerationStructure)::UInt32
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

function deviceHandle(this::BottomLevelAccelerationStructure)::UInt64
    return this.mDeviceHandle
end
