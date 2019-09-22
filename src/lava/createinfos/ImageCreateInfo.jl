struct ImageCreateInfo
    mHandleRef::Ref{vk.VkImageCreateInfo}
    mViewType::vk.VkImageViewType

    function ImageCreateInfo(;
        pNext = C_NULL, #::Ptr{Cvoid}
        flags = 0, #::VkImageCreateFlags
        imageType = vk.VK_IMAGE_TYPE_1D, #::VkImageType
        format = vk.VK_FORMAT_UNDEFINED, #::VkFormat
        extent = vk.VkExtent3D(0, 0, 0), #::VkExtent3D
        mipLevels = 0, #::UInt32
        arrayLayers = 0, #::UInt32
        samples = vk.VK_SAMPLE_COUNT_1_BIT, #::VkSampleCountFlagBits
        tiling = vk.VK_IMAGE_TILING_OPTIMAL, #::VkImageTiling
        usage = 0, #::VkImageUsageFlags
        sharingMode = vk.VK_SHARING_MODE_EXCLUSIVE, #::VkSharingMode
        queueFamilyIndexCount = 0, #::UInt32
        pQueueFamilyIndices = C_NULL, #::Ptr{UInt32}
        initialLayout = vk.VK_IMAGE_LAYOUT_UNDEFINED, #::VkImageLayout
        imageViewType = vk.VK_IMAGE_VIEW_TYPE_1D #vk.VkImageViewType
    )

    this = new(Ref(vk.VkImageCreateInfo(
        vk.VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
        pNext, #Ptr{Cvoid}
        flags, #VkImageCreateFlags
        imageType, #VkImageType
        format, #VkFormat
        extent, #VkExtent3D
        mipLevels, #UInt32
        arrayLayers, #UInt32
        samples, #VkSampleCountFlagBits
        tiling, #VkImageTiling
        usage, #VkImageUsageFlags
        sharingMode, #VkSharingMode
        queueFamilyIndexCount, #UInt32
        pQueueFamilyIndices, #Ptr{UInt32}
        initialLayout #VkImageLayout
    )), imageViewType)
end

function createImageCreateInfo(;others...)
    return ImageCreateInfo(initialLayout = vk.VK_IMAGE_LAYOUT_UNDEFINED,
                            mipLevels = 1, arrayLayers = 1,
                            samples = vk.VK_SAMPLE_COUNT_1_BIT,
                            sharingMode = vk.VK_SHARING_MODE_EXCLUSIVE,
                            tiling = vk.VK_IMAGE_TILING_OPTIMAL,
                            usage = vk.VK_IMAGE_USAGE_TRANSFER_DST_BIT | vk.VK_IMAGE_USAGE_TRANSFER_SRC_BIT)
end

function getCombinedType(viewType::vk.VkImageViewType)
    imgType = 0
    flags = 0
    if viewType == vk.VK_IMAGE_VIEW_TYPE_1D || viewType == vk.VK_IMAGE_VIEW_TYPE_1D_ARRAY
        imgType = vk.VK_IMAGE_TYPE_1D
    elseif viewType == vk.VK_IMAGE_VIEW_TYPE_CUBE || viewType == vk.VK_IMAGE_VIEW_TYPE_CUBE_ARRAY
        imgType = vk.VK_IMAGE_TYPE_2D
        flags |= vk.VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT
    elseif viewType == vk.VK_IMAGE_VIEW_TYPE_2D || viewType == vk.VK_IMAGE_VIEW_TYPE_2D_ARRAY
        imgType = vk.VK_IMAGE_TYPE_2D
    elseif viewType == vk.VK_IMAGE_VIEW_TYPE_3D
        imgType = vk.VK_IMAGE_TYPE_3D
    end

    return viewType, imgType, flags
end

function attachment2D(width::UInt32, height::UInt32, format::vk.VkFormat)::vk.VkImageCreateInfo
    viewType, imgType, flags = getCombinedType(vk.VK_IMAGE_VIEW_TYPE_2D)
    usage = vk.VK_IMAGE_USAGE_SAMPLED_BIT
    aspects = aspectsOf(format)
    if (aspects & vk.VK_IMAGE_ASPECT_DEPTH_BIT != 0 ||
        aspects & vk.VK_IMAGE_ASPECT_STENCIL_BIT != 0)
        usage |= vk.VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT
    end
    if (aspects & vk.VK_IMAGE_ASPECT_COLOR_BIT != 0)
        usage |= vk.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT
    end
    info = createImageCreateInfo(imageViewType = viewType, imageType = imgType, flags = flags,
                                format = format,
                                extent = vk.VkExtent3D(width, height, 1),
                                usage = usage)
    return info
}