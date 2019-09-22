mutable struct Image
    mHandle::vk.VkImage
    mType::vk.VkImageViewType
    mCreateInfo::vk.VkImageCreateInfo
    mUnowned::Bool
    mDevice

    function Image(device, createInfo::vk.VkImageCreateInfo, type::vk.VkImageViewType)
        this = new()
        this.mDevice = device
        this.mType = type
        this.mCreateInfo = createInfo
        this.mUnowned = false
        
        features = usageToFeatures(createInfo.usage)
        props = Ref{vk.VkFormatProperties}()
        vk.vkGetPhysicalDeviceFormatProperties(getPhysicalDevice(device), createInfo.format, props)
        canUseOptimal = ((props.optimalTilingFeatures & features) == features)
        canUseLinear = ((props.linearTilingFeatures & features) == features)
        
        if (!canUseOptimal && createInfo.tiling == vk.VK_IMAGE_TILING_OPTIMAL)
            if (canUseLinear)
                println("The format selected for this image does not support optimal ",
                        "tiling for the required features, falling back to linear ",
                        "tiling.\n",
                        "In order to optimize performance, use a format that supports ",
                        "optimal tiling (e.g. use RGBA instead of RGB textures for ",
                        "attachments)\n",
                        "You can supress this warning by setting the tiling to linear ",
                        "yourself.")
                createInfo.tiling = vk.VK_IMAGE_TILING_LINEAR
            else
                error("The format selected can't provide the requested ",
                        "usages. Try another format (e.g. use RGBA ",
                        "instead of RGB for attachments)")
            end
        elseif (!canUseLinear && info.tiling == vk.VK_IMAGE_TILING_LINEAR)
            if (canUseOptimal)
                println("The format selected for this image does not support linear ",
                        "tiling for the required features, falling back to optimal ",
                        "tiling.\n",
                        "You can supress this warning by setting the tiling to optimal ",
                        "yourself.")
                createInfo.tiling = vk.VK_IMAGE_TILING_OPTIMAL
            else
                error("The format selected can't provide the requested ",
                        "usages. Try another format (e.g. use RGBA ",
                        "instead of RGB for attachments)")
            end
        end
        newImage = Ref{vk.VkImage}()
        if (vk.vkCreateImage(getLogicalDevice(device), createInfo, C_NULL, newImage) != vk.VK_SUCCESS)
            error("Failed to create image!")
        end
        mHandle = newImage[]
    end
    # Assumes that the Image is managed somewhere else (e.g. in a swapchain)
    # The ImageCreateInfo will not be used to actually create an image, but to
    # derive properties of the image (format, extend, ...)
    function Image(vkDevice::vk.VkDevice, createInfo::vk.VkImageCreateInfo, unowned::vk.VkImage type::vk.VkImageViewType)
        this = new()
        this.mVkDevice = vkDevice
        this.mType = type
        this.mCreateInfo = createInfo
        this.mHandle = unowned
        this.mUnowned = true
    end
end

function usageToFeatures(usage::vk.VkImageUsageFlags)::vk.VkFormatFeatureFlags
    result::vk.VkFormatFeatureFlags = 0
    if (usage & vk.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT != 0)
        result |= vk.VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BIT |
                  vk.VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BLEND_BIT
    end
    if (usage & vk.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT)
        result |= vk.VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT
    end
    if (usage & vk.VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT)
        result |= vk.VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BIT
    end
    if (usage & vk.VK_IMAGE_USAGE_SAMPLED_BIT)
        result |= vk.VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT
    end
    if (usage & vk.VK_IMAGE_USAGE_STORAGE_BIT)
        result |= vk.VK_FORMAT_FEATURE_STORAGE_IMAGE_BIT
    end
    if (usage & vk.VK_IMAGE_USAGE_TRANSFER_DST_BIT)
        # not sure if I should use this, because it's hidden behind an
        # extension
        # result |= vk.VK_FORMAT_FEATURE_TRANSFER_DST_BIT_KHR
    end
    if (usage & vk.VK_IMAGE_USAGE_TRANSFER_SRC_BIT)
        # not sure if I should use this, because it's hidden behind an
        # extension
        # result |= vk.VK_FORMAT_FEATURE_TRANSFER_SRC_BIT_KHR
    end
    return result;
end

function createView(this::Image)
    return createView(this, vk.VkImageSubresourceRange(0, 0, 0, 0, 0))
end

function createView(this::Image, range::vk.VkImageSubresourceRange)
    return createView(this, this.mType, range)
end

function createView(this::Image, type::vk.VkImageViewType)
    return createView(this, type, vk.VkImageSubresourceRange(0, 0, 0, 0, 0))
end

function createView(this::Image, type::vk.VkImageViewType, range::vk.VkImageSubresourceRange)
    if range == vk.VkImageSubresourceRange(0, 0, 0, 0, 0)
        return ImageView(this, type)
    end
    return ImageView(this, type, range)
end

function handle(this::Image)::vk.VkImage
    return this.mHandle
end