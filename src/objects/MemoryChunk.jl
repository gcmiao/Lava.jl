mutable struct MemoryChunk
    mMemory::vk.VkDeviceMemory
    mVkDevice::vk.VkDevice
    mAllocationOffset::vk.VkDeviceSize
    mOffset::vk.VkDeviceSize
    mSize::vk.VkDeviceSize
    mType::UInt32
    mMappable::Bool
    mDeallocate

    function MemoryChunk(memory::vk.VkDeviceMemory, vkDevice::vk.VkDevice,
                         allocationOffset::vk.VkDeviceSize, offset::vk.VkDeviceSize,
                         size::vk.VkDeviceSize, type::UInt32, mappable::Bool,
                         deallocator = nothing)
        this = new()
        this.mMemory = memory
        this.mVkDevice = vkDevice
        this.mAllocationOffset = allocationOffset
        this.mOffset = offset
        this.mSize = size
        this.mType = type
        this.mMappable = mappable
        this.mDeallocate = deallocator
        return this
    end
end

@class MemoryChunk

function destroy(this::MemoryChunk)
    if (this.mSize == 0)
        return
    end
    if (this.mDeallocate != nothing)
        this.mDeallocate(this)
    else
        vk.vkFreeMemory(this.mVkDevice, this.mMemory, C_NULL)
    end
end

mutable struct MappedMemory
    mOffset::vk.VkDeviceSize
    mSize::vk.VkDeviceSize
    mVkDevice::vk.VkDevice
    mMemory::vk.VkDeviceMemory
    mData::Ptr{Cvoid}

    function MappedMemory(mem::MemoryChunk, dataOffset::vk.VkDeviceSize, size::vk.VkDeviceSize)
        this = new()
        this.mMemory = mem.mMemory
        this.mVkDevice = mem.mVkDevice
        this.mOffset = getOffset(mem) + dataOffset
        this.mSize = min(mem.mSize - dataOffset, size)
        this.mData = VkExt.mapMemory(this.mVkDevice, this.mMemory, this.mOffset, this.mSize, vk.VkFlags(0))
        return this
    end
end

function handle(this::MemoryChunk)::vk.VkDeviceMemory
    return this.mMemory
end

function bindToImage(this::MemoryChunk, image::vk.VkImage)
    if vk.vkBindImageMemory(this.mVkDevice, image, this.mMemory, this.mOffset) != vk.VK_SUCCESS
        error("Failed to bind memory chunk to image!")
    end
end

function bindToBuffer(this::MemoryChunk, buffer::vk.VkBuffer)
    if vk.vkBindBufferMemory(this.mVkDevice, buffer, this.mMemory, this.mOffset) != vk.VK_SUCCESS
        error("Failed to bind memory chunk to buffer!")
    end
end

function getOffset(this::MemoryChunk)::vk.VkDeviceSize
    return this.mOffset
end

function getSize(this::MemoryChunk)::vk.VkDeviceSize
    return this.mSize
end

function getAllocationOffset(this::MemoryChunk)::vk.VkDeviceSize
    return this.mAllocationOffset
end

function isMappable(this::MemoryChunk)::Bool
    return this.mMappable
end

function map(this::MemoryChunk, dataOffset::vk.VkDeviceSize = vk.VkDeviceSize(0), size::vk.VkDeviceSize = vk.VkDeviceSize(vk.VK_WHOLE_SIZE))::MappedMemory
    return MappedMemory(this, dataOffset, size)
end

# When ~MappedMemory is called
function unmap(this::MappedMemory)
    if this.mMemory != C_NULL
        range = [vk.VkMappedMemoryRange(
                    vk.VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE, #sType::VkStructureType
                    C_NULL, #pNext::Ptr{Cvoid}
                    this.mMemory, #memory::VkDeviceMemory
                    this.mOffset, #offset::VkDeviceSize
                    vk.VK_WHOLE_SIZE #size::VkDeviceSize
                )]
        vk.vkFlushMappedMemoryRanges(this.mVkDevice, 1, pointer(range))
        vk.vkUnmapMemory(this.mVkDevice, this.mMemory)
    end
end

function getData(this::MappedMemory)::Ptr{Cvoid}
    return this.mData
end
