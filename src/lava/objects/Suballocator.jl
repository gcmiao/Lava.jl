mutable struct Suballocator
    mDevice
    mBufferImageGranularity::vk.VkDeviceSize
    mMemoryProperties::vk.VkPhysicalDeviceMemoryProperties

    function Suballocator(device, biGranularity::vk.VkDeviceSize)
        this = new()
        this.mDevice = device
        this.mBufferImageGranularity = biGranularity
        this.mMemoryProperties = VkExt.getMemoryProperties(getPhysicalDevice(this.mDevice))
        return this
    end
end

@enum MemoryType begin
    VRAM = 1
    RAM = 2
end

function allocateDedicated(this::Suballocator, req::vk.VkMemoryRequirements, type::MemoryType)::MemoryChunk
    return allocateDedicated(this, req, flagsForType(type))
end

function allocateDedicated(this::Suballocator, req::vk.VkMemoryRequirements, flags::vk.VkMemoryPropertyFlags)::MemoryChunk
    typeIdx = typeIndexFor(this, req, flags)
    type = this.mMemoryProperties.memoryTypes[typeIdx]
    createInfo = Ref(vk.VkMemoryAllocateInfo(
        vk.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, #sType::VkStructureType
        C_NULL, #pNext::Ptr{Cvoid}
        req.size, #allocationSize::VkDeviceSize
        typeIdx - 1 #memoryTypeIndex::UInt32
    ))
    logicalDevice = getLogicalDevice(this.mDevice)
    memory = VkExt.allocateMemory(logicalDevice, createInfo)
    mappable = (type.propertyFlags & vk.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) != 0
    return MemoryChunk(memory, logicalDevice, UInt64(0), UInt64(0), req.size, typeIdx, mappable, nothing)
end

function flagsForType(type::MemoryType)::vk.VkMemoryPropertyFlags
    flags::vk.VkMemoryPropertyFlags = 0
    if type == VRAM
        flags = vk.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT |
                vk.VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT
    elseif type == RAM
        flags = vk.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT |
                vk.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT |
                vk.VK_MEMORY_PROPERTY_HOST_CACHED_BIT
    end
    return flags
end

function typeIndexFor(this::Suballocator, req::vk.VkMemoryRequirements, flags::vk.VkMemoryPropertyFlags)::UInt32
    memtype = typemax(UInt32)
    best_popcount::Csize_t = 0
    for i::UInt32 = 1 : this.mMemoryProperties.memoryTypeCount
        if (req.memoryTypeBits & (1 << (i - 1))) != 0
            current_flags = this.mMemoryProperties.memoryTypes[i].propertyFlags
            intersect = flags & current_flags

            if (intersect > best_popcount)
                best_popcount = intersect
                memtype = i
            end
        end
    end

    if (memtype == typemax(UInt32))
        error("Could not find appropriate memory class.")
    end
    return memtype
end
