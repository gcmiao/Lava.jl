mutable struct RenderPass
    mVkDevice::vk.VkDevice
    mInfo::RenderPassCreateInfo
    mClearValues::Vector{vk.VkClearValue}

    mHandleRef::Ref{vk.VkRenderPass}

    function RenderPass(device::vk.VkDevice, info::RenderPassCreateInfo)
        this = new()
        this.mVkDevice = device
        this.mInfo = info
        this.mClearValues = Vector{vk.VkClearValue}()

        this.mHandleRef = Ref{vk.VkRenderPass}()
        if (vk.vkCreateRenderPass(this.mVkDevice, handleRef(this.mInfo), C_NULL, this.mHandleRef) != vk.VK_SUCCESS)
            error("Failed to create render pass!")
        end

        attachments = this.mInfo.mAttachments
        for a in attachments
            if aspectsOf(getFormat(a)) & vk.VK_IMAGE_ASPECT_COLOR_BIT != 0
                push!(this.mClearValues, VkExt.ClearValue(vk.VkClearColorValue((0, 0, 0, 0))))
            elseif aspectsOf(getFormat(a)) & (vk.VK_IMAGE_ASPECT_DEPTH_BIT | vk.VK_IMAGE_ASPECT_STENCIL_BIT) != 0
                push!(this.mClearValues, VkExt.ClearValue(vk.VkClearDepthStencilValue(0, 0)))
            else
                error("RenderPass attachments should have a color or a depth/stencil aspect.")
            end
        end

        return this
    end
end

@class RenderPass

function destroy(this::RenderPass)
    vk.vkDestroyRenderPass(this.mVkDevice, this.mHandleRef[], C_NULL)
    this.mHandleRef = C_NULL
end

function handleRef(this::RenderPass)::Ref{vk.VkRenderPass}
    return this.mHandleRef
end

function getVkDevice(this::RenderPass)::vk.VkDevice
    return this.mVkDevice
end

function getClearValues(this::RenderPass)::Vector{vk.VkClearValue}
    return this.mClearValues
end
