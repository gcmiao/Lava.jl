mutable struct Framebuffer
    mPass::RenderPass
    mViews::Vector{ImageView}
    mViewHandles::Vector{vk.VkImageView}
    mCreateInfo::vk.VkFramebufferCreateInfo
    mOwnedViews

    mHandle::vk.VkFramebuffer

    function Framebuffer(pass::RenderPass, views::Vector{ImageView})
        this = new()
        this.mPass = pass
        this.mViews = views
        this.mViewHandles = Vector{vk.VkImageView}()
        this.mOwnedViews = nothing
        init(this)
        return this
    end

    function Framebuffer(pass::RenderPass, images::Vector{Image})
        this = new()
        this.mPass = pass
        this.mViews = Vector{ImageView}()
        this.mViewHandles = Vector{vk.VkImageView}()
        this.mOwnedViews = this.mViews
        for img in images
            range = vk.VkImageSubresourceRange(
                aspectsOf(img.mCreateInfo.format), # aspectMask::VkImageAspectFlags
                0, # baseMipLevel::UInt32
                1, # levelCount::UInt32
                0, # baseArrayLayer::UInt32
                img.mCreateInfo.arrayLayers # layerCount::UInt32
            )
            push!(this.mViews, img.createView(range))
        end
        init(this)
        return this
    end
end

@class Framebuffer

function destroy(this::Framebuffer)
    vk.vkDestroyFramebuffer(getVkDevice(this.mPass), this.mHandle, C_NULL)
    this.mHandle = C_NULL

    if this.mOwnedViews != nothing
        for v in this.mOwnedViews
            v.destroy()
        end
    end
end

function init(this::Framebuffer)
    empty!(this.mViewHandles)
    for imageView in this.mViews
        push!(this.mViewHandles, imageView.handle())
    end

    width = typemax(Int32)
    height = typemax(Int32)
    layers = typemax(Int32)
    for imageView in this.mViews
        image = imageView.getImage()
        if (image != nothing)
            width = min(width, image.getWidth())
            height = min(height, image.getHeight())
        end
        layers = min(layers, imageView.getLayers())
    end

    this.mCreateInfo = vk.VkFramebufferCreateInfo(
        vk.VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO, #sType::VkStructureType
        C_NULL, #pNext::Ptr{Cvoid}
        0, #flags::VkFramebufferCreateFlags
        this.mPass.handleRef()[], #renderPass::VkRenderPass
        length(this.mViewHandles), #attachmentCount::UInt32
        pointer(this.mViewHandles), #pAttachments::Ptr{VkImageView}
        width, #width::UInt32
        height, #height::UInt32
        layers, #layers::UInt32
    )

    framebuffer= Ref{vk.VkFramebuffer}()
    infoRef = Ref(this.mCreateInfo)
    GC.@preserve infoRef begin
        if (vk.vkCreateFramebuffer(this.mPass.getVkDevice(), infoRef, C_NULL, framebuffer) != vk.VK_SUCCESS)
            error("Failed to create framebuffer!")
        end
    end
    this.mHandle = framebuffer[]
end

function handle(this::Framebuffer)::vk.VkFramebuffer
    return this.mHandle
end

function pass(this::Framebuffer)::RenderPass
    return this.mPass
end

function getWidth(this::Framebuffer)::UInt32
    return this.mCreateInfo.width
end

function getHeight(this::Framebuffer)::UInt32
    return this.mCreateInfo.height
end
