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

function bindToImage(this::MemoryChunk, image::vk.VkImage)
    if vk.vkBindImageMemory(this.mVkDevice, image, this.mMemory, this.mOffset) != vk.VK_SUCCESS
        error("Failed to bind memory chunk to image!")
    end
end