mutable struct CommandBuffer
    mHandle::vk.VkCommandBuffer
    mLevel::vk.VkCommandBufferLevel
    mQueue::Queue
    mSignalSemaphores::Vector{vk.VkSemaphore}
    mWaitSemaphores::Vector{vk.VkSemaphore}
    mWaitStages::Vector{vk.VkPipelineStageFlags}

    function CommandBuffer(queue::Queue, level::vk.VkCommandBufferLevel)
        this = new()
        this.mQueue = queue
        this.mLevel = level
        this.mSignalSemaphores = Vector{vk.VkSemaphore}()
        this.mWaitSemaphores = Vector{vk.VkSemaphore}()
        this.mWaitStages = Vector{vk.VkPipelineStageFlags}()
        info = Ref(vk.VkCommandBufferAllocateInfo(
            vk.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO, #sType::VkStructureType
            C_NULL, #pNext::Ptr{Cvoid}
            getPool(queue), #commandPool::VkCommandPool
            level, #level::VkCommandBufferLevel
            1 #commandBufferCount::UInt32
        ))
        commandBuffers = Vector{vk.VkCommandBuffer}(undef, 1)
        if (vk.vkAllocateCommandBuffers(getLogicalDevice(this.mQueue), info, pointer(commandBuffers)) != vk.VK_SUCCESS)
            error("Failed to allocate command buffers!")
        end
        this.mHandle = commandBuffers[1]
        return this
    end
end

function handle(this::CommandBuffer)::vk.VkCommandBuffer
    return this.mHandle
end

#thread_local
sRecordingBufferCount = UInt32(0)
mutable struct RecordingCommandBuffer
    mBuffer::CommandBuffer
    mLastLayout::PipelineLayout
    mAutoSubmit::Bool

    function RecordingCommandBuffer(buffer::CommandBuffer)
        this = new()
        this.mBuffer = buffer
        this.mAutoSubmit = false

        global sRecordingBufferCount += 1
        beginInfo = Ref(vk.VkCommandBufferBeginInfo(
            vk.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO, #sType::VkStructureType
            C_NULL, #pNext::Ptr{Cvoid}
            vk.VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT, #flags::VkCommandBufferUsageFlags
            C_NULL #pInheritanceInfo::Ptr{VkCommandBufferInheritanceInfo}
        ))
        if (vk.vkBeginCommandBuffer(handle(this.mBuffer), beginInfo) != vk.VK_SUCCESS)
            error("Failed to begin recording command buffer!")
        end
        return this
    end
end

function handle(this::RecordingCommandBuffer)::vk.VkCommandBuffer
    return this.mBuffer.mHandle
end

function beginRecord(this::CommandBuffer)::RecordingCommandBuffer
    return RecordingCommandBuffer(this)
end

function autoSubmit(this::RecordingCommandBuffer, val::Bool = true)
    this.mAutoSubmit = val
end

function getBuffer(this::RecordingCommandBuffer)::CommandBuffer
    return this.mBuffer
end

function setLastLayout(this::RecordingCommandBuffer, layout::PipelineLayout)
    this.mLastLayout = layout
end

function beginCommandBuffer(this::Queue)::RecordingCommandBuffer
    buf = CommandBuffer(this, vk.VK_COMMAND_BUFFER_LEVEL_PRIMARY)
    rec = beginRecord(buf)
    autoSubmit(rec)
    return rec
end

# signals the given Semaphore once the CommandBuffer finished execution
function signal(this::RecordingCommandBuffer, sem::vk.VkSemaphore)
    signal(this.mBuffer, sem)
end

# waits for the given Semaphore before executing
function wait(this::RecordingCommandBuffer,sem::vk.VkSemaphore)
    wait(this.mBuffer, sem)
end

function signal(this::CommandBuffer, sem::vk.VkSemaphore)
    push!(this.mSignalSemaphores, sem)
end

function wait(this::CommandBuffer, sem::vk.VkSemaphore, stage::vk.VkPipelineStageFlags = vk.VkPipelineStageFlags(vk.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT))
    push!(this.mWaitSemaphores, sem)
    push!(this.mWaitStages, stage)
end

function beginRenderpass(this::RecordingCommandBuffer, fbo::Framebuffer)::ActiveRenderPass
    clearValues = getClearValues(pass(fbo))
    info = vk.VkRenderPassBeginInfo(
        vk.VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO, #sType::VkStructureType
        C_NULL, #pNext::Ptr{Cvoid}
        handleRef(pass(fbo))[], #renderPass::VkRenderPass
        handle(fbo), #framebuffer::VkFramebuffer
        vk.VkRect2D(vk.VkOffset2D(0, 0), vk.VkExtent2D(getWidth(fbo), getHeight(fbo))), #renderArea::VkRect2D
        length(clearValues), #clearValueCount::UInt32
        pointer(clearValues) #pClearValues::Ptr{VkClearValue}
    )

    return ActiveRenderPass(this, info)
end

# TODO
# function bindPipeline(this::RecordingCommandBuffer, pip::ComputePipeline)
#     this.mLastLayout = getLayout(pip)
#     vk.vkCmdBindPipeline(this.mBuffer, vk.VK_PIPELINE_BIND_POINT_COMPUTE, handleRef(pip)[])
# end