export ImageView

mutable struct ImageView
    mImage::Image
    mCreateInfo::vk.VkImageViewCreateInfo
    mHandle::vk.VkImageView

    function ImageView(ofImg, type::vk.VkImageViewType)
        imgInfo = ofImg.mCreateInfo;
        range = vk.VkImageSubresourceRange(
            aspectsOf(imgInfo.format), #aspectMask::VkImageAspectFlags
            0, #baseMipLevel::UInt32
            imgInfo.mipLevels, #levelCount::UInt32
            0, #baseArrayLayer::UInt32
            imgInfo.arrayLayers #layerCount::UInt32
        )
        return ImageView(ofImg, type, range)
    end

    function ImageView(ofImg, type::vk.VkImageViewType, range::vk.VkImageSubresourceRange)
        this = new()
        this.mImage = ofImg
        imgInfo = ofImg.mCreateInfo
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
            handle(ofImg), #image::VkImage
            type, #viewType::VkImageViewType
            imgInfo.format, #format::VkFormat
            components, #components::VkComponentMapping
            range, #subresourceRange::VkImageSubresourceRange
        )

        newImageView = Ref{vk.VkImageView}()
        infoRef = Ref(this.mCreateInfo)
        GC.@preserve infoRef begin
            if (vk.vkCreateImageView(getLogicalDeviceOf(this.mImage), infoRef, C_NULL, newImageView) != vk.VK_SUCCESS)
                error("Failed to create image view!")
            end
        end
        this.mHandle = newImageView[]
        return this
    end
end

function destroy(this::ImageView)
    vk.vkDestroyImageView(getLogicalDeviceOf(this.mImage), this.mHandle, C_NULL)
end

function createView(image::Image, type::vk.VkImageViewType, range::vk.VkImageSubresourceRange = vk.VkImageSubresourceRange(0, 0, 0, 0, 0))
    if range == vk.VkImageSubresourceRange(0, 0, 0, 0, 0)
        return ImageView(image, type)
    end
    return ImageView(image, type, range)
end

function handle(this::ImageView)::vk.VkImageView
    return this.mHandle
end

function getImage(this::ImageView)::Image
    return this.mImage
end

function getLayers(this::ImageView)::UInt32
    return this.mCreateInfo.subresourceRange.layerCount
end