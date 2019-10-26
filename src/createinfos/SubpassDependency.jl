mutable struct SubpassDependency
    srcSubpass::UInt32
    dstSubpass::UInt32
    srcStageMask::vk.VkPipelineStageFlags
    dstStageMask::vk.VkPipelineStageFlags
    srcAccessMask::vk.VkAccessFlags
    dstAccessMask::vk.VkAccessFlags
    dependencyFlags::vk.VkDependencyFlags

    mHandleRef::Ref{vk.VkSubpassDependency}

    function SubpassDependency(from::UInt32 = 0, to::UInt32 = 0)
        this = new()
        this.srcSubpass = from
        this.dstSubpass = to
        this.srcStageMask = this.dstStageMask = 0
        this.srcAccessMask = this.dstAccessMask = 0
        this.dependencyFlags = vk.VK_DEPENDENCY_BY_REGION_BIT
        return this
    end
end

function first(::Type{SubpassDependency})::SubpassDependency
    return SubpassDependency(vk.VK_SUBPASS_EXTERNAL, 0);
end

function last(::Type{SubpassDependency}, current::UInt32)::SubpassDependency
    return SubpassDependency(current, vk.VK_SUBPASS_EXTERNAL);
end

function readInVertexShader(this::SubpassDependency)
    this.srcStageMask |= vk.VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT
    this.srcAccessMask |= vk.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT
    this.dstStageMask |= vk.VK_PIPELINE_STAGE_VERTEX_SHADER_BIT
    this.dstAccessMask |= vk.VK_ACCESS_SHADER_READ_BIT
end

function readInFragmentShader(this::SubpassDependency)
    this.srcStageMask |= vk.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
    this.srcAccessMask |= vk.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT
    this.dstStageMask |= vk.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT
    this.dstAccessMask |= vk.VK_ACCESS_SHADER_READ_BIT
end

function reuseDepthStencil(this::SubpassDependency)
    this.srcStageMask |= vk.VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT
    this.srcAccessMask |= vk.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT
    this.dstStageMask |= vk.VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT
    this.dstAccessMask |= vk.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT
end

function reuseColor(this::SubpassDependency)
    this.srcStageMask |= vk.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
    this.srcAccessMask |= vk.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT
    this.dstStageMask |= vk.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
    this.dstAccessMask |= vk.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT
end

function sampleColor(this::SubpassDependency)
    this.srcStageMask |= vk.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
    this.srcAccessMask |= vk.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT
    this.dstStageMask |= vk.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT
    if (this.srcSubpass == vk.VK_SUBPASS_EXTERNAL || this.dstSubpass == vk.VK_SUBPASS_EXTERNAL)
        this.dstStageMask |= vk.VK_PIPELINE_STAGE_VERTEX_SHADER_BIT
        this.dstAccessMask |= vk.VK_ACCESS_SHADER_READ_BIT
    end
end

function transferColor(this::SubpassDependency)
    this.srcStageMask |= vk.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
    this.srcAccessMask |= vk.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT
    this.dstStageMask |= vk.VK_PIPELINE_STAGE_TRANSFER_BIT
    this.dstAccessMask |= vk.VK_ACCESS_TRANSFER_READ_BIT
end

function transferDepth(this::SubpassDependency)
    this.srcStageMask |= (vk.VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT | vk.VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT)
    this.srcAccessMask |= vk.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT
    this.dstStageMask |= vk.VK_PIPELINE_STAGE_TRANSFER_BIT
    this.dstAccessMask |= vk.VK_ACCESS_TRANSFER_READ_BIT
end

function sampleDepthStencil(this::SubpassDependency)
    this.srcStageMask |= vk.VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT
    this.srcAccessMask |= vk.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT
    this.dstStageMask |= vk.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT
    if (this.srcSubpass == vk.VK_SUBPASS_EXTERNAL || this.dstSubpass == vk.VK_SUBPASS_EXTERNAL)
        this.dstStageMask |= vk.VK_PIPELINE_STAGE_VERTEX_SHADER_BIT
        this.dstAccessMask |= vk.VK_ACCESS_SHADER_READ_BIT
    end
end

function commit(this::SubpassDependency)
    this.mHandleRef = Ref(vk.VkSubpassDependency(
                            this.srcSubpass, #srcSubpass::UInt32
                            this.dstSubpass, #dstSubpass::UInt32
                            this.srcStageMask, #srcStageMask::VkPipelineStageFlags
                            this.dstStageMask, #dstStageMask::VkPipelineStageFlags
                            this.srcAccessMask, #srcAccessMask::VkAccessFlags
                            this.dstAccessMask, #dstAccessMask::VkAccessFlags
                            this.dependencyFlags #dependencyFlags::VkDependencyFlags
                        ))
end

function handleRef(this::SubpassDependency)::Ref{vk.VkSubpassDependency}
    return this.mHandleRef
end