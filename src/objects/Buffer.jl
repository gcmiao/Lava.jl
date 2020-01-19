mutable struct Buffer
    mDevice::Device
    mCreateInfo::BufferCreateInfo
    mMemory::MemoryChunk
    mStagingBuffer::Buffer
    mKeepStagingBuffer::Bool

    mHandle::vk.VkBuffer

    function Buffer(device::Device, createInfo::BufferCreateInfo)
        this = new()
        this.mDevice = device
        this.mCreateInfo = createInfo
        this.mHandle = C_NULL
        this.mKeepStagingBuffer = false
        if (handleRef(createInfo)[].size > 0)
            this.mHandle = VkExt.createBuffer(getLogicalDevice(this.mDevice), handleRef(createInfo))
        end
        return this
    end
end

@class Buffer

function handle(this::Buffer)::vk.VkBuffer
    return this.mHandle
end

function destroy(this::Buffer)
    vk.vkDestroyBuffer(getLogicalDevice(this.mDevice), this.mHandle, C_NULL)
    destroy(this.mMemory)
    if isdefined(this, :mStagingBuffer)
        destroy(this.mStagingBuffer)
    end
end

function createBuffer(device::Device, createInfo::BufferCreateInfo)::Buffer
    return Buffer(device, createInfo)
end

function setDataVRAM(this::Buffer, data::Vector, dataType::Type)
    setDataVRAM(this, data, Csize_t(sizeof(dataType) * length(data)))
end

function setDataVRAM(this::Buffer, data::Vector, size::Csize_t)
    # TODO
    #RecordingCommandBuffer::convenienceBufferCheck("Buffer::setDataVRAM()");
    this.initHandle(size);
    if !isdefined(this, :mMemory)
        this.realizeVRAM()
    end

    if isMappable(this.mMemory) # For APUs / integrated GPUs
        mapped = map(this.mMemory)
        memmove(getData(mapped), pointer(data), size)
        unmap(mapped)
    else
        if isdefined(this, :mStagingBuffer)
            staging = this.mStagingBuffer;
        else
            createInfo = copyWithUsage(this.mCreateInfo, vk.VkFlags(vk.VK_BUFFER_USAGE_TRANSFER_SRC_BIT))
            staging = this.mDevice.createBuffer(createInfo)
        end
        staging.setDataRAM(data, size)

        this.copyFrom(staging)

        if this.mKeepStagingBuffer
            this.mStagingBuffer = staging
        end
    end
end

function setDataRAM(this::Buffer, data, size::Csize_t)
    initHandle(this, size)
    if !isdefined(this, :mMemory)
        realizeRAM(this)
    end

    mapped = map(this.mMemory)
    memmove(getData(mapped), pointer(data), size)
    unmap(mapped)
end

function initHandle(this::Buffer, dataLen::Csize_t)
    if (this.mHandle != C_NULL)
        @assert (dataLen <= handleRef(this.mCreateInfo)[].size) "Buffers in Vulkan cannot be " *
                                                                "enlarged. Create a new one or " *
                                                                "start off with a bigger one."
    else
        this.mCreateInfo = copyWithSize(this.mCreateInfo, dataLen)
        this.mHandle = VkExt.createBuffer(getLogicalDevice(this.mDevice), handleRef(this.mCreateInfo))
    end
end

function realizeRAM(this::Buffer)
    @assert (this.mHandle != C_NULL) "Cannot realize a Buffer that doesn't have a size yet."
    logicalDevice = getLogicalDevice(this.mDevice)
    req = VkExt.getBufferMemoryRequirements(logicalDevice, this.mHandle)
    this.mMemory = allocate(getSuballocator(this.mDevice), req, RAM)
    @assert (getOffset(this.mMemory) % req.alignment == 0)
    bindToBuffer(this.mMemory, this.mHandle)
end

function realizeVRAM(this::Buffer)
    @assert (this.mHandle != C_NULL) "Cannot realize a Buffer that doesn't have a size yet."
    logicalDevice = getLogicalDevice(this.mDevice)
    req = VkExt.getBufferMemoryRequirements(logicalDevice, this.mHandle)
    this.mMemory = allocate(getSuballocator(this.mDevice), req, VRAM)
    @assert (getOffset(this.mMemory) % req.alignment == 0)
    bindToBuffer(this.mMemory, this.mHandle)
end

function stagesForUsage(usage::vk.VkBufferUsageFlags)::vk.VkPipelineStageFlags
    flags::vk.VkPipelineStageFlags = vk.VkFlags(0)
    check = (use, flag) -> begin
        if ((usage & use) != 0)
            flags |= flag
        end
    end

    check(vk.VK_BUFFER_USAGE_TRANSFER_SRC_BIT,                          vk.VK_PIPELINE_STAGE_TRANSFER_BIT)
    check(vk.VK_BUFFER_USAGE_TRANSFER_DST_BIT,                          vk.VK_PIPELINE_STAGE_TRANSFER_BIT)
    check(vk.VK_BUFFER_USAGE_UNIFORM_TEXEL_BUFFER_BIT,                  vk.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT)
    check(vk.VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT,                  vk.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT)
    check(vk.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT,                        vk.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT)
    check(vk.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT,                        vk.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT)
    check(vk.VK_BUFFER_USAGE_INDEX_BUFFER_BIT,                          vk.VK_PIPELINE_STAGE_VERTEX_INPUT_BIT)
    check(vk.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT,                         vk.VK_PIPELINE_STAGE_VERTEX_INPUT_BIT)
    check(vk.VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT,                       vk.VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT)
    check(vk.VK_BUFFER_USAGE_TRANSFORM_FEEDBACK_BUFFER_BIT_EXT,         vk.VK_PIPELINE_STAGE_TRANSFORM_FEEDBACK_BIT_EXT)
    check(vk.VK_BUFFER_USAGE_TRANSFORM_FEEDBACK_COUNTER_BUFFER_BIT_EXT, vk.VK_PIPELINE_STAGE_TRANSFORM_FEEDBACK_BIT_EXT)
    check(vk.VK_BUFFER_USAGE_CONDITIONAL_RENDERING_BIT_EXT,             vk.VK_PIPELINE_STAGE_CONDITIONAL_RENDERING_BIT_EXT)
    check(vk.VK_BUFFER_USAGE_RAY_TRACING_BIT_NV,                        vk.VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_NV)

    return flags
end

function accessForUsage(usage::vk.VkBufferUsageFlags)::vk.VkAccessFlags
    flags::vk.VkAccessFlags = vk.VkFlags(0)

    check = (use, flag) -> begin
        if ((usage & use) != 0)
            flags |= flag
        end
    end

    check(vk.VK_BUFFER_USAGE_TRANSFER_SRC_BIT,                          vk.VK_ACCESS_TRANSFER_READ_BIT)
    check(vk.VK_BUFFER_USAGE_TRANSFER_DST_BIT,                          vk.VK_ACCESS_TRANSFER_WRITE_BIT)
    check(vk.VK_BUFFER_USAGE_UNIFORM_TEXEL_BUFFER_BIT,                  vk.VK_ACCESS_UNIFORM_READ_BIT)
    check(vk.VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT,                  vk.VK_ACCESS_SHADER_READ_BIT |
                                                                        vk.VK_ACCESS_SHADER_WRITE_BIT)
    check(vk.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT,                        vk.VK_ACCESS_UNIFORM_READ_BIT)
    check(vk.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT,                        vk.VK_ACCESS_SHADER_READ_BIT |
                                                                        vk.VK_ACCESS_SHADER_WRITE_BIT)
    check(vk.VK_BUFFER_USAGE_INDEX_BUFFER_BIT,                          vk.VK_ACCESS_INDEX_READ_BIT)
    check(vk.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT,                         vk.VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT)
    check(vk.VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT,                       vk.VK_ACCESS_INDIRECT_COMMAND_READ_BIT)
    check(vk.VK_BUFFER_USAGE_TRANSFORM_FEEDBACK_BUFFER_BIT_EXT,         vk.VK_ACCESS_TRANSFORM_FEEDBACK_WRITE_BIT_EXT)
    check(vk.VK_BUFFER_USAGE_TRANSFORM_FEEDBACK_COUNTER_BUFFER_BIT_EXT, vk.VK_ACCESS_TRANSFORM_FEEDBACK_COUNTER_READ_BIT_EXT |
                                                                        vk.VK_ACCESS_TRANSFORM_FEEDBACK_COUNTER_WRITE_BIT_EXT)
    check(vk.VK_BUFFER_USAGE_CONDITIONAL_RENDERING_BIT_EXT,             vk.VK_ACCESS_CONDITIONAL_RENDERING_READ_BIT_EXT)
    check(vk.VK_BUFFER_USAGE_RAY_TRACING_BIT_NV,                        vk.VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_NV |
                                                                        vk.VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_NV)

    return flags
end

function copyFrom(this::Buffer, other::Buffer)
    # TODO
    # RecordingCommandBuffer::convenienceBufferCheck("Buffer::copyFrom()")
    queue = this.mDevice.graphicsQueue()
    cmd = queue.beginCommandBuffer()
    this.copyFrom(other, cmd)
    cmd.endCommandBuffer()
end

function copyFrom(this::Buffer, other::Buffer, cmd::RecordingCommandBuffer)
    region = [vk.VkBufferCopy(
        0, #srcOffset::VkDeviceSize
        0, #dstOffset::VkDeviceSize
        min(this.mCreateInfo.handleRef()[].size, other.mCreateInfo.handleRef()[].size) #size::VkDeviceSize
    )]

    vk.vkCmdCopyBuffer(cmd.handle(), other.handle(), this.handle(), 1, pointer(region))
    cmd.attachResource(other)

    BufferBarrier(cmd, this.handle(),
                  srcStage = vk.VkFlags(vk.VK_PIPELINE_STAGE_TRANSFER_BIT),
                  srcAccessMask = vk.VkFlags(vk.VK_ACCESS_TRANSFER_WRITE_BIT),
                  dstStage = stagesForUsage(this.mCreateInfo.handleRef()[].usage),
                  dstAccessMask = accessForUsage(this.mCreateInfo.handleRef()[].usage)).apply()
end

function keepStagingBuffer(this::Buffer, val::Bool = true)
    this.mKeepStagingBuffer = val
end
