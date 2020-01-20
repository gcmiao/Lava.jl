struct SamplerCreateInfo
    mHandleRef::Ref{vk.VkSamplerCreateInfo}

    function SamplerCreateInfo(;
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkSamplerCreateFlags = vk.VkSamplerCreateFlags(0),
        magFilter::vk.VkFilter = vk.VK_FILTER_LINEAR,
        minFilter::vk.VkFilter = vk.VK_FILTER_NEAREST,
        mipmapMode::vk.VkSamplerMipmapMode = vk.VK_SAMPLER_MIPMAP_MODE_LINEAR,
        addressModeU::vk.VkSamplerAddressMode = vk.VK_SAMPLER_ADDRESS_MODE_REPEAT,
        addressModeV::vk.VkSamplerAddressMode = vk.VK_SAMPLER_ADDRESS_MODE_REPEAT,
        addressModeW::vk.VkSamplerAddressMode = vk.VK_SAMPLER_ADDRESS_MODE_REPEAT,
        mipLodBias::Cfloat = 0f0,
        anisotropyEnable::vk.VkBool32 = VkExt.VK_FALSE,
        maxAnisotropy::Cfloat = 1.0f0,
        compareEnable::vk.VkBool32 = VkExt.VK_FALSE,
        compareOp::vk.VkCompareOp = vk.VK_COMPARE_OP_NEVER,
        minLod::Cfloat = 0f0,
        maxLod::Cfloat = vk.VK_LOD_CLAMP_NONE,
        borderColor::vk.VkBorderColor = vk.VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK,
        unnormalizedCoordinates::vk.VkBool32 = VkExt.VK_FALSE
    )
        this = new(Ref(vk.VkSamplerCreateInfo(
            vk.VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO, # sType::VkStructureType
            pNext, # pNext::Ptr{Cvoid}
            flags, # flags::VkSamplerCreateFlags
            magFilter, # magFilter::VkFilter
            minFilter, # minFilter::VkFilter
            mipmapMode, # mipmapMode::VkSamplerMipmapMode
            addressModeU, # addressModeU::VkSamplerAddressMode
            addressModeV, # addressModeV::VkSamplerAddressMode
            addressModeW, # addressModeW::VkSamplerAddressMode
            mipLodBias, # mipLodBias::Cfloat
            anisotropyEnable, # anisotropyEnable::VkBool32
            maxAnisotropy, # maxAnisotropy::Cfloat
            compareEnable, # compareEnable::VkBool32
            compareOp, # compareOp::VkCompareOp
            minLod, # minLod::Cfloat
            maxLod, # maxLod::Cfloat
            borderColor, # borderColor::VkBorderColor
            unnormalizedCoordinates # unnormalizedCoordinates::VkBool32
        )))
    end
end

function handleRef(this::SamplerCreateInfo)
    return this.mHandleRef
end
