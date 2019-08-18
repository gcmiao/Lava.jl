mutable struct AttachmentDescription
    flags::vk.VkAttachmentDescriptionFlags
    format::vk.VkFormat
    samples::vk.VkSampleCountFlagBits
    loadOp::vk.VkAttachmentLoadOp
    storeOp::vk.VkAttachmentStoreOp
    stencilLoadOp::vk.VkAttachmentLoadOp
    stencilStoreOp::vk.VkAttachmentStoreOp
    initialLayout::vk.VkImageLayout
    finalLayout::vk.VkImageLayout

    mHandleRef::Ref{vk.VkAttachmentDescription}

    function AttachmentDescription()
        this = new()
        this.flags = 0
        return this
    end
end

function createWithDepth24Stencil8(::Type{AttachmentDescription})::AttachmentDescription
    result = AttachmentDescription()
    result.format = vk.VK_FORMAT_D24_UNORM_S8_UINT, #format::VkFormat
    result.samples = vk.VK_SAMPLE_COUNT_1_BIT, #samples::VkSampleCountFlagBits
    result.loadOp = vk.VK_ATTACHMENT_LOAD_OP_LOAD, #loadOp::VkAttachmentLoadOp
    result.storeOp = vk.VK_ATTACHMENT_STORE_OP_STORE, #storeOp::VkAttachmentStoreOp
    result.stencilLoadOp = vk.VK_ATTACHMENT_LOAD_OP_LOAD, #stencilLoadOp::VkAttachmentLoadOp
    result.stencilStoreOp = vk.VK_ATTACHMENT_STORE_OP_STORE, #stencilStoreOp::VkAttachmentStoreOp
    result.initialLayout = vk.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL, #initialLayout::VkImageLayout
    result.finalLayout = vk.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL #finalLayout::VkImageLayout
    commit(result)
    return result;
end

function createWithDepth16(::Type{AttachmentDescription})::AttachmentDescription
    result = AttachmentDescription()
    result.format = vk.VK_FORMAT_D16_UNORM, #format::VkFormat
    result.samples = vk.VK_SAMPLE_COUNT_1_BIT, #samples::VkSampleCountFlagBits
    result.loadOp = vk.VK_ATTACHMENT_LOAD_OP_CLEAR, #loadOp::VkAttachmentLoadOp
    result.storeOp = vk.VK_ATTACHMENT_STORE_OP_STORE, #storeOp::VkAttachmentStoreOp
    result.stencilLoadOp = vk.VK_ATTACHMENT_LOAD_OP_DONT_CARE, #stencilLoadOp::VkAttachmentLoadOp
    result.stencilStoreOp = vk.VK_ATTACHMENT_LOAD_OP_DONT_CARE, #stencilStoreOp::VkAttachmentStoreOp
    result.initialLayout = vk.VK_IMAGE_LAYOUT_UNDEFINED, #initialLayout::VkImageLayout
    result.finalLayout = vk.VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL #finalLayout::VkImageLayout
    commit(result)
    return result;
end

function createWithDepth32float(::Type{AttachmentDescription})::AttachmentDescription
    result = AttachmentDescription()
    result.format = vk.VK_FORMAT_D32_SFLOAT, #format::VkFormat
    result.samples = vk.VK_SAMPLE_COUNT_1_BIT, #samples::VkSampleCountFlagBits
    result.loadOp = vk.VK_ATTACHMENT_LOAD_OP_LOAD, #loadOp::VkAttachmentLoadOp
    result.storeOp = vk.VK_ATTACHMENT_STORE_OP_STORE, #storeOp::VkAttachmentStoreOp
    result.stencilLoadOp = vk.VK_ATTACHMENT_LOAD_OP_LOAD, #stencilLoadOp::VkAttachmentLoadOp
    result.stencilStoreOp = vk.VK_ATTACHMENT_STORE_OP_STORE, #stencilStoreOp::VkAttachmentStoreOp
    result.initialLayout = vk.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL, #initialLayout::VkImageLayout
    result.finalLayout = vk.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL #finalLayout::VkImageLayout
    commit(result)
    return result;
end

 function createWithColor(::Type{AttachmentDescription}, vkFormat::vk.VkFormat)::AttachmentDescription
    result = AttachmentDescription()
    result.format = vkFormat, #format::VkFormat
    result.samples = vk.VK_SAMPLE_COUNT_1_BIT, #samples::VkSampleCountFlagBits
    result.loadOp = vk.VK_ATTACHMENT_LOAD_OP_LOAD, #loadOp::VkAttachmentLoadOp
    result.storeOp = vk.VK_ATTACHMENT_STORE_OP_STORE, #storeOp::VkAttachmentStoreOp
    result.stencilLoadOp = vk.VK_ATTACHMENT_LOAD_OP_DONT_CARE, #stencilLoadOp::VkAttachmentLoadOp
    result.stencilStoreOp = vk.VK_ATTACHMENT_LOAD_OP_DONT_CARE, #stencilStoreOp::VkAttachmentStoreOp
    result.initialLayout = vk.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, #initialLayout::VkImageLayout
    result.finalLayout = vk.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL #finalLayout::VkImageLayout
    commit(result)
    return result;
end

function clear(this::AttachmentDescription)
    this.loadOp = vk.VK_ATTACHMENT_LOAD_OP_CLEAR
    this.stencilLoadOp = vk.VK_ATTACHMENT_LOAD_OP_CLEAR
    this.initialLayout = vk.VK_IMAGE_LAYOUT_UNDEFINED
end

function discard(this::AttachmentDescription)
    this.storeOp = vk.VK_ATTACHMENT_LOAD_OP_DONT_CARE
    this.stencilStoreOp = vk.VK_ATTACHMENT_LOAD_OP_DONT_CARE
    if aspectsOf(this.format) & vk.VK_IMAGE_ASPECT_COLOR_BIT != 0
        this.finalLayout = vk.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
    elseif aspectsOf(this.format) & vk.VK_IMAGE_ASPECT_DEPTH_BIT != 0
        this.finalLayout = vk.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
    end
end

function finalLayout(this::AttachmentDescription, layout::vk.VkImageLayout)
    this.finalLayout = layout
end

function getFormat(this::AttachmentDescription)::vk.VkFormat
    return this.mHandleRef[].format
end

function commit(this::AttachmentDescription)
    this.mHandleRef = Ref(vk.VkAttachmentDescription(
                            this.flags, #flags::VkAttachmentDescriptionFlags
                            this.format, #format::VkFormat
                            this.samples, #samples::VkSampleCountFlagBits
                            this.loadOp, #loadOp::VkAttachmentLoadOp
                            this.storeOp, #storeOp::VkAttachmentStoreOp
                            this.stencilLoadOp, #stencilLoadOp::VkAttachmentLoadOp
                            this.stencilStoreOp, #stencilStoreOp::VkAttachmentStoreOp
                            this.initialLayout, #initialLayout::VkImageLayout
                            this.finalLayout #finalLayout::VkImageLayout
    ))
end

function handleRef(this::AttachmentDescription)::Ref{vk.VkAttachmentDescription}
    return this.mHandleRef
end