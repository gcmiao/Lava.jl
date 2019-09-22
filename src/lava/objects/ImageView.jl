mutable struct ImageView
    mImage
    mCreateInfo::vk.VkImageViewCreateInfo
    mHandle::vk.VkImageView

    function ImageView(of, type::vk.VkImageViewType)
        imgInfo = of.mCreateInfo;

        range = vk.VkImageSubresourceRange(
            aspectsOf(imgInfo.format), #aspectMask::VkImageAspectFlags
            0, baseMipLevel::UInt32
            imgInfo.mipLevels, #levelCount::UInt32
            0, baseArrayLayer::UInt32
            imgInfo.arrayLayers, #layerCount::UInt32
        )
        return ImageView(of, type, range)
    end

    function ImageView(of, type::vk.VkImageViewType, range::vk.VkImageSubresourceRange)
        this = new()
        this.mImage = of

        imgInfo = of.mCreateInfo
        components = vk.VkComponentMapping(
            vk.VK_COMPONENT_SWIZZLE_IDENTITY, #r::VkComponentSwizzle
            vk.VK_COMPONENT_SWIZZLE_IDENTITY, #g::VkComponentSwizzle
            vk.VK_COMPONENT_SWIZZLE_IDENTITY, #b::VkComponentSwizzle
            vk.VK_COMPONENT_SWIZZLE_IDENTITY #a::VkComponentSwizzle
        )
        this.mCreateInfo = vk.VkImageViewCreateInfo(
            vk.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO, #sType::VkStructureType
            C_NULL, #pNext::Ptr{Cvoid}
            0, #flags::VkImageViewCreateFlags
            handle(of), #image::VkImage
            type, #viewType::VkImageViewType
            imgInfo.format, #format::VkFormat
            components, #components::VkComponentMapping
            range, #subresourceRange::VkImageSubresourceRange
        )

        mDevice = of->device().get();
        newImageView = Ref{vk.VkImageView}()
        if (vk.vkCreateImageView(logicalDevice, Ref(this.mCreateInfo), C_NULL, newImageView) != vk.VK_SUCCESS)
            error("Failed to create image view!")
        end
        this.mHandle = newImageView[]
        return this
    end
end