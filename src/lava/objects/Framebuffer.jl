mutable struct Framebuffer
    mPass::RenderPass
    mViews::Vector{ImageView}
    mCreateInfoViews::Vector{vk.VkImageView}
    mCreateInfo::vk.VkFramebufferCreateInfo
    
    mHandle::vk.VkFramebuffer

    function Framebuffer(pass::RenderPass, views::Vector{ImageView})
        this = new()
        this.mPass = pass
        this.mViews = views
        this.mCreateInfoViews = Vector{vk.VkImageView}()
        init(this)
        return this
    end
end

function createFramebuffer(this::RenderPass, attachments::Vector{ImageView})::Framebuffer
    return Framebuffer(this, attachments)
end

function init(this::Framebuffer)
    empty!(this.mCreateInfoViews)
    for imageView in this.mViews
        push!(this.mCreateInfoViews, handle(imageView))
    end

    width = typemax(Int32)
    height = typemax(Int32)
    layers = typemax(Int32)
    for imageView in this.mViews
        image = getImage(imageView)
        if (image != nothing)
            width = min(width, getWidth(image))
            height = min(height, getHeight(image))
        end
        layers = min(layers, getLayers(imageView))
    end

    this.mCreateInfo = vk.VkFramebufferCreateInfo(
        vk.VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO, #sType::VkStructureType
        C_NULL, #pNext::Ptr{Cvoid}
        0, #flags::VkFramebufferCreateFlags
        handleRef(this.mPass)[], #renderPass::VkRenderPass
        length(this.mCreateInfoViews), #attachmentCount::UInt32
        pointer(this.mCreateInfoViews), #pAttachments::Ptr{VkImageView}
        width, #width::UInt32
        height, #height::UInt32
        layers, #layers::UInt32
    )

    framebuffer= Ref{vk.VkFramebuffer}()
    if (vk.vkCreateFramebuffer(getVkDevice(this.mPass), Ref(this.mCreateInfo), C_NULL, framebuffer) != vk.VK_SUCCESS)
        error("Failed to create framebuffer!")
    end
    this.mHandle = framebuffer[]
end

function handle(this::Framebuffer)::vk.VkFramebuffer
    return this.mHandle
end