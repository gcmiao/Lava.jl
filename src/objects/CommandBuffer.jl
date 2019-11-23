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

# TODO: Deconstruction
# CommandBuffer::~CommandBuffer() {
#     if (!mHandle)
#         return;
#     mQueue->device()->handle().freeCommandBuffers(mQueue->pool(), {mHandle});
# }

#thread_local
sRecordingBufferCount = UInt32(0)
mutable struct RecordingCommandBuffer
    mCmdBuffer::CommandBuffer
    mLastLayout::PipelineLayout
    mAutoSubmit::Bool

    function RecordingCommandBuffer(cmdBuffer::CommandBuffer)
        this = new()
        this.mCmdBuffer = cmdBuffer
        this.mAutoSubmit = false

        global sRecordingBufferCount += 1
        beginInfo = Ref(vk.VkCommandBufferBeginInfo(
            vk.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO, #sType::VkStructureType
            C_NULL, #pNext::Ptr{Cvoid}
            vk.VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT, #flags::VkCommandBufferUsageFlags
            C_NULL #pInheritanceInfo::Ptr{VkCommandBufferInheritanceInfo}
        ))
        if (vk.vkBeginCommandBuffer(handle(this.mCmdBuffer), beginInfo) != vk.VK_SUCCESS)
            error("Failed to begin recording command buffer!")
        end
        return this
    end
end

function handle(this::RecordingCommandBuffer)::vk.VkCommandBuffer
    return this.mCmdBuffer.mHandle
end

function beginRecord(this::CommandBuffer)::RecordingCommandBuffer
    return RecordingCommandBuffer(this)
end

function submit(this::CommandBuffer)
    submit(this.mQueue, this, this.mWaitSemaphores, this.mWaitStages, this.mSignalSemaphores)
end

function autoSubmit(this::RecordingCommandBuffer, val::Bool = true)
    this.mAutoSubmit = val
end

function getBuffer(this::RecordingCommandBuffer)::CommandBuffer
    return this.mCmdBuffer
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

# When ~RecordingCommandBuffer is called
function endCommandBuffer(this::RecordingCommandBuffer)
    if (this.mCmdBuffer != nothing)
        global sRecordingBufferCount -= 1

        vk.vkEndCommandBuffer(handle(this.mCmdBuffer))

        if (this.mAutoSubmit)
            submit(this.mCmdBuffer)
        end
    end
end

# signals the given Semaphore once the CommandBuffer finished execution
function signal(this::RecordingCommandBuffer, sem::vk.VkSemaphore)
    signal(this.mCmdBuffer, sem)
end

# waits for the given Semaphore before executing
function wait(this::RecordingCommandBuffer,sem::vk.VkSemaphore)
    wait(this.mCmdBuffer, sem)
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
#     vk.vkCmdBindPipeline(this.mCmdBuffer, vk.VK_PIPELINE_BIND_POINT_COMPUTE, handleRef(pip)[])
# end

function pushConstantBlock(this::RecordingCommandBuffer, size::UInt32, data::Ptr{Cvoid})
    ranges = getRanges(getCreateInfo(this.mLastLayout))
    @assert (length(ranges) == 1) "Can only use pushConstantBlock with a single push constant range."
    @assert (Base.first(ranges).size == size) "The size of the constant block doesn't match the one in the pipeline layout"
    pushConstants(this, size, data, UInt32(0), vk.VkShaderStageFlags(vk.VK_SHADER_STAGE_ALL), this.mLastLayout);
end

function pushConstants(this::RecordingCommandBuffer, dataSize::UInt32, data::Ptr{Cvoid}, offset::UInt32,
                 stageFlags::vk.VkShaderStageFlags, layout::PipelineLayout)
    # if (layout) {
    pipLayout = handleRef(layout)[]
    # } else {
    #     assert(mLastLayout);
    #     pipLayout = mLastLayout->handle();
    # }
    vk.vkCmdPushConstants(handle(this.mCmdBuffer), pipLayout, stageFlags, offset, dataSize, data)
end
