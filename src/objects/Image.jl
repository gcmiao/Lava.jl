export Image

mutable struct Image
    mHandle::vk.VkImage
    mType::vk.VkImageViewType
    mCreateInfo::vk.VkImageCreateInfo
    mUnowned::Bool
    mDevice::Device
    mMemory::MemoryChunk
    mKeepStagingBuffer::Bool

    function Image(device::Device, createInfo::vk.VkImageCreateInfo, type::vk.VkImageViewType)
        this = new()
        this.mDevice = device
        this.mType = type
        this.mCreateInfo = createInfo
        this.mUnowned = false
        this.mKeepStagingBuffer = false

        newImage = Ref{vk.VkImage}()
        infoRef = Ref(createInfo)
        GC.@preserve infoRef begin
            if (vk.vkCreateImage(getLogicalDevice(device), infoRef, C_NULL, newImage) != vk.VK_SUCCESS)
                error("Failed to create image!")
            end
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

@class Image [:handle, :destroy]

function destroy(this::Image)
    if (this.mUnowned)
        return
    end
    vk.vkDestroyImage(getLogicalDevice(this.mDevice), this.mHandle, C_NULL)
    destroy(this.mMemory)
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

function createImage(this::ImageCreateInfo, device::Device)::Image
    return Image(device, handleRef(this)[], this.mViewType)
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

function getWidth(this::Image)::UInt32
    return this.mCreateInfo.extent.width
end

function getHeight(this::Image)::UInt32
    return this.mCreateInfo.extent.height
end

function getDepth(this::Image)::UInt32
    return this.mCreateInfo.extent.depth
end

function getFormat(this::Image)::vk.VkFormat
    return this.mCreateInfo.format
end

function setDataVRAM(this::Image, data, cmd)
    this.realizeVRAM()

    num_bytes = this.getWidth() * this.getHeight() * this.getDepth() * bytePerPixel(this.mCreateInfo.format)
    if this.mMemory.isMappable()
        this.changeLayout(vk.VK_IMAGE_LAYOUT_GENERAL, cmd)
        mapped = this.mMemory.map()
        memmove(mapped.getData(), pointer(data), num_bytes)
        mapped.unmap()
    else
        staging = this.prepStagingBuffer(num_bytes)
        staging.setDataRAM(data, num_bytes) #TODO why don't use cmd?
        this.copyFrom(staging, cmd)
    end
end

function setDataVRAM(this::Image, data::Vector{T}) where T
    num_bytes = this.getWidth() * this.getHeight() * this.getDepth() * bytePerPixel(this.mCreateInfo.format)
    @assert (length(data) * sizeof(T) == num_bytes) "The size of the vector provided " *
                                                    "does not match the size of the image contents."

    # RecordingCommandBuffer::convenienceBufferCheck("Image::setDataVRAM()");
    this.realizeVRAM()

    if mMemory.mappable()
        cmd = this.mDevice.graphicsQueue().beginCommandBuffer()
        this.changeLayout(vk.VK_IMAGE_LAYOUT_GENERAL, cmd)

        mapped = this.mMemory.map()
        memmove(mapped.getData(), data, levelBytes())
        mapped.unmap()
        cmd.endCommandBuffer()
    else
        staging = this.prepStagingBuffer(levelBytes())
        staging.setDataRAM(data, levelBytes())

        cmd = this.mDevice.graphicsQueue().beginCommandBuffer()
        this.copyFrom(staging, cmd)
        cmd.endCommandBuffer()
    end
end

function setDataRAM(this::Image, data::Vector{T}) where T
    num_bytes = this.getWidth() * this.getHeight() * this.getDepth() * bytePerPixel(this.mCreateInfo.format)
    @assert (length(data) * sizeof(T) == num_bytes) "The size of the vector provided " *
                                                    "does not match the size of the image contents."
    this.realizeRAM()

    cmd = this.mDevice.graphicsQueue().beginCommandBuffer()
    this.changeLayout(vk.VK_IMAGE_LAYOUT_GENERAL, cmd)

    mapped = this.mMemory.map()
    memcpy(mapped.getData(), data, num_bytes)
    mapped.unmap()

    cmd.endCommandBuffer()
end

function getData(this::Image, outData::Vector, level::Integer)
    @assert isdefined(this, :mMemory) "Image needs to be realized to get data."

    staging = prepStagingBuffer(this.levelBytes(level))

    this.copyTo(staging, level)
    this.mDevice.graphicsQueue().catchUp(0)
    staging.getData(outData)
end

function realizeVRAM(this::Image)
    if (isdefined(this, :mMemory))
        return
    end

    req = VkExt.getImageMemoryRequirements(this.mDevice.getLogicalDevice(), this.mHandle)
    this.mMemory = this.mDevice.getSuballocator().allocate(req, VRAM)
    @assert (this.mMemory.getOffset() % req.alignment == 0)
    this.mMemory.bindToImage(this.mHandle)
end

function realizeRAM(this::Image)
    if (isdefined(this, :mMemory))
        return
    end

    req = VkExt.getImageMemoryRequirements(this.mDevice.getLogicalDevice(), this.mHandle)
    this.mMemory = this.mDevice.getSuballocator().allocate(req, RAM)
    @assert (this.mMemory.getOffset() % req.alignment == 0)
    this.mMemory.bindToImage(this.mHandle)
end

function copyFrom(this::Image, buffer::Buffer)
    # RecordingCommandBuffer::convenienceBufferCheck("Image::copyFrom()");
    cmd = this.mDevice.transferQueue().beginCommandBuffer()
    this.copyFrom(buffer, cmd)
    cmd.endCommandBuffer()
end

function copyFrom(this::Image, buffer::Buffer, cmd)
    this.changeLayout(vk.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, cmd)

    copies = [vk.VkBufferImageCopy(
        vk.VkDeviceSize(0), # bufferOffset::VkDeviceSize
        this.getWidth(), # bufferRowLength::UInt32
        this.getHeight(), # bufferImageHeight::UInt32
        vk.VkImageSubresourceLayers(
            aspectsOf(this.getFormat()), # aspectMask::VkImageAspectFlags
            UInt32(0), # mipLevel::UInt32
            UInt32(0), # baseArrayLayer::UInt32
            this.mCreateInfo.arrayLayers # layerCount::UInt32
        ), # imageSubresource::VkImageSubresourceLayers
        vk.VkOffset3D(Int32(0), Int32(0), Int32(0)), # imageOffset::VkOffset3D
        this.mCreateInfo.extent # imageExtent::VkExtent3D
    )]

    vk.vkCmdCopyBufferToImage(cmd.handle(), buffer.handle(), this.mHandle,
                              vk.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, pointer(copies))
    cmd.attachResource(buffer)
end

function copyFrom(this::Image, other::Image)
    # RecordingCommandBuffer::convenienceBufferCheck("Image::copyFrom()");
    cmd = this.mDevice.transferQueue().beginCommandBuffer()

    this.changeLayout(vk.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, cmd)

    subresource = vk.VkImageSubresourceLayers(
                        aspectsOf(this.mCreateInfo.format), # aspectMask::VkImageAspectFlags
                        UInt32(0), # mipLevel::UInt32
                        UInt32(0), # baseArrayLayer::UInt32
                        this.mCreateInfo.arrayLayers # layerCount::UInt32
                    )
    offset = vk.VkOffset3D(Int32(0), Int32(0), Int32(0))
    copies = vk.VkImageCopy(
        subresource, # srcSubresource::VkImageSubresourceLayers
        offset, # srcOffset::VkOffset3D
        subresource, # dstSubresource::VkImageSubresourceLayers
        offset, # dstOffset::VkOffset3D
        this.mCreateInfo.extent # extent::VkExtent3D
    )
    vk.vkCmdCopyImage(cmd.handle(), other.handle(), vk.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                      this.mHandle, vk.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, pointer(copies))
end

function copyTo(this::Image, buffer::Buffer, layer::Integer)
    # RecordingCommandBuffer::convenienceBufferCheck("Image::copyTo()");
    cmd = this.mDevice.transferQueue().beginCommandBuffer()
    this.copyTo(buffer, cmd, layer)
    cmd.endCommandBuffer()
end

function copyTo(this::Image, buffer::Buffer, cmd, level::Integer)
    @assert isdefined(this, :mMemory) "The Image needs to be realized to copy the data from it."

    copies = [vk.VkBufferImageCopy(
        vk.VkDeviceSize(0), # bufferOffset::VkDeviceSize
        max(1, this.mCreateInfo.extent.width >> level), # bufferRowLength::UInt32
        max(1, this.mCreateInfo.extent.height >> level), # bufferImageHeight::UInt32
        vk.VkImageSubresourceLayers(
            aspectsOf(this.mCreateInfo.format), # aspectMask::VkImageAspectFlags
            UInt32(level), # mipLevel::UInt32
            UInt32(0), # baseArrayLayer::UInt32
            this.mCreateInfo.arrayLayers # layerCount::UInt32
        ), # imageSubresource::VkImageSubresourceLayers
        vk.VkOffset3D(Int32(0), Int32(0), Int32(0)), # imageOffset::VkOffset3D
        this.mCreateInfo.extent # imageExtent::VkExtent3D
    )]

    vk.vkCmdCopyImageToBuffer(cmd.handle(), this.mHandle, vk.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                              buffer.handle(), 1, pointer(copies))
    cmd.attachResource(this)
end

function changeLayout(this::Image, from::vk.VkImageLayout, to::vk.VkImageLayout)
    # RecordingCommandBuffer::convenienceBufferCheck("Image::changeLayout()");
    cmd = this.mDevice.graphicsQueue().beginCommandBuffer()
    this.changeLayout(from, to, cmd)
    cmd.endCommandBuffer()
end

function changeLayout(this::Image, from::vk.VkImageLayout, to::vk.VkImageLayout, cmd)
    barrs = [vk.VkImageMemoryBarrier(
                vk.VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER, # sType::VkStructureType
                C_NULL, # pNext::Ptr{Cvoid}
                flagsForLayout(from), # srcAccessMask::VkAccessFlags
                flagsForLayout(to), # dstAccessMask::VkAccessFlags
                from, # oldLayout::VkImageLayout
                to, # newLayout::VkImageLayout
                vk.VK_QUEUE_FAMILY_IGNORED, # srcQueueFamilyIndex::UInt32
                vk.VK_QUEUE_FAMILY_IGNORED, # dstQueueFamilyIndex::UInt32
                this.mHandle, # image::VkImage
                vk.VkImageSubresourceRange(
                    aspectsOf(this.mCreateInfo.format), # aspectMask::VkImageAspectFlags
                    UInt32(0), # baseMipLevel::UInt32
                    this.mCreateInfo.mipLevels, # levelCount::UInt32
                    UInt32(0), # baseArrayLayer::UInt32
                    this.mCreateInfo.arrayLayers # layerCount::UInt32
                ) # subresourceRange::VkImageSubresourceRange
            )
    ]

    VkExt.vkCmdPipelineBarrier(cmd.handle(), stageForLayout(from), stageForLayout(to),
                               vk.VkFlags(0), imageMemoryBarriers = barrs)
end

function changeLayout(this::Image, to::vk.VkImageLayout, cmd)
    this.changeLayout(vk.VK_IMAGE_LAYOUT_UNDEFINED, to, cmd)
end

function changeLayout(this::Image, to::vk.VkImageLayout)
    this.changeLayout(vk.VK_IMAGE_LAYOUT_UNDEFINED, to)
end
# changeOwner

function barrierForGenerateMipmaps(this::Image, level::Integer, oldLayout::vk.VkImageLayout, newLayout::vk.VkImageLayout)
    barrier = vk.VkImageMemoryBarrier(
        vk.VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER, # sType::VkStructureType
        C_NULL, # pNext::Ptr{Cvoid}
        flagsForLayout(oldLayout), # srcAccessMask::VkAccessFlags
        flagsForLayout(newLayout), # dstAccessMask::VkAccessFlags
        oldLayout, # oldLayout::VkImageLayout
        newLayout, # newLayout::VkImageLayout
        UInt32(0), # srcQueueFamilyIndex::UInt32
        UInt32(0), # dstQueueFamilyIndex::UInt32
        this.mHandle, # image::VkImage
        vk.VkImageSubresourceRange(
            aspectsOf(this.mCreateInfo.format), # aspectMask::VkImageAspectFlags
            UInt32(level), # baseMipLevel::UInt32
            UInt32(1), # levelCount::UInt32
            UInt32(0), # baseArrayLayer::UInt32
            this.mCreateInfo.arrayLayers # layerCount::UInt32
        ) # subresourceRange::VkImageSubresourceRange
    )
end
function generateMipmaps(this::Image, cmd)
    props = VkExt.vkGetPhysicalDeviceFormatProperties(this.mDevice.getPhysicalDevice(), this.mCreateInfo.format)
    @assert (props.optimalTilingFeatures & vk.VK_FORMAT_FEATURE_BLIT_DST_BIT != 0) "Need to be able to blit to this image format."
    @assert (props.optimalTilingFeatures & vk.VK_FORMAT_FEATURE_BLIT_SRC_BIT != 0) "Need to be able to blit to this image format."

    or1 = x::UInt32 -> begin return max(x, 1) end

    for level = 1 : this.mCreateInfo.mipLevels - 1
        # change layout of target level
        barrier = barrierForGenerateMipmaps(this, level, vk.VK_IMAGE_LAYOUT_UNDEFINED, vk.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL)
        VkExt.vkCmdPipelineBarrier(cmd.handle(), vk.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, vk.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT,
                                   vk.VkFlags(0), imageMemoryBarriers = [barrier])

        blits = [vk.VkImageBlit(
            vk.VkImageSubresourceLayers(
                aspectsOf(this.mCreateInfo.format), # aspectMask::VkImageAspectFlags
                UInt32(level - 1), # mipLevel::UInt32
                UInt32(0), # baseArrayLayer::UInt32
                this.mCreateInfo.arrayLayers # layerCount::UInt32
            ), # srcSubresource::VkImageSubresourceLayers
            (vk.VkOffset3D(0, 0, 0),
             vk.VkOffset3D(or1(this.getWidth() >> (level - 1)),
                           or1(this.getHeight() >> (level - 1)),
                           or1(this.getDepth() >> (level - 1)))), # srcOffsets::NTuple{2, VkOffset3D}
            vk.VkImageSubresourceLayers(
                aspectsOf(this.mCreateInfo.format), # aspectMask::VkImageAspectFlags
                UInt32(level), # mipLevel::UInt32
                UInt32(0), # baseArrayLayer::UInt32
                this.mCreateInfo.arrayLayers # layerCount::UInt32
            ), # dstSubresource::VkImageSubresourceLayers
            (vk.VkOffset3D(0, 0, 0),
             vk.VkOffset3D(or1(this.getWidth() >> level),
                           or1(this.getHeight() >> level),
                           or1(this.getDepth() >> level))) # dstOffsets::NTuple{2, VkOffset3D}
        )]

        vk.vkCmdBlitImage(cmd.handle(), this.mHandle, vk.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                                        this.mHandle, vk.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                                        UInt32(1), pointer(blits), vk.VK_FILTER_LINEAR)

        barrier = barrierForGenerateMipmaps(this, level, vk.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, vk.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL)
        VkExt.vkCmdPipelineBarrier(cmd.handle(), vk.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, vk.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT,
                                   vk.VkFlags(0), imageMemoryBarriers = [barrier])

    end
    cmd.attachResource(this)
end
# createView
# changeOwnerImpl
function levelPixels(this::Image, layer::Integer)::Csize_t
    return max(1, this.mCreateInfo.extent.width >> layer) *
           max(1, this.mCreateInfo.extent.height >> layer) *
           max(1, this.mCreateInfo.extent.depth >> layer) *
           max(1, this.mCreateInfo.arrayLayers)
end

function levelBytes(this::Image, layer::Integer)::Csize_t
    return this.levelPixels(layer) * bytePerPixel(this.mCreateInfo.format)
end

function prepStagingBuffer(this::Image, size::Csize_t)::Buffer
    if isdefined(this, :mStagingBuffer)
        if this.mStagingBuffer.getSize() >= size
            return this.mStagingBuffer
        else
            this.mStagingBuffer.destroy()
        end
    end

    buf = this.mDevice.createBuffer(stagingBuffer(size, addUsage = vk.VK_BUFFER_USAGE_TRANSFER_DST_BIT))
    buf.realizeRAM()

    if this.mKeepStagingBuffer
        this.mStagingBuffer = buf
    end
    return buf
end

function keepStagingBuffer(this::Image, val::Bool = true)
    this.mKeepStagingBuffer = val
end
