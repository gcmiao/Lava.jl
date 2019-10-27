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
    function Queue(family::UInt32, queue::vk.VkQueue, pool::vk.VkCommandPool)
        this = new()
        this.mFamilyIndex = family
        this.mQueue = queue
        this.mPool = pool
        return this
    end
end

function family(this::Queue)::UInt32
    return this.mFamilyIndex
end