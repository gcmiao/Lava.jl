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
end
@class ImageCreateInfo

function handleRef(this::ImageCreateInfo)::Ref{vk.VkImageCreateInfo}
    return this.mHandleRef
end

function createImageCreateInfo(vkPhyDevice::vk.VkPhysicalDevice;
                               usage = vk.VK_IMAGE_USAGE_TRANSFER_DST_BIT | vk.VK_IMAGE_USAGE_TRANSFER_SRC_BIT,
                               others...)
    usage |= vk.VK_IMAGE_USAGE_TRANSFER_DST_BIT | vk.VK_IMAGE_USAGE_TRANSFER_SRC_BIT
    tilingRef = Ref{vk.VkImageTiling}(vk.VK_IMAGE_TILING_OPTIMAL)
    if (vkPhyDevice != C_NULL)
        adaptTiling(vkPhyDevice, others[:format], usage, tilingRef)
    end

    return ImageCreateInfo(;initialLayout = vk.VK_IMAGE_LAYOUT_UNDEFINED,
                            mipLevels = 1, arrayLayers = 1,
                            samples = vk.VK_SAMPLE_COUNT_1_BIT,
                            sharingMode = vk.VK_SHARING_MODE_EXCLUSIVE,
                            tiling = tilingRef[],
                            usage = usage,
                            others...)
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

function adaptTiling(vkPhyDevice::vk.VkPhysicalDevice, format::vk.VkFormat, usage::vk.VkImageUsageFlags, tilingRef::Ref{vk.VkImageTiling})
    features = usageToFeatures(usage)
    props = Ref{vk.VkFormatProperties}()
    vk.vkGetPhysicalDeviceFormatProperties(vkPhyDevice, format, props)
    canUseOptimal = ((props[].optimalTilingFeatures & features) == features)
    canUseLinear = ((props[].linearTilingFeatures & features) == features)

    if (!canUseOptimal && tilingRef[] == vk.VK_IMAGE_TILING_OPTIMAL)
        if (canUseLinear)
            println("The format selected for this image does not support optimal ",
                    "tiling for the required features, falling back to linear ",
                    "tiling.\n",
                    "In order to optimize performance, use a format that supports ",
                    "optimal tiling (e.g. use RGBA instead of RGB textures for ",
                    "attachments)\n",
                    "You can supress this warning by setting the tiling to linear ",
                    "yourself.")
            tilingRef[] = vk.VK_IMAGE_TILING_LINEAR
        else
            error("The format selected can't provide the requested ",
                    "usages. Try another format (e.g. use RGBA ",
                    "instead of RGB for attachments)")
        end
    elseif (!canUseLinear && tilingRef[] == vk.VK_IMAGE_TILING_LINEAR)
        if (canUseOptimal)
            println("The format selected for this image does not support linear ",
                    "tiling for the required features, falling back to optimal ",
                    "tiling.\n",
                    "You can supress this warning by setting the tiling to optimal ",
                    "yourself.")
            tilingRef[] = vk.VK_IMAGE_TILING_OPTIMAL
        else
            error("The format selected can't provide the requested ",
                    "usages. Try another format (e.g. use RGBA ",
                    "instead of RGB for attachments)")
        end
    end
end

function attachment2D(vkPhyDevice::vk.VkPhysicalDevice,
                    width::Integer, height::Integer, format::vk.VkFormat)::ImageCreateInfo
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

    info = createImageCreateInfo(vkPhyDevice, imageViewType = viewType, imageType = imgType, flags = flags,
                                format = format,
                                extent = vk.VkExtent3D(width, height, 1),
                                usage = usage)
    return info
end
