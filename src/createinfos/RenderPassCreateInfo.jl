include("SubpassDescription.jl")
include("SubpassDependency.jl")
include("AttachmentDescription.jl")
include("ExtensionStructure.jl")

mutable struct RenderPassCreateInfo
    flags::vk.VkRenderPassCreateFlags
    mAttachments::Vector{AttachmentDescription}
    mSubpasses::Vector{SubpassDescription}
    mNext::Ref{ExtensionStructure}
    
    mVkDependencies::Vector{vk.VkSubpassDependency}

    mHandleRef::Ref{vk.VkRenderPassCreateInfo}

    function RenderPassCreateInfo()
        this = new()
        this.mAttachments = Vector{AttachmentDescription}()
        this.mSubpasses = Vector{SubpassDescription}()
        this.mVkDependencies = Vector{vk.VkSubpassDependency}()
        return this
    end
end

function createSimpleForward(::Type{RenderPassCreateInfo}, colorFormat::vk.VkFormat)::RenderPassCreateInfo
    info = RenderPassCreateInfo()

    depth = createWithDepth32float(AttachmentDescription)
    clear(depth)
    discard(depth)
    commit(depth)
    addAttachment(info, depth)

    color = createWithColor(AttachmentDescription, colorFormat)
    clear(color)
    finalLayout(color, vk.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR)
    commit(color)
    addAttachment(info, color)

    addSubpass(info, createFullSubpass(info))
    autoAddDependencies(info)
    commit(info)

    return info
end

function addDependency(this::RenderPassCreateInfo, dep::vk.VkSubpassDependency)
    push!(this.mVkDependencies, dep);
end

function addSubpass(this::RenderPassCreateInfo, sub::SubpassDescription)
    push!(this.mSubpasses, sub);
end

function addAttachment(this::RenderPassCreateInfo, att::AttachmentDescription)
    push!(this.mAttachments, att);
end

function createFullSubpass(this::RenderPassCreateInfo)::SubpassDescription
    sub = SubpassDescription()
    attCount = length(this.mAttachments)
    for i = 1 : attCount
        attachment = UInt32(i - 1)
        if (aspectsOf(getFormat(this.mAttachments[i])) & vk.VK_IMAGE_ASPECT_COLOR_BIT != 0)
            push!(sub.colorAttachments, vk.VkAttachmentReference(
                                            attachment, #attachment::UInt32
                                            vk.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL#layout::VkImageLayout
                                        ))
        else
            sub.depthStencilAttachment = vk.VkAttachmentReference(
                                            attachment, #attachment::UInt32
                                            vk.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL#layout::VkImageLayout
                                        )
        end
    end
    commit(sub)
    return sub;
end

function autoAddDependencies(this::RenderPassCreateInfo)
    n = length(this.mSubpasses)
    for i = 0 : n
        srcSubpass = (i == 0) ? vk.VK_SUBPASS_EXTERNAL : UInt32(i - 1)
        dstSubpass = (i == n) ? vk.VK_SUBPASS_EXTERNAL : UInt32(i)
        srcStageMask = dstStageMask = 0
        srcAccessMask = dstAccessMask = 0
        if i > 0
            srcSubpass = UInt32(i - 1)
            srcStageMask = vk.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
            srcAccessMask = vk.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT
        else
            srcSubpass = vk.VK_SUBPASS_EXTERNAL;
            srcStageMask = vk.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT
        end

        if i < n
            dstSubpass = UInt32(i)
            dstStageMask = vk.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT
            dstAccessMask = vk.VK_ACCESS_SHADER_READ_BIT
        else
            dstSubpass = vk.VK_SUBPASS_EXTERNAL;
            dstStageMask = vk.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT
        end
        dep = vk.VkSubpassDependency(
            srcSubpass, #srcSubpass::UInt32
            dstSubpass, #dstSubpass::UInt32
            srcStageMask, #srcStageMask::VkPipelineStageFlags
            dstStageMask, #dstStageMask::VkPipelineStageFlags
            srcAccessMask, #srcAccessMask::VkAccessFlags
            dstAccessMask, #dstAccessMask::VkAccessFlags
            vk.VK_DEPENDENCY_BY_REGION_BIT #dependencyFlags::VkDependencyFlags
        )

        push!(this.mVkDependencies, dep)
    end
end

function commit(this::RenderPassCreateInfo)
    subpassCount = length(this.mSubpasses)
    vkSubpasses = Vector{vk.VkSubpassDescription}()
    for subpass in this.mSubpasses
        push!(vkSubpasses, handleRef(subpass)[])
    end

    attachCount = length(this.mAttachments)
    vkAttachs = Vector{vk.VkAttachmentDescription}()
    for attach in this.mAttachments
        push!(vkAttachs, handleRef(attach)[])
    end
        
    this.mHandleRef = Ref(vk.VkRenderPassCreateInfo(
                            vk.VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO, #sType::VkStructureType
                            isdefined(this, :mNext) ? pointer(this.mNext) : C_NULL, #pNext::Ptr{Cvoid}
                            0, #flags::VkRenderPassCreateFlags
                            attachCount, #attachmentCount::UInt32
                            pointer(vkAttachs), #pAttachments::Ptr{VkAttachmentDescription}
                            subpassCount, #subpassCount::UInt32
                            pointer(vkSubpasses), #pSubpasses::Ptr{VkSubpassDescription}
                            length(this.mVkDependencies), #dependencyCount::UInt32
                            pointer(this.mVkDependencies) #pDependencies::Ptr{VkSubpassDependency}
                        ))
end

function handleRef(this::RenderPassCreateInfo)::Ref{vk.VkRenderPassCreateInfo}
    return this.mHandleRef
end
