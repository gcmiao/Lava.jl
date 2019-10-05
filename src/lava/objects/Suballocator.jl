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

function allocate(this::Suballocator, req::vk.VkMemoryRequirements, type::MemoryType)::MemoryChunk
    return allocate(this, req, flagsForType(type))
end

function allocate(this::Suballocator, req::vk.VkMemoryRequirements, flags::vk.VkMemoryPropertyFlags)::MemoryChunk
    # TODO
    # /// the bufferImageGranularity is the size of memory pages that must not be
    # /// shared between linear resources (buffers) and non-linear resources
    # /// (images). In order to limit complexity, we (for now) assume that every
    # /// currently bound resource is of the "wrong" type
    # /// => increase the alignment to the page size
    # req.alignment = std::max(req.alignment, mBufferImageGranularity);

    # uint32_t typeIdx = typeIndexFor(req, flags);
    # auto type = mMemoryProperties.memoryTypes[typeIdx];
    # auto heapIndex = type.heapIndex;
    # auto heap = mMemoryProperties.memoryHeaps[heapIndex];
    # auto blocksize = heap.size > mSmallHeapThreshold ? mLargeHeapBlockSize
    #                                                  : mSmallHeapBlockSize;

    # if (req.size > blocksize)
    #     return allocateDedicated(req, flags);

    # auto toAlign = [&](vk::DeviceSize offset) {
    #     auto remainder = offset % req.alignment;
    #     if (!remainder)
    #         return offset;
    #     return offset + req.alignment - remainder;
    # };

    # auto deallocator = [this](MemoryChunk &chunk) { this->deallocate(chunk); };
    # auto mappable =
    #     !!(type.propertyFlags & vk::MemoryPropertyFlagBits::eHostVisible);
    # auto &blocks = mTypeBlocks[typeIdx];
    # for (auto &block : blocks) {
    #     for (auto it = begin(block.holes); it != end(block.holes); ++it) {
    #         auto &hole = *it;
    #         auto diff = int64_t(hole.end) - int64_t(toAlign(hole.begin)) -
    #                     int64_t(req.size);

    #         if (diff == 0) {
    #             // Allocation fits hole exactly, throw out the hole
    #             block.holes.erase(it);
    #             return std::make_shared<MemoryChunk>(
    #                 block.memory->handle(), mDevice.shared_from_this(),
    #                 hole.begin, toAlign(hole.begin), req.size, typeIdx,
    #                 mappable, deallocator);
    #         } else if (diff > 0) {
    #             // Put the allocation at the beginning of the hole
    #             auto begin = hole.begin;
    #             hole.begin = toAlign(begin) + req.size;
    #             return std::make_shared<MemoryChunk>(
    #                 block.memory->handle(), mDevice.shared_from_this(), begin,
    #                 toAlign(begin), req.size, typeIdx, mappable, deallocator);
    #         }
    #     }
    # }

    # // Still no hole found, add a new block
    # vk::MemoryAllocateInfo info;
    # info.memoryTypeIndex = typeIdx;
    # info.allocationSize = blocksize;
    # auto memory = mDevice.handle().allocateMemory(info);
    # auto blockchunk = std::make_shared<MemoryChunk>(
    #     memory, mDevice.shared_from_this(), 0, 0, blocksize, typeIdx, mappable,
    #     MemoryChunk::Deallocator{});
    # blocks.push_back(
    #     MemoryBlock{blockchunk, blocksize, {{req.size, blocksize}}});

    # return std::make_shared<MemoryChunk>(
    #     blocks.back().memory->handle(), mDevice.shared_from_this(), 0, 0,
    #     req.size, typeIdx, mappable, deallocator);
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
