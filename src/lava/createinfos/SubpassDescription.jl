mutable struct SubpassDescription
    flags::vk.VkSubpassDescriptionFlags
    pipelineBindPoint::vk.VkPipelineBindPoint
    resolveAttachments::Vector{vk.VkAttachmentReference}
    depthStencilAttachment::Ref{vk.VkAttachmentReference}
    preserveAttachments::Vector{UInt32}
    colorAttachments::Vector{vk.VkAttachmentReference}
    inputAttachments::Vector{vk.VkAttachmentReference}

    mHandleRef::Ref{vk.VkSubpassDescription}

    function SubpassDescription()
        this = new()
        this.pipelineBindPoint = vk.VK_PIPELINE_BIND_POINT_GRAPHICS
        this.resolveAttachments = Vector{vk.VkAttachmentReference}()
        this.preserveAttachments = Vector{UInt32}()
        return this
    end
end

function depth(this::SubpassDescription, index::UInt32)
    this.depthStencilAttachment = Ref(vk.vkAttachmentReference(
                                            index, #attachment::UInt32
                                            vk.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL #layout::VkImageLayout
                                        ))
end

function colors(this::SubpassDescription, indices::Vector{UInt32})
        resize!(this.colorAttachments, length(indices))
        for idx in indices
            push!(this.colorAttachments, vk.VkAttachmentReference(
                                            idx, #attachment::UInt32
                                            vk.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL #layout::VkImageLayout
                                        ))
        end
end

function inputsColor(this::SubpassDescription, indices::Vector{UInt32})
    oldSize = length(this.inputAttachments)
    resize!(this.inputAttachments, oldSize + length(indices))
    for idx in indices
        push!(this.inputAttachments, vk.VkAttachmentReference(
                                        idx, #attachment::UInt32
                                        vk.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL #layout::VkImageLayout
                                    ))
    end
end

function inputsDepth(this::SubpassDescription, indices::Vector{UInt32})
    oldSize = length(this.inputAttachments)
    resize!(this.inputAttachments, oldSize + length(indices))
    for idx in indices
        push!(this.inputAttachments, vk.VkAttachmentReference(
                                        idx, #attachment::UInt32
                                        vk.VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL #layout::VkImageLayout
                                    ))
    end
end

function perViewAttributes(this::SubpassDescription, active::Bool = true, allComponents::Bool = false)
    if active
        this.flags = vk.VK_SUBPASS_DESCRIPTION_PER_VIEW_ATTRIBUTES_BIT_NVX
        if !allComponents
            this.flags |= vk.VK_SUBPASS_DESCRIPTION_PER_VIEW_POSITION_X_ONLY_BIT_NVX
        end
    else
        this.flags = 0
    end
end

function commit(this::SubpassDescription)
    this.mHandleRef = Ref(vk.VkSubpassDescription(
        this.flags, #flags::VkSubpassDescriptionFlags
        this.pipelineBindPoint, #pipelineBindPoint::VkPipelineBindPoint
        length(this.inputAttachments), #inputAttachmentCount::UInt32
        pointer(this.inputAttachments), #pInputAttachments::Ptr{VkAttachmentReference}
        length(this.colorAttachments), #colorAttachmentCount::UInt32
        pointer(this.colorAttachments), #pColorAttachments::Ptr{VkAttachmentReference}
        pointer(this.resolveAttachments), #pResolveAttachments::Ptr{VkAttachmentReference}
        pointer(this.depthStencilAttachment), #pDepthStencilAttachment::Ptr{VkAttachmentReference}
        length(this.preserveAttachments), #preserveAttachmentCount::UInt32
        pointer(this.preserveAttachments) #pPreserveAttachments::Ptr{UInt32}
    ))
end

function handleRef(this::SubpassDescription)::Ref{vk.VkSubpassDescription}
    return this.mHandleRef
end