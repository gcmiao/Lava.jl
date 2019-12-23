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

function handle(this::Buffer)::vk.VkBuffer
    return this.mHandle
end

function destroy(this::Buffer)
    vk.vkDestroyBuffer(getLogicalDevice(this.mDevice), this.mHandle, C_NULL)
    println("Destroy Buffer")
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
    initHandle(this, size);
    if !isdefined(this, :mMemory)
        realizeVRAM(this)
    end

    if isMappable(this.mMemory) # For APUs / integrated GPUs
        println("Is mappable")
        mapped = map(this.mMemory)
        memmove(getData(mapped), pointer(data), size)
        unmap(mapped)
    else
        println("Is unmappable")
        staging::Buffer
        if isdefined(this, :mStagingBuffer)
            staging = this.mStagingBuffer;
        else
            createInfo = copyWithUsage(this.mCreateInfo, vk.VK_BUFFER_USAGE_TRANSFER_SRC_BIT)
            staging = createBuffer(this.mDevice, createInfo)
        end
        setDataRAM(staging, data, size)

        copyFrom(staging)

        if this.mKeepStagingBuffer
            this.mStagingBuffer = staging
        end
    end
end

function setDataRAM(this::Buffer, data, size::Csize_t)
    initHandle(this, size)
    if (!mMemory)
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

function copyFrom(this::Buffer, other::Buffer)
    # TODO
    # RecordingCommandBuffer::convenienceBufferCheck("Buffer::copyFrom()")
    queue = graphicsQueue(this.mDevice)
    cmd = queue.beginCommandBuffer()
    copyFrom(other, cmd)
end

function copyFrom(this::Buffer, other::Buffer, cmd::RecordingCommandBuffer)
    error("copyFrom has not been implemented!")
    region = vk.VkBufferCopy(
        0, #srcOffset::VkDeviceSize
        0, #dstOffset::VkDeviceSize
        min(this.mCreateInfo.size, other.mCreateInfo.size) #size::VkDeviceSize
    )
    # TODO
    # cmd->copyBuffer(other->mHandle, mHandle, 1, &region);
    # cmd.attachResource(other);

    # return BufferBarrier(cmd, handle())
    #     .addSrcStage(vk::PipelineStageFlagBits::eTransfer)
    #     .addSrcAccess(vk::AccessFlagBits::eTransferWrite)
    #     .addDstStage(stagesForUsage(mCreateInfo.usage))
    #     .addDstAccess(accessForUsage(mCreateInfo.usage));
end

function keepStagingBuffer(this::Buffer, val::Bool = true)
    this.mKeepStagingBuffer = val
end
