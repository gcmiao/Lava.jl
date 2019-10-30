mutable struct ActiveRenderPass
    mCmd::RecordingCommandBuffer
    mBeginInfo::vk.VkRenderPassBeginInfo
    mNextSubpass::UInt32

    function ActiveRenderPass(cmd::RecordingCommandBuffer, info::vk.VkRenderPassBeginInfo)
        this = new()
        this.mCmd = cmd
        this.mBeginInfo = info
        this.mNextSubpass = 0
        return this
    end
end

mutable struct InlineSubpass
    mPass::ActiveRenderPass
    mSubpassIndex::UInt32
    mCommandBuffer::RecordingCommandBuffer

    function InlineSubpass(pass::ActiveRenderPass, subpass::UInt32, commandBuffer::RecordingCommandBuffer)
        this = new()
        this.mPass = pass
        this.mSubpassIndex = subpass
        this.mCommandBuffer = commandBuffer
        return this
    end
end

function startInlineSubpass(this::ActiveRenderPass)::InlineSubpass
    cmd = handle(getBuffer(this.mCmd))
    if (this.mNextSubpass == 0)
        vk.vkCmdBeginRenderPass(cmd, Ref(this.mBeginInfo), vk.VK_SUBPASS_CONTENTS_INLINE)
    else
        vk.vkCmdNextSubpass(cmd, vk.VK_SUBPASS_CONTENTS_INLINE)
    end
    this.mNextSubpass += 1
    return InlineSubpass(this, this.mNextSubpass, this.mCmd)
end

function bindPipeline(this::InlineSubpass, pip::GraphicsPipeline)
    setLastLayout(this.mCommandBuffer, getLayout(pip))
    vk.vkCmdBindPipeline(handle(this.mCommandBuffer), vk.VK_PIPELINE_BIND_POINT_GRAPHICS, handleRef(pip)[])
end

function setViewports(this::InlineSubpass, viewports::Vector{vk.VkViewport}, first::UInt32 = UInt32(0))
    vk.vkCmdSetViewport(handle(this.mCommandBuffer), first, length(viewports), pointer(viewports))
end

function bindVertexBuffers(this::InlineSubpass, buffers::Vector{Buffer}, first::UInt32 = UInt32(0))
    vkBuffers = Vector{vk.VkBuffer}()
    for b in buffers
        push!(vkBuffers, handle(b))
    end
    offsets = zeros(vk.VkDeviceSize, length(vkBuffers))

    vk.vkCmdBindVertexBuffers(handle(this.mCommandBuffer), first, length(vkBuffers), pointer(vkBuffers), pointer(offsets))
end