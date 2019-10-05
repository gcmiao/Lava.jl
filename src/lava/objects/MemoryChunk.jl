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
                         dealloc)
        this = new()
        this.mMemory = memory
        this.mVkDevice = vkDevice
        this.mAllocationOffset = allocationOffset
        this.mOffset = offset
        this.mSize = size
        this.mType = type
        this.mMappable = mappable
        this.mDeallocate = dealloc
        return this
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
        this.mData = VkExt.mapMemory(this.mVkDevice, this.mMemory, this.mOffset, this.mSize, 0)
        return this
    end
end

# TODO
# MappedMemory::~MappedMemory() {
#     if (mMemory) {
#         mDevice.flushMappedMemoryRanges(
#             {vk::MappedMemoryRange(mMemory, mOffset, VK_WHOLE_SIZE)});
#         mDevice.unmapMemory(mMemory);
#     }
# }
# MemoryChunk::~MemoryChunk() {
#     if (mSize == 0)
#         return;
#     if (mDeallocate) {
#         mDeallocate(*this);
#     } else {
#         mDevice->handle().freeMemory(mMemory);
#     }
# }

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

function isMappable(this::MemoryChunk)::bool
    return this.mMappable
end

function map(this::MemoryChunk, dataOffset::vk.VkDeviceSize = 0, size::vk.VkDeviceSize = vk.VK_WHOLE_SIZE)::MappedMemory
    return MappedMemory(this, dataOffset, size)
end

function getData(this::MappedMemory)::Ptr{Cvoid}
    return this.mData
end