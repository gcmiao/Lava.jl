function flagsForLayout(layout::vk.VkImageLayout)::vk.VkAccessFlags
    if layout == vk.VK_IMAGE_LAYOUT_UNDEFINED
        return vk.VkFlags(0)
    elseif layout == vk.VK_IMAGE_LAYOUT_GENERAL
        return vk.VK_ACCESS_SHADER_READ_BIT |
               vk.VK_ACCESS_SHADER_WRITE_BIT |
               vk.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT |
               vk.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT |
               vk.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT |
               vk.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT |
               vk.VK_ACCESS_TRANSFER_READ_BIT |
               vk.VK_ACCESS_TRANSFER_WRITE_BIT |
               vk.VK_ACCESS_HOST_READ_BIT |
               vk.VK_ACCESS_HOST_WRITE_BIT |
               vk.VK_ACCESS_MEMORY_READ_BIT |
               vk.VK_ACCESS_MEMORY_WRITE_BIT
    elseif layout == vk.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
        return vk.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT
    elseif layout == vk.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
        return vk.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT
    elseif layout == vk.VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL
        return vk.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT
    elseif layout == vk.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
        return vk.VK_ACCESS_SHADER_READ_BIT
    elseif layout == vk.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL
        return vk.VK_ACCESS_TRANSFER_READ_BIT
    elseif layout == vk.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL
        return vk.VK_ACCESS_TRANSFER_WRITE_BIT
    elseif layout == vk.VK_IMAGE_LAYOUT_PREINITIALIZED
        return vk.VK_ACCESS_HOST_WRITE_BIT
    elseif layout == vk.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR ||
           layout == vk.VK_IMAGE_LAYOUT_SHARED_PRESENT_KHR
        return vk.VkFlags(0)
    elseif layout == vk.VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL
        return vk.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT |
               vk.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT
    elseif layout == vk.VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL
        return vk.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT |
               vk.VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT
    else
        return vk.VkFlags(0)
    end
end

function stageForLayout(layout::vk.VkImageLayout)::vk.VkPipelineStageFlagBits
    if layout == vk.VK_IMAGE_LAYOUT_GENERAL
        return vk.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT
    elseif layout == vk.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
        return vk.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
    elseif layout == vk.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL ||
           layout == vk.VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL
        return vk.VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT
    elseif layout == vk.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
        return vk.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT
    elseif layout == vk.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL ||
           layout == vk.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL
        return vk.VK_PIPELINE_STAGE_TRANSFER_BIT
    elseif layout == vk.VK_IMAGE_LAYOUT_PREINITIALIZED
        return vk.VK_PIPELINE_STAGE_HOST_BIT
    else
        return vk.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT
    end
end
