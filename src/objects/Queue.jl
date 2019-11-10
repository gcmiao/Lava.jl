export Queue, QueueRequest, createByFamily

mutable struct QueueRequest
    name::String
    priority::Float32
    flags::vk.VkQueueFlags
    index::UInt32
end

function createGraphics(::Type{QueueRequest}, name::String)
    return QueueRequest(name, 1.0, vk.VK_QUEUE_GRAPHICS_BIT, typemax(UInt32))
end

function createTransfer(::Type{QueueRequest}, name::String)
    return QueueRequest(name, 1.0, vk.VK_QUEUE_TRANSFER_BIT, typemax(UInt32))
end

function createCompute(::Type{QueueRequest}, name::String)
    return QueueRequest(name, 1.0, vk.VK_QUEUE_COMPUTE_BIT, typemax(UInt32))
end

function createByFlags(::Type{QueueRequest}, name::String, flags::vk.VkQueueFlags, priority::Float32)
    return QueueRequest(name, priority, flags, typemax(UInt32))
end

function createByFamily(::Type{QueueRequest}, name::String, index::UInt32, priority::Float32)
    return QueueRequest(name, priority, 0, index)
end

mutable struct Queue
    mFamilyIndex::UInt32
    mQueue::vk.VkQueue
    mPool::vk.VkCommandPool
    mVkDevice::vk.VkDevice

    mFencePool::Vector{vk.VkFence}
    mSubmissionFences::Vector{vk.VkFence}
    mSubmissionBuffers::Vector{vk.VkCommandBuffer}

    function Queue(family::UInt32, queue::vk.VkQueue, pool::vk.VkCommandPool, vkDevice::vk.VkDevice)
        this = new()
        this.mFamilyIndex = family
        this.mQueue = queue
        this.mPool = pool
        this.mVkDevice = vkDevice

        this.mFencePool = Vector{vk.VkFence}()
        this.mSubmissionFences = Vector{vk.VkFence}()
        this.mSubmissionBuffers = Vector{vk.VkCommandBuffer}()
        return this
    end
end

function handle(this::Queue)::vk.VkQueue
    return this.mQueue
end

function family(this::Queue)::UInt32
    return this.mFamilyIndex
end

function getPool(this::Queue)::vk.VkCommandPool
    return this.mPool
end

function getLogicalDevice(this::Queue)::vk.VkDevice
    return this.mVkDevice
end

function catchUp(this::Queue, inflightBuffers::Int32)
    while(length(this.mSubmissionFences) > inflightBuffers)
        VkExt.waitForFences(this.mVkDevice, this.mSubmissionFences, vk.VkBool32(vk.VK_FALSE), typemax(UInt64))
        gc(this)
    end
end

function gc(this::Queue)
    # Garbage collection of pool
    len = length(this.mSubmissionFences)
    i = 1
    while i <= len
        fence = this.mSubmissionFences[i]
        if vk.vkGetFenceStatus(this.mVkDevice, fence) == vk.VK_SUCCESS
            push!(this.mFencePool, fence)
            deleteat!(this.mSubmissionFences, i)
            deleteat!(this.mSubmissionBuffers, i)
            len -= 1
        else
            i += 1
        end
    end
end

function submit(this::Queue, cmd::vk.VkCommandBuffer,
                  waitSemaphores::Vector{vk.VkSemaphore},
                      waitStages::Vector{vk.VkPipelineStageFlags},
                signalSemaphores::Vector{vk.VkSemaphore})
    fence = findFreeFence(this)
    push!(this.mSubmissionFences, fence)
    push!(this.mSubmissionBuffers, cmd)
    cmds = [cmd]
    info = Ref(vk.VkSubmitInfo(
        vk.VK_STRUCTURE_TYPE_SUBMIT_INFO, #sType::VkStructureType
        C_NULL, #pNext::Ptr{Cvoid}
        length(waitSemaphores), #waitSemaphoreCount::UInt32
        pointer(waitSemaphores), #pWaitSemaphores::Ptr{VkSemaphore}
        pointer(waitStages), #pWaitDstStageMask::Ptr{VkPipelineStageFlags}
        1, #commandBufferCount::UInt32
        pointer(cmds), #pCommandBuffers::Ptr{VkCommandBuffer}
        length(signalSemaphores), #signalSemaphoreCount::UInt32
        pointer(signalSemaphores) #pSignalSemaphores::Ptr{VkSemaphore}
    ))

    GC.@preserve cmds info begin
        if vk.vkQueueSubmit(this.mQueue, 1, info, fence) != vk.VK_SUCCESS
            error("Failed to submit draw command buffer!")
        end
    end
end

 function findFreeFence(this::Queue)::vk.VkFence
    if !isempty(this.mFencePool)
        ret = pop!(this.mFencePool)
        vk.vkResetFences(this.mVkDevice, 1, Ref(ret))
        return ret
    else
        ret = VkExt.createFence(this.mVkDevice)
        return ret
    end
 end