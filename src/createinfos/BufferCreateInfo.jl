struct BufferCreateInfo
    mHandleRef::Ref{vk.VkBufferCreateInfo}

    function BufferCreateInfo(;
                pNext = C_NULL, #::Ptr{Cvoid}
                flags = 0, #::VkBufferCreateFlags
                size = 0, #::VkDeviceSize
                usage = 0, #::VkBufferUsageFlags
                sharingMode = vk.VK_SHARING_MODE_EXCLUSIVE, #::VkSharingMode
                queueFamilyIndexCount = 0, #::UInt32
                pQueueFamilyIndices = C_NULL #::Ptr{UInt32}
            )
        this = new(Ref(vk.VkBufferCreateInfo(
            vk.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO, #sType::VkStructureType
            pNext, #::Ptr{Cvoid}
            flags, #::VkBufferCreateFlags
            size, #::VkDeviceSize
            usage, #::VkBufferUsageFlags
            sharingMode, #::VkSharingMode
            queueFamilyIndexCount, #::UInt32
            pQueueFamilyIndices, #::Ptr{UInt32}
        )))
    end
end

function handleRef(this::BufferCreateInfo)::Ref{vk.VkBufferCreateInfo}
    return this.mHandleRef
end

function arrayBuffer(size::Csize_t = Csize_t(0))::BufferCreateInfo
    return BufferCreateInfo(size = size, usage = vk.VK_BUFFER_USAGE_TRANSFER_DST_BIT |
                                                 vk.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT)
end

function indexBuffer(size::Csize_t = Csize_t(0))::BufferCreateInfo
    return BufferCreateInfo(size = size, usage = vk.VK_BUFFER_USAGE_TRANSFER_DST_BIT |
                                                 vk.VK_BUFFER_USAGE_INDEX_BUFFER_BIT)
end

function copyWithSize(this::BufferCreateInfo, size::Csize_t)
    handle = this.mHandleRef[]
    return BufferCreateInfo(
        pNext = handle.pNext, #::Ptr{Cvoid}
        flags = handle.flags, #::VkBufferCreateFlags
        size = size, #::VkDeviceSize
        usage = handle.usage, #::VkBufferUsageFlags
        sharingMode = handle.sharingMode, #::VkSharingMode
        queueFamilyIndexCount = handle.queueFamilyIndexCount, #::UInt32
        pQueueFamilyIndices = handle.pQueueFamilyIndices #::Ptr{UInt32}
    )
end

function copyWithUsage(this::BufferCreateInfo, usage::vk.VkBufferUsageFlags)
    handle = this.mHandleRef[]
    return BufferCreateInfo(
        pNext = handle.pNext, #::Ptr{Cvoid}
        flags = handle.flags, #::VkBufferCreateFlags
        size = handle.size, #::VkDeviceSize
        usage = usage, #::VkBufferUsageFlags
        sharingMode = handle.sharingMode, #::VkSharingMode
        queueFamilyIndexCount = handle.queueFamilyIndexCount, #::UInt32
        pQueueFamilyIndices = handle.pQueueFamilyIndices #::Ptr{UInt32}
    )
end