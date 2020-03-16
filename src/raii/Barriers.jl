abstract type Barrier end

function drop(this::Barrier)
    this.mEnabled = false
end

struct BufferBarrier <: Barrier
    mEnabled::Bool
    mTarget::vk.VkCommandBuffer
    mSrcStage::vk.VkPipelineStageFlags
    mDstStage::vk.VkPipelineStageFlags
    mHandle::vk.VkBufferMemoryBarrier

    function BufferBarrier(cmd::RecordingCommandBuffer, buffer::vk.VkBuffer;
                      srcStage::vk.VkPipelineStageFlags = 0, dstStage::vk.VkPipelineStageFlags = 0,
                      srcAccessMask::vk.VkAccessFlags = 0, dstAccessMask::vk.VkAccessFlags = 0)
        this = new(true, cmd.getBuffer().handle(),
                    srcStage,
                    dstStage,
                    vk.VkBufferMemoryBarrier(
                        vk.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER, # sType::VkStructureType
                        C_NULL, # pNext::Ptr{Cvoid}
                        srcAccessMask, # srcAccessMask::VkAccessFlags
                        dstAccessMask, # dstAccessMask::VkAccessFlags
                        vk.VK_QUEUE_FAMILY_IGNORED, # srcQueueFamilyIndex::UInt32
                        vk.VK_QUEUE_FAMILY_IGNORED, # dstQueueFamilyIndex::UInt32
                        buffer, # buffer::VkBuffer
                        0, # offset::VkDeviceSize
                        vk.VK_WHOLE_SIZE, # size::VkDeviceSize
                    ))
        return this
    end
end
@class BufferBarrier

function apply(this::BufferBarrier)
    if this.mEnabled
        VkExt.vkCmdPipelineBarrier(this.mTarget, this.mSrcStage, this.mDstStage,
                                   vk.VkFlags(0), bufferMemoryBarriers = [this.mHandle])
    end
end

function handle(this::BufferBarrier)
    return this.mHandle
end
