mutable struct Buffer
    mDevice::Device
    mCreateInfo::BufferCreateInfo
    mMemory::MemoryChunk
    mStagingBuffer::Ref{Buffer}
    mKeepStagingBuffer::Bool

    mHandle::vk.VkBuffer

    function Buffer(device::Device, createInfo::BufferCreateInfo)
        this = new()
        this.mDevice = device
        this.mCreateInfo = createInfo
        this.mHandle = C_NULL
        this.mKeepStagingBuffer = false
        this.mStagingBuffer = Ref{Buffer}()
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
    if (isdefined(this, :mMemory))
        destroy(this.mMemory)
    end
    if isdefined(this.mStagingBuffer, :x)
        destroy(this.mStagingBuffer[])
    end
end

function createBuffer(device::Device, createInfo::BufferCreateInfo)::Buffer
    return Buffer(device, createInfo)
end

function setDataVRAM(this::Buffer, data::Vector, dataType::Type)
    setDataVRAM(this, data, Csize_t(sizeof(dataType) * length(data)))
end

function setDataVRAM(this::Buffer, data::Vector{T}) where T
    setDataVRAM(this, data, Csize_t(sizeof(T) * length(data)))
end

function setDataVRAM(this::Buffer, data::Vector, size::Csize_t)
    # TODO
    #RecordingCommandBuffer::convenienceBufferCheck("Buffer::setDataVRAM()");
    this.initHandle(size)
    if !isdefined(this, :mMemory)
        this.realizeVRAM()
    end

    if isMappable(this.mMemory) # For APUs / integrated GPUs
        mapped = map(this.mMemory)
        memmove(getData(mapped), pointer(data), size)
        unmap(mapped)
    else
        if isdefined(this.mStagingBuffer, :x)
            staging = this.mStagingBuffer[]
        else
            createInfo = copyWithUsage(this.mCreateInfo, vk.VkFlags(vk.VK_BUFFER_USAGE_TRANSFER_SRC_BIT))
            staging = this.mDevice.createBuffer(createInfo)
        end
        staging.setDataRAM(data, size)

        this.copyFrom(staging)

        if this.mKeepStagingBuffer
            this.mStagingBuffer[] = staging
        else
            destroy(staging)
        end
    end
end

function setDataVRAM(this::Buffer, data::Vector{T}, size::Csize_t, cmd)::BufferBarrier where T
    this.initHandle(size)
    if !isdefined(this, :mMemory)
        this.realizeVRAM()
    end

    if this.mMemory.isMappable() # For APUs / integrated GPUs
        mapped = this.mMemory.map()
        memmove(mapped.getData(), pointer(data), size)
        unmap(mapped)
    else
        return this.executeOnStagingBuffer(staging->begin
            staging.setDataRAM(data, size)
            return this.copyFrom(staging, cmd)
        end)
    end
end

function setDataVRAM(this::Buffer, data::Vector{T}, cmd)::BufferBarrier where T
    return this.setDataVRAM(data, Csize_t(sizeof(T) * length(data)), cmd)
end

function setDataRAM(this::Buffer, data::Vector, size::Csize_t)
    initHandle(this, size)
    if !isdefined(this, :mMemory)
        realizeRAM(this)
    end

    mapped = map(this.mMemory)
    memmove(getData(mapped), pointer(data), size)
    unmap(mapped)
end

function initHandle(this::Buffer, size::Csize_t)
    if (this.mHandle != C_NULL)
        @assert (size <= handleRef(this.mCreateInfo)[].size) "Buffers in Vulkan cannot be " *
                                                             "enlarged. Create a new one or " *
                                                             "start off with a bigger one."
    else
        this.mCreateInfo = copyWithSize(this.mCreateInfo, size)
        this.mHandle = VkExt.createBuffer(getLogicalDevice(this.mDevice), handleRef(this.mCreateInfo))
    end
end

function pushData(this::Buffer, data::Vector, size::Csize_t)
    cmd = this.mDevice.graphicsQueue().beginCommandBuffer()
    pushData(this, data, size, cmd)
    cmd.endCommandBuffer()
end

function pushData(this::Buffer, data::Vector, size::Csize_t,
                   cmd)
    vk.vkCmdUpdateBuffer(cmd.handle(), this.mHandle, 0, size, pointer(data))
end

function getData(this::Buffer, outData::Vector)
    @assert isdefined(this, :mMemory) "Buffer needs to be realized to get data."

    if this.mMemory.isMappable() # For APUs / integrated GPUs
        mapped = this.mMemory.map()
        memmove(pointer(outData), mapped.getData(), this.mCreateInfo.handleRef()[].size)
        unmap(mapped)
    else
        this.executeOnStagingBuffer(staging->begin
            cmd = this.mDevice.graphicsQueue().beginCommandBuffer()
            region = [vk.VkBufferCopy(
                0, #srcOffset::VkDeviceSize
                0, #dstOffset::VkDeviceSize
                this.mCreateInfo.handleRef()[].size #size::VkDeviceSize
            )]
            vk.vkCmdCopyBuffer(cmd.handle(), this.mHandle, staging.mHandle, 1, pointer(region))
            cmd.endCommandBuffer()
            staging.getData(outData)
        end)
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

function copyFrom(this::Buffer, other::Buffer, cmd)::BufferBarrier
    region = [vk.VkBufferCopy(
        0, #srcOffset::VkDeviceSize
        0, #dstOffset::VkDeviceSize
        min(this.mCreateInfo.handleRef()[].size, other.mCreateInfo.handleRef()[].size) #size::VkDeviceSize
    )]

    vk.vkCmdCopyBuffer(cmd.handle(), other.handle(), this.handle(), 1, pointer(region))
    cmd.attachResource(other)

    barrier = BufferBarrier(cmd, this.handle(),
                          srcStage = vk.VkFlags(vk.VK_PIPELINE_STAGE_TRANSFER_BIT),
                          srcAccessMask = vk.VkFlags(vk.VK_ACCESS_TRANSFER_WRITE_BIT),
                          dstStage = stagesForUsage(this.mCreateInfo.handleRef()[].usage),
                          dstAccessMask = accessForUsage(this.mCreateInfo.handleRef()[].usage))
    barrier.apply()
    return barrier
end

function keepStagingBuffer(this::Buffer, val::Bool = true)
    this.mKeepStagingBuffer = val
end

function getMemoryChunk(this::Buffer)::MemoryChunk
    return this.mMemory
end

function getSize()::vk.VkDeviceSize
    return this.mCreateInfo.size
end

function executeOnStagingBuffer(this::Buffer, callable)
    if isdefined(this.mStagingBuffer, :x)
        staging = this.mStagingBuffer[]
    else
        createInfo = copyWithUsage(this.mCreateInfo, vk.VkFlags(vk.VK_BUFFER_USAGE_TRANSFER_SRC_BIT |
                                                                vk.VK_BUFFER_USAGE_TRANSFER_DST_BIT))
        staging = this.mDevice.createBuffer(createInfo)
        staging.realizeRAM()
    end

    ret = callable(staging)

    if this.mKeepStagingBuffer
        this.mStagingBuffer[] = staging
    else
        destroy(staging)
    end
    return ret
end
