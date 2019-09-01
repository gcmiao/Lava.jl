mutable struct RenderPass
    mVkDevice::vk.VkDevice
    mInfo::RenderPassCreateInfo
    mClearValues::Vector{VkExt.ClearValue}
    
    mHandleRef::Ref{vk.VkRenderPass}

    function RenderPass(device::vk.VkDevice, info::RenderPassCreateInfo)
        this = new()
        this.mVkDevice = device
        this.mInfo = info
        this.mClearValues = Vector{VkExt.ClearValue}()

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

# TODO Deconstruction
# RenderPass::~RenderPass() { mDevice->handle().destroyRenderPass(mHandle); }

function handleRef(this::RenderPass)::Ref{vk.VkRenderPass}
    return this.mHandleRef
end