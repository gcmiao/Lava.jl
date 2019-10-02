mutable struct Image
    mHandle::vk.VkImage
    mType::vk.VkImageViewType
    mCreateInfo::vk.VkImageCreateInfo
    mUnowned::Bool
    mDevice::Device
    mMemory::MemoryChunk

    function Image(device::Device, createInfo::vk.VkImageCreateInfo, type::vk.VkImageViewType)
        this = new()
        this.mDevice = device
        this.mType = type
        this.mCreateInfo = createInfo
        this.mUnowned = false
        
        newImage = Ref{vk.VkImage}()
        if (vk.vkCreateImage(getLogicalDevice(device), Ref(createInfo), C_NULL, newImage) != vk.VK_SUCCESS)
            error("Failed to create image!")
        end
        this.mHandle = newImage[]
        return this
    end
    # Assumes that the Image is managed somewhere else (e.g. in a swapchain)
    # The ImageCreateInfo will not be used to actually create an image, but to
    # derive properties of the image (format, extend, ...)
    function Image(device::Device, createInfo::vk.VkImageCreateInfo, unowned::vk.VkImage, type::vk.VkImageViewType)
        this = new()
        this.mDevice = device
        this.mType = type
        this.mCreateInfo = createInfo
        this.mHandle = unowned
        this.mUnowned = true
        return this
    end
end

function usageToFeatures(usage::vk.VkImageUsageFlags)::vk.VkFormatFeatureFlags
    result::vk.VkFormatFeatureFlags = 0
    if (usage & vk.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT != 0)
        result |= vk.VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BIT |
                  vk.VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BLEND_BIT
    end
    if (usage & vk.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT != 0)
        result |= vk.VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT
    end
    if (usage & vk.VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT != 0)
        result |= vk.VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BIT
    end
    if (usage & vk.VK_IMAGE_USAGE_SAMPLED_BIT != 0)
        result |= vk.VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT
    end
    if (usage & vk.VK_IMAGE_USAGE_STORAGE_BIT != 0)
        result |= vk.VK_FORMAT_FEATURE_STORAGE_IMAGE_BIT
    end
    if (usage & vk.VK_IMAGE_USAGE_TRANSFER_DST_BIT != 0)
        # not sure if I should use this, because it's hidden behind an
        # extension
        # result |= vk.VK_FORMAT_FEATURE_TRANSFER_DST_BIT_KHR
    end
    if (usage & vk.VK_IMAGE_USAGE_TRANSFER_SRC_BIT != 0)
        # not sure if I should use this, because it's hidden behind an
        # extension
        # result |= vk.VK_FORMAT_FEATURE_TRANSFER_SRC_BIT_KHR
    end
    return result;
end

function createImage(createInfo::ImageCreateInfo, device::Device)::Image
    return Image(device, handleRef(createInfo)[], createInfo.mViewType)
end

function createView(this::Image, range::vk.VkImageSubresourceRange = vk.VkImageSubresourceRange(0, 0, 0, 0, 0))
    return createView(this, this.mType, range)
end

function handle(this::Image)::vk.VkImage
    return this.mHandle
end

function getLogicalDeviceOf(this::Image)::vk.VkDevice
    return getLogicalDevice(this.mDevice)
end

function realizeAttachment(this::Image)
    req = VkExt.getImageMemoryRequirements(getLogicalDevice(this.mDevice), this.mHandle)
    this.mMemory = allocateDedicated(this.mDevice.mSuballocator, req, VRAM)
    bindToImage(this.mMemory, this.mHandle)
end
