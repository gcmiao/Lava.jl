struct SamplerCreateInfo
    mHandleRef::Ref{vk.VkSamplerCreateInfo}

    function SamplerCreateInfo(;
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkSamplerCreateFlags = vk.VkSamplerCreateFlags(0),
        magFilter::vk.VkFilter = vk.VK_FILTER_LINEAR,
        minFilter::vk.VkFilter = vk.VK_FILTER_LINEAR,
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
        if unnormalizedCoordinates == vk.VK_TRUE
            maxLod = minLod = 0
            mipmapMode = vk.VK_SAMPLER_MIPMAP_MODE_NEAREST
            addressModeU = addressModeV = addressModeW = vk.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER
        end
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
        return this
    end
end
@class SamplerCreateInfo

function handleRef(this::SamplerCreateInfo)::Ref{vk.VkSamplerCreateInfo}
    return this.mHandleRef
end

# a non-shadow depth sampler
function depth(::Type{SamplerCreateInfo})::SamplerCreateInfo
    ret = SamplerCreateInfo(
        addressModeU = vk.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
        addressModeV = vk.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
        addressModeW = vk.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
        borderColor = vk.VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE
    )
    return ret
end

# a shadow sampler that
function shadow(::Type{SamplerCreateInfo})::SamplerCreateInfo
    ret = SamplerCreateInfo(
        addressModeU = vk.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
        addressModeV = vk.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
        addressModeW = vk.VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER,
        borderColor = vk.VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE,
        compareEnable = VkExt.VK_TRUE,
        compareOp = vk.VK_COMPARE_OP_GREATER_OR_EQUAL
    )
    return ret
end
