mutable struct Hole
    _begin::vk.VkDeviceSize
    _end::vk.VkDeviceSize
end

struct MemoryBlock
    memory::MemoryChunk
    size::vk.VkDeviceSize
    holes::Vector{Hole}
end

mutable struct Suballocator
    mDevice
    mBufferImageGranularity::vk.VkDeviceSize
    mMemoryProperties::vk.VkPhysicalDeviceMemoryProperties
    mLargeHeapBlockSize::vk.VkDeviceSize
    mSmallHeapBlockSize::vk.VkDeviceSize
    mSmallHeapThreshold::vk.VkDeviceSize
    mTypeBlocks::Vector{Vector{MemoryBlock}}

    function Suballocator(device, biGranularity::vk.VkDeviceSize)
        this = new()
        this.mDevice = device
        this.mBufferImageGranularity = biGranularity
        this.mMemoryProperties = VkExt.getMemoryProperties(getPhysicalDevice(this.mDevice))

        this.mLargeHeapBlockSize = vk.VkDeviceSize(256 * 1024 * 1024)
        this.mSmallHeapBlockSize = vk.VkDeviceSize(64 * 1024 * 1024)
        this.mSmallHeapThreshold = vk.VkDeviceSize(512 * 1024 * 1024)

        this.mTypeBlocks = Vector{Vector{MemoryBlock}}(undef, vk.VK_MAX_MEMORY_TYPES)
        for i = 1 : length(this.mTypeBlocks)
            this.mTypeBlocks[i] = Vector{MemoryBlock}()
        end
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
    # the bufferImageGranularity is the size of memory pages that must not be
    # shared between linear resources (buffers) and non-linear resources
    # (images). In order to limit complexity, we (for now) assume that every
    # currently bound resource is of the "wrong" type
    # => increase the alignment to the page size
    newAlignment = max(req.alignment, this.mBufferImageGranularity)

    typeIdx = typeIndexFor(this, req, flags)
    type = this.mMemoryProperties.memoryTypes[typeIdx]
    heapIndex = type.heapIndex # start from 1
    heap = this.mMemoryProperties.memoryHeaps[heapIndex + 1]
    # allocate a large block if heap.size exceed the threshold
    blocksize = heap.size > this.mSmallHeapThreshold ? this.mLargeHeapBlockSize : this.mSmallHeapBlockSize

    if (req.size > blocksize)
        return allocateDedicated(this, req, flags)
    end

    toAlign = offset::vk.VkDeviceSize->begin
        remainder = offset % newAlignment
        if remainder == 0
            return offset
        end
        return offset + newAlignment - remainder;
    end
    deallocator = chunk::MemoryChunk->begin
        deallocate(this, chunk)
    end

    mappable = (type.propertyFlags & vk.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) != 0
    blocks = this.mTypeBlocks[typeIdx]
    logicalDevice = getLogicalDevice(this.mDevice)
    for block in blocks
        count = length(block.holes)
        for i = 1 : count
            hole = block.holes[i]
            diff = Int64(hole._end) - Int64(toAlign(hole._begin)) - Int64(req.size)
            if (diff == 0)
                # Allocation fits hole exactly, throw out the hole
                deleteat!(block.holes, i)
                return MemoryChunk(handle(block.memory), logicalDevice,
                                    hole._begin, toAlign(hole._begin), req.size,
                                    typeIdx, mappable, deallocator)
            elseif (diff > 0)
                # Put the allocation at the beginning of the hole
                newBegin = hole._begin
                # move the begin of the hole backward because the part is used for the new memory chunk
                hole._begin = toAlign(newBegin) + req.size;
                return MemoryChunk(handle(block.memory), logicalDevice,
                                    newBegin, toAlign(newBegin), req.size,
                                    typeIdx, mappable, deallocator)
            end
        end
    end

    # Still no hole found, add a new block
    createInfo = Ref(vk.VkMemoryAllocateInfo(
        vk.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, #sType::VkStructureType
        C_NULL, #pNext::Ptr{Cvoid}
        blocksize, #allocationSize::VkDeviceSize
        typeIdx #memoryTypeIndex::UInt32
    ))

    memory = VkExt.allocateMemory(logicalDevice, createInfo)
    blockchunk = MemoryChunk(memory, logicalDevice,
                            UInt64(0), UInt64(0), blocksize, typeIdx, mappable)
    push!(blocks, MemoryBlock(blockchunk, blocksize, [Hole(req.size, blocksize)]))

    return MemoryChunk(handle(blockchunk), logicalDevice,
                            UInt64(0), UInt64(0), req.size, typeIdx, mappable, deallocator)
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
    best_popcount::Int = 0
    for i::UInt32 = 0 : this.mMemoryProperties.memoryTypeCount - 1
        if (req.memoryTypeBits & (1 << i)) != 0
            current_flags = this.mMemoryProperties.memoryTypes[i + 1].propertyFlags
            ones = count_ones(flags & current_flags)

            if (ones > best_popcount)
                best_popcount = ones
                memtype = i + 1
            end
        end
    end

    if (memtype == typemax(UInt32))
        error("Could not find appropriate memory class.")
    end
    return memtype
end

function deallocate(this::Suballocator, chunk::MemoryChunk)
    # TODO Deconstruction
end