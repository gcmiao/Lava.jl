using Images

@enum ColorSpace begin
    Linear = 0
    sRGB
    AutoDetect
end

mutable struct ImageData
    mBytes
    mFormat::vk.VkFormat
    mExtent::vk.VkExtent3D
    mMipLevels::UInt32
    mLayers::UInt32
    mGenMipmaps::Bool

    function ImageData()
        this = new()
        this.mGenMipmaps = false
        return this
    end
  #   /// Creates ImageData (for a non-array image) from a pointer to the binary
  #   /// color values of the given format.
  #   /// Assumes the provided data to be the 0th mip level
  #   static SharedImageData
  #   createFromData(const void *data, uint32_t width, uint32_t height = 1,
  #                  uint32_t depth = 1,
  #                  vk::Format format = vk::Format::eR8G8B8A8Srgb);
  #
  #   /// Upload the image data as new image onto the given device.
  #   /// Uses the transfer-queue of the device.
  #   SharedImage uploadTo(lava::SharedDevice const &device) const;
  #   /// Upload the image data as new image onto the given device using the given
  #   /// queue.
  #   SharedImage uploadTo(lava::SharedDevice const &device,
  #                        lava::RecordingCommandBuffer &cmd) const;
  #
  #   void disableMipmapGen() { mGenMipmaps = false; }
  #
  #   void concatLayers(const void* data, uint32_t layers = 1);
  #
  # private:
  #   static SharedImageData loadWithLodepng(const std::string &filename,
  #                                          const std::string &,
  #                                          ColorSpace colorspace);
  #   static SharedImageData loadWithSTB(const std::string &filename,
  #                                      const std::string &,
  #                                      ColorSpace colorspace);
end
@class ImageData

function createFromFile(fileName::String, colorspace::ColorSpace = AutoDetect)::ImageData
    ending = lowercase(getExtName(fileName))
    img = load(fileName)
    height, width = size(img)
    rgbchs = channelview(img)
    rgba = fill!(Array{ColorTypes.RGBA{FixedPointNumbers.Normed{UInt16,16}},2}(undef, size(img)), RGBA(0.0f0, 0.0f0, 0.0f0, 1.0f0))
    rgbachs = channelview(rgba)
    rgbachs[1,:,:] = rgbchs[1,:,:]
    rgbachs[2,:,:] = rgbchs[2,:,:]
    rgbachs[3,:,:] = rgbchs[3,:,:]

    ret = ImageData()
    ret.mBytes = rgba
    ret.mExtent = vk.VkExtent3D(width, height, 1)
    ret.mLayers = 1
    ret.mMipLevels = 1
    ret.mGenMipmaps = true

    println("img:", typeof(img), summary(img))
    if (ending == ".hdr")
        # TODO Decide format according to meta data of the image
        ret.mFormat = vk.VK_FORMAT_R16G16B16A16_SFLOAT # vk.VK_FORMAT_R16G16B16_UNORM
    else
        if colorspace == Linear
            ret.mFormat = vk.VK_FORMAT_R8G8B8A8_UNORM
        else
            ret.mFormat = vk.VK_FORMAT_R8G8B8A8_SRGB
        end
    end

    return ret
end

# const dataFolder = "C:\\Codes\\Lava.jl\\examples\\HelloRTX\\data\\"
# envmap, data = createFromFile(dataFolder * "spruit_sunrise_4k.hdr")
# summary(envmap)
# size(envmap)
# typeof(envmap)
# eltype(envmap)

function uploadTo(this::ImageData, device::Device, cmd)::Image
    if (this.mExtent.depth == 1)
        vkPhyDevice = device.getPhysicalDevice()
        mipLevels = this.mGenMipmaps ? 0 : this.mMipLevels

        if (this.mLayers == 1)
            info = texture2D(vkPhyDevice, this.mExtent.width, this.mExtent.height, this.mFormat, mipLevels = mipLevels)
        else
            info = texture2DArray(vkPhyDevice, this.mExtent.width, this.mExtent.height, this.mLayers, this.mFormat, mipLevels = mipLevels)
        end
    else
        error("extent.depth = ", this.mExtent.depth, ", 3D Image is not supported yet.")
    end

    image = info.createImage(device)
    image.setDataVRAM(this.mBytes, cmd)

    if this.mGenMipmaps
        image.changeLayout(vk.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                           vk.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, cmd)
        image.generateMipmaps(cmd)
    end

    return image
end

function uploadTo(this::ImageData, device::Device)::Image
    cmd = device.graphicsQueue().beginCommandBuffer()
    ret = this.uploadTo(device, cmd)
    cmd.endCommandBuffer()
    return ret
end
