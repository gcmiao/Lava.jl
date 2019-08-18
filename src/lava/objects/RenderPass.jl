mutable struct RenderPass
    mVkDevice::vk.VkDevice
    mInfo::RenderPassCreateInfo
    mClearValues::Vector{vk.VkClearValue}
    
    mHandleRef::Ref{vk.VkRenderPass}

    function RenderPass(device::vk.VkDevice, info::RenderPassCreateInfo)
        this.mVkDevice = device
        this.mInfo = info
        this.mClearValues = Vector{vk.VkClearValue}()

        this.mHandleRef = Ref{vk.VkRenderPass}()
        if (vk.vkCreateRenderPass(this.mVkDevice, handleRef(this.mInfo), C_NULL, this.mHandleRef) != vk.VK_SUCCESS)
            println("Failed to create render pass!")
        end
        println(this.mHandleRef)

        attachments = this.mInfo.mAttachments
        for a in attachments
            if aspectsOf(getFormat(a)) & vk.VK_IMAGE_ASPECT_COLOR_BIT
                push!(this.mClearValues, vk.VkClearValue(0, 0, 0, 0))
            elseif aspectsOf(getFormat(a)) & (vk.VK_IMAGE_ASPECT_DEPTH_BIT | vk.VK_IMAGE_ASPECT_STENCIL_BIT)
                push!(this.mClearValues, vk.VkClearDepthStencilValue(0, 0))
            else
                error("RenderPass attachments should have a color or a depth/stencil aspect.")
            end
        end
    end
end

# TODO Deconstruction
# RenderPass::~RenderPass() { mDevice->handle().destroyRenderPass(mHandle); }

function handleRef(this::RenderPass)::Ref{vk.VkRenderPass}
    return this.mHandleRef
end