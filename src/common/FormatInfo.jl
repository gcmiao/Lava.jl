using StaticArrays

function aspectsOf(format::vk.VkFormat)::vk.VkImageAspectFlags
    if format == vk.VK_FORMAT_UNDEFINED
        return 0
    elseif format == vk.VK_FORMAT_R4G4_UNORM_PACK8 ||
            format == vk.VK_FORMAT_R4G4B4A4_UNORM_PACK16 ||
            format == vk.VK_FORMAT_B4G4R4A4_UNORM_PACK16 ||
            format == vk.VK_FORMAT_R5G6B5_UNORM_PACK16 ||
            format == vk.VK_FORMAT_B5G6R5_UNORM_PACK16 ||
            format == vk.VK_FORMAT_R5G5B5A1_UNORM_PACK16 ||
            format == vk.VK_FORMAT_B5G5R5A1_UNORM_PACK16 ||
            format == vk.VK_FORMAT_A1R5G5B5_UNORM_PACK16 ||
            format == vk.VK_FORMAT_R8_UNORM ||
            format == vk.VK_FORMAT_R8_SNORM ||
            format == vk.VK_FORMAT_R8_USCALED ||
            format == vk.VK_FORMAT_R8_SSCALED ||
            format == vk.VK_FORMAT_R8_UINT ||
            format == vk.VK_FORMAT_R8_SINT ||
            format == vk.VK_FORMAT_R8_SRGB ||
            format == vk.VK_FORMAT_R8G8_UNORM ||
            format == vk.VK_FORMAT_R8G8_SNORM ||
            format == vk.VK_FORMAT_R8G8_USCALED ||
            format == vk.VK_FORMAT_R8G8_SSCALED ||
            format == vk.VK_FORMAT_R8G8_UINT ||
            format == vk.VK_FORMAT_R8G8_SINT ||
            format == vk.VK_FORMAT_R8G8_SRGB ||
            format == vk.VK_FORMAT_R8G8B8_UNORM ||
            format == vk.VK_FORMAT_R8G8B8_SNORM ||
            format == vk.VK_FORMAT_R8G8B8_USCALED ||
            format == vk.VK_FORMAT_R8G8B8_SSCALED ||
            format == vk.VK_FORMAT_R8G8B8_UINT ||
            format == vk.VK_FORMAT_R8G8B8_SINT ||
            format == vk.VK_FORMAT_R8G8B8_SRGB ||
            format == vk.VK_FORMAT_B8G8R8_UNORM ||
            format == vk.VK_FORMAT_B8G8R8_SNORM ||
            format == vk.VK_FORMAT_B8G8R8_USCALED ||
            format == vk.VK_FORMAT_B8G8R8_SSCALED ||
            format == vk.VK_FORMAT_B8G8R8_UINT ||
            format == vk.VK_FORMAT_B8G8R8_SINT ||
            format == vk.VK_FORMAT_B8G8R8_SRGB ||
            format == vk.VK_FORMAT_R8G8B8A8_UNORM ||
            format == vk.VK_FORMAT_R8G8B8A8_SNORM  ||
            format == vk.VK_FORMAT_R8G8B8A8_USCALED ||
            format == vk.VK_FORMAT_R8G8B8A8_SSCALED ||
            format == vk.VK_FORMAT_R8G8B8A8_UINT ||
            format == vk.VK_FORMAT_R8G8B8A8_SINT ||
            format == vk.VK_FORMAT_R8G8B8A8_SRGB ||
            format == vk.VK_FORMAT_B8G8R8A8_UNORM ||
            format == vk.VK_FORMAT_B8G8R8A8_SNORM ||
            format == vk.VK_FORMAT_B8G8R8A8_USCALED ||
            format == vk.VK_FORMAT_B8G8R8A8_SSCALED ||
            format == vk.VK_FORMAT_B8G8R8A8_UINT ||
            format == vk.VK_FORMAT_B8G8R8A8_SINT ||
            format == vk.VK_FORMAT_B8G8R8A8_SRGB ||
            format == vk.VK_FORMAT_A8B8G8R8_UNORM_PACK32 ||
            format == vk.VK_FORMAT_A8B8G8R8_SNORM_PACK32 ||
            format == vk.VK_FORMAT_A8B8G8R8_USCALED_PACK32 ||
            format == vk.VK_FORMAT_A8B8G8R8_SSCALED_PACK32 ||
            format == vk.VK_FORMAT_A8B8G8R8_UINT_PACK32 ||
            format == vk.VK_FORMAT_A8B8G8R8_SINT_PACK32 ||
            format == vk.VK_FORMAT_A8B8G8R8_SRGB_PACK32 ||
            format == vk.VK_FORMAT_A2R10G10B10_UNORM_PACK32 ||
            format == vk.VK_FORMAT_A2R10G10B10_SNORM_PACK32 ||
            format == vk.VK_FORMAT_A2R10G10B10_USCALED_PACK32 ||
            format == vk.VK_FORMAT_A2R10G10B10_SSCALED_PACK32 ||
            format == vk.VK_FORMAT_A2R10G10B10_UINT_PACK32 ||
            format == vk.VK_FORMAT_A2R10G10B10_SINT_PACK32 ||
            format == vk.VK_FORMAT_A2B10G10R10_UNORM_PACK32 ||
            format == vk.VK_FORMAT_A2B10G10R10_SNORM_PACK32 ||
            format == vk.VK_FORMAT_A2B10G10R10_USCALED_PACK32 ||
            format == vk.VK_FORMAT_A2B10G10R10_SSCALED_PACK32 ||
            format == vk.VK_FORMAT_A2B10G10R10_UINT_PACK32 ||
            format == vk.VK_FORMAT_A2B10G10R10_SINT_PACK32 ||
            format == vk.VK_FORMAT_R16_UNORM ||
            format == vk.VK_FORMAT_R16_SNORM ||
            format == vk.VK_FORMAT_R16_USCALED ||
            format == vk.VK_FORMAT_R16_SSCALED ||
            format == vk.VK_FORMAT_R16_UINT ||
            format == vk.VK_FORMAT_R16_SINT ||
            format == vk.VK_FORMAT_R16_SFLOAT ||
            format == vk.VK_FORMAT_R16G16_UNORM ||
            format == vk.VK_FORMAT_R16G16_SNORM ||
            format == vk.VK_FORMAT_R16G16_USCALED ||
            format == vk.VK_FORMAT_R16G16_SSCALED ||
            format == vk.VK_FORMAT_R16G16_UINT ||
            format == vk.VK_FORMAT_R16G16_SINT ||
            format == vk.VK_FORMAT_R16G16_SFLOAT ||
            format == vk.VK_FORMAT_R16G16B16_UNORM ||
            format == vk.VK_FORMAT_R16G16B16_SNORM ||
            format == vk.VK_FORMAT_R16G16B16_USCALED ||
            format == vk.VK_FORMAT_R16G16B16_SSCALED ||
            format == vk.VK_FORMAT_R16G16B16_UINT ||
            format == vk.VK_FORMAT_R16G16B16_SINT ||
            format == vk.VK_FORMAT_R16G16B16_SFLOAT ||
            format == vk.VK_FORMAT_R16G16B16A16_UNORM ||
            format == vk.VK_FORMAT_R16G16B16A16_SNORM ||
            format == vk.VK_FORMAT_R16G16B16A16_USCALED ||
            format == vk.VK_FORMAT_R16G16B16A16_SSCALED ||
            format == vk.VK_FORMAT_R16G16B16A16_UINT ||
            format == vk.VK_FORMAT_R16G16B16A16_SINT ||
            format == vk.VK_FORMAT_R16G16B16A16_SFLOAT ||
            format == vk.VK_FORMAT_R32_UINT ||
            format == vk.VK_FORMAT_R32_SINT ||
            format == vk.VK_FORMAT_R32_SFLOAT ||
            format == vk.VK_FORMAT_R32G32_UINT ||
            format == vk.VK_FORMAT_R32G32_SINT ||
            format == vk.VK_FORMAT_R32G32_SFLOAT ||
            format == vk.VK_FORMAT_R32G32B32_UINT ||
            format == vk.VK_FORMAT_R32G32B32_SINT ||
            format == vk.VK_FORMAT_R32G32B32_SFLOAT ||
            format == vk.VK_FORMAT_R32G32B32A32_UINT ||
            format == vk.VK_FORMAT_R32G32B32A32_SINT ||
            format == vk.VK_FORMAT_R32G32B32A32_SFLOAT ||
            format == vk.VK_FORMAT_R64_UINT ||
            format == vk.VK_FORMAT_R64_SINT ||
            format == vk.VK_FORMAT_R64_SFLOAT ||
            format == vk.VK_FORMAT_R64G64_UINT ||
            format == vk.VK_FORMAT_R64G64_SINT ||
            format == vk.VK_FORMAT_R64G64_SFLOAT ||
            format == vk.VK_FORMAT_R64G64B64_UINT ||
            format == vk.VK_FORMAT_R64G64B64_SINT ||
            format == vk.VK_FORMAT_R64G64B64_SFLOAT ||
            format == vk.VK_FORMAT_R64G64B64A64_UINT ||
            format == vk.VK_FORMAT_R64G64B64A64_SINT ||
            format == vk.VK_FORMAT_R64G64B64A64_SFLOAT ||
            format == vk.VK_FORMAT_B10G11R11_UFLOAT_PACK32 ||
            format == vk.VK_FORMAT_E5B9G9R9_UFLOAT_PACK32
        return vk.VK_IMAGE_ASPECT_COLOR_BIT
    elseif format == vk.VK_FORMAT_D16_UNORM ||
            format == vk.VK_FORMAT_X8_D24_UNORM_PACK32 ||
            format == vk.VK_FORMAT_D32_SFLOAT
        return vk.VK_IMAGE_ASPECT_DEPTH_BIT
    elseif format == vk.VK_FORMAT_S8_UINT
        return vk.VK_IMAGE_ASPECT_STENCIL_BIT
    elseif format == vk.VK_FORMAT_D16_UNORM_S8_UINT ||
            format == vk.VK_FORMAT_D24_UNORM_S8_UINT ||
            format == vk.VK_FORMAT_D32_SFLOAT_S8_UINT
        return vk.VK_IMAGE_ASPECT_DEPTH_BIT | vk.VK_IMAGE_ASPECT_STENCIL_BIT
    elseif format == vk.VK_FORMAT_BC1_RGB_UNORM_BLOCK ||
            format == vk.VK_FORMAT_BC1_RGB_SRGB_BLOCK ||
            format == vk.VK_FORMAT_BC1_RGBA_UNORM_BLOCK ||
            format == vk.VK_FORMAT_BC1_RGBA_SRGB_BLOCK ||
            format == vk.VK_FORMAT_BC2_UNORM_BLOCK ||
            format == vk.VK_FORMAT_BC2_SRGB_BLOCK ||
            format == vk.VK_FORMAT_BC3_UNORM_BLOCK ||
            format == vk.VK_FORMAT_BC3_SRGB_BLOCK ||
            format == vk.VK_FORMAT_BC4_UNORM_BLOCK ||
            format == vk.VK_FORMAT_BC4_SNORM_BLOCK ||
            format == vk.VK_FORMAT_BC5_UNORM_BLOCK ||
            format == vk.VK_FORMAT_BC5_SNORM_BLOCK ||
            format == vk.VK_FORMAT_BC6H_UFLOAT_BLOCK ||
            format == vk.VK_FORMAT_BC6H_SFLOAT_BLOCK ||
            format == vk.VK_FORMAT_BC7_UNORM_BLOCK ||
            format == vk.VK_FORMAT_BC7_SRGB_BLOCK ||
            format == vk.VK_FORMAT_ETC2_R8G8B8_UNORM_BLOCK ||
            format == vk.VK_FORMAT_ETC2_R8G8B8_SRGB_BLOCK ||
            format == vk.VK_FORMAT_ETC2_R8G8B8A1_UNORM_BLOCK ||
            format == vk.VK_FORMAT_ETC2_R8G8B8A1_SRGB_BLOCK ||
            format == vk.VK_FORMAT_ETC2_R8G8B8A8_UNORM_BLOCK ||
            format == vk.VK_FORMAT_ETC2_R8G8B8A8_SRGB_BLOCK ||
            format == vk.VK_FORMAT_EAC_R11_UNORM_BLOCK ||
            format == vk.VK_FORMAT_EAC_R11_SNORM_BLOCK ||
            format == vk.VK_FORMAT_EAC_R11G11_UNORM_BLOCK ||
            format == vk.VK_FORMAT_EAC_R11G11_SNORM_BLOCK ||
            format == vk.VK_FORMAT_ASTC_4x4_UNORM_BLOCK ||
            format == vk.VK_FORMAT_ASTC_4x4_SRGB_BLOCK ||
            format == vk.VK_FORMAT_ASTC_5x4_UNORM_BLOCK ||
            format == vk.VK_FORMAT_ASTC_5x4_SRGB_BLOCK ||
            format == vk.VK_FORMAT_ASTC_5x5_UNORM_BLOCK ||
            format == vk.VK_FORMAT_ASTC_5x5_SRGB_BLOCK ||
            format == vk.VK_FORMAT_ASTC_6x5_UNORM_BLOCK ||
            format == vk.VK_FORMAT_ASTC_6x5_SRGB_BLOCK ||
            format == vk.VK_FORMAT_ASTC_6x6_UNORM_BLOCK ||
            format == vk.VK_FORMAT_ASTC_6x6_SRGB_BLOCK ||
            format == vk.VK_FORMAT_ASTC_8x5_UNORM_BLOCK ||
            format == vk.VK_FORMAT_ASTC_8x5_SRGB_BLOCK ||
            format == vk.VK_FORMAT_ASTC_8x6_UNORM_BLOCK ||
            format == vk.VK_FORMAT_ASTC_8x6_SRGB_BLOCK ||
            format == vk.VK_FORMAT_ASTC_8x8_UNORM_BLOCK ||
            format == vk.VK_FORMAT_ASTC_8x8_SRGB_BLOCK ||
            format == vk.VK_FORMAT_ASTC_10x5_UNORM_BLOCK ||
            format == vk.VK_FORMAT_ASTC_10x5_SRGB_BLOCK ||
            format == vk.VK_FORMAT_ASTC_10x6_UNORM_BLOCK ||
            format == vk.VK_FORMAT_ASTC_10x6_SRGB_BLOCK ||
            format == vk.VK_FORMAT_ASTC_10x8_UNORM_BLOCK ||
            format == vk.VK_FORMAT_ASTC_10x8_SRGB_BLOCK ||
            format == vk.VK_FORMAT_ASTC_10x10_UNORM_BLOCK ||
            format == vk.VK_FORMAT_ASTC_10x10_SRGB_BLOCK ||
            format == vk.VK_FORMAT_ASTC_12x10_UNORM_BLOCK ||
            format == vk.VK_FORMAT_ASTC_12x10_SRGB_BLOCK ||
            format == vk.VK_FORMAT_ASTC_12x12_UNORM_BLOCK ||
            format == vk.VK_FORMAT_ASTC_12x12_SRGB_BLOCK ||
            format == vk.VK_FORMAT_PVRTC1_2BPP_UNORM_BLOCK_IMG ||
            format == vk.VK_FORMAT_PVRTC1_4BPP_UNORM_BLOCK_IMG ||
            format == vk.VK_FORMAT_PVRTC2_2BPP_UNORM_BLOCK_IMG ||
            format == vk.VK_FORMAT_PVRTC2_4BPP_UNORM_BLOCK_IMG ||
            format == vk.VK_FORMAT_PVRTC1_2BPP_SRGB_BLOCK_IMG ||
            format == vk.VK_FORMAT_PVRTC1_4BPP_SRGB_BLOCK_IMG ||
            format == vk.VK_FORMAT_PVRTC2_2BPP_SRGB_BLOCK_IMG ||
            format == vk.VK_FORMAT_PVRTC2_4BPP_SRGB_BLOCK_IMG
        return vk.VK_IMAGE_ASPECT_COLOR_BIT
    else
        error("lava/common/FormatInfo lava::aspectsOf(): Unknown ", format, ", assuming color.")
    end
    return vk.VK_IMAGE_ASPECT_COLOR_BIT
end

const TYPE_TO_VK_FORMAT_MAP = Dict([
    (Vec{1, UInt8}, vk.VK_FORMAT_R8_UNORM),
    (Vec{2, UInt8}, vk.VK_FORMAT_R8G8_UNORM),
    (Vec{3, UInt8}, vk.VK_FORMAT_R8G8B8_UNORM),
    (Vec{4, UInt8}, vk.VK_FORMAT_R8G8B8A8_UNORM),
    (Vec{1, Int8}, vk.VK_FORMAT_R8_SNORM),
    (Vec{2, Int8}, vk.VK_FORMAT_R8G8_SNORM),
    (Vec{3, Int8}, vk.VK_FORMAT_R8G8B8_SNORM),
    (Vec{4, Int8}, vk.VK_FORMAT_R8G8B8A8_SNORM),
    (Vec{1, UInt32}, vk.VK_FORMAT_R32_UINT),
    (Vec{2, UInt32}, vk.VK_FORMAT_R32G32_UINT),
    (Vec{3, UInt32}, vk.VK_FORMAT_R32G32B32_UINT),
    (Vec{4, UInt32}, vk.VK_FORMAT_R32G32B32A32_UINT),
    (Vec{1, Int32}, vk.VK_FORMAT_R32_SINT),
    (Vec{2, Int32}, vk.VK_FORMAT_R32G32_SINT),
    (Vec{3, Int32}, vk.VK_FORMAT_R32G32B32_SINT),
    (Vec{4, Int32}, vk.VK_FORMAT_R32G32B32A32_SINT),
    (Vec{1, Float32}, vk.VK_FORMAT_R32_SFLOAT),
    (Vec{2, Float32}, vk.VK_FORMAT_R32G32_SFLOAT),
    (Vec{3, Float32}, vk.VK_FORMAT_R32G32B32_SFLOAT),
    (Vec{4, Float32}, vk.VK_FORMAT_R32G32B32A32_SFLOAT)
])
function vkTypeOfFormat(type)::vk.VkFormat
    return get(TYPE_TO_VK_FORMAT_MAP, type, vk.VK_FORMAT_UNDEFINED)
end

function bytePerPixel(format::vk.VkFormat)::Csize_t
    if format == vk.VK_FORMAT_UNDEFINED
        return 0
    elseif format == vk.VK_FORMAT_R4G4_UNORM_PACK8
        return 1
    elseif format == vk.VK_FORMAT_R4G4B4A4_UNORM_PACK16 ||
        format == vk.VK_FORMAT_B4G4R4A4_UNORM_PACK16 ||
        format == vk.VK_FORMAT_R5G6B5_UNORM_PACK16 ||
        format == vk.VK_FORMAT_B5G6R5_UNORM_PACK16 ||
        format == vk.VK_FORMAT_R5G5B5A1_UNORM_PACK16 ||
        format == vk.VK_FORMAT_B5G5R5A1_UNORM_PACK16 ||
        format == vk.VK_FORMAT_A1R5G5B5_UNORM_PACK16
        return 2
    elseif format == vk.VK_FORMAT_R8_UNORM ||
        format == vk.VK_FORMAT_R8_SNORM ||
        format == vk.VK_FORMAT_R8_USCALED ||
        format == vk.VK_FORMAT_R8_SSCALED ||
        format == vk.VK_FORMAT_R8_UINT ||
        format == vk.VK_FORMAT_R8_SINT ||
        format == vk.VK_FORMAT_R8_SRGB
        return 1
    elseif format == vk.VK_FORMAT_R8G8_UNORM ||
        format == vk.VK_FORMAT_R8G8_SNORM ||
        format == vk.VK_FORMAT_R8G8_USCALED ||
        format == vk.VK_FORMAT_R8G8_SSCALED ||
        format == vk.VK_FORMAT_R8G8_UINT ||
        format == vk.VK_FORMAT_R8G8_SINT ||
        format == vk.VK_FORMAT_R8G8_SRGB
        return 2
    elseif format == vk.VK_FORMAT_R8G8B8_UNORM ||
        format == vk.VK_FORMAT_R8G8B8_SNORM ||
        format == vk.VK_FORMAT_R8G8B8_USCALED ||
        format == vk.VK_FORMAT_R8G8B8_SSCALED ||
        format == vk.VK_FORMAT_R8G8B8_UINT ||
        format == vk.VK_FORMAT_R8G8B8_SINT ||
        format == vk.VK_FORMAT_R8G8B8_SRGB ||
        format == vk.VK_FORMAT_B8G8R8_UNORM ||
        format == vk.VK_FORMAT_B8G8R8_SNORM ||
        format == vk.VK_FORMAT_B8G8R8_USCALED ||
        format == vk.VK_FORMAT_B8G8R8_SSCALED ||
        format == vk.VK_FORMAT_B8G8R8_UINT ||
        format == vk.VK_FORMAT_B8G8R8_SINT ||
        format == vk.VK_FORMAT_B8G8R8_SRGB
        return 3
    elseif format == vk.VK_FORMAT_R8G8B8A8_UNORM ||
        format == vk.VK_FORMAT_R8G8B8A8_SNORM ||
        format == vk.VK_FORMAT_R8G8B8A8_USCALED ||
        format == vk.VK_FORMAT_R8G8B8A8_SSCALED ||
        format == vk.VK_FORMAT_R8G8B8A8_UINT ||
        format == vk.VK_FORMAT_R8G8B8A8_SINT ||
        format == vk.VK_FORMAT_R8G8B8A8_SRGB ||
        format == vk.VK_FORMAT_B8G8R8A8_UNORM ||
        format == vk.VK_FORMAT_B8G8R8A8_SNORM ||
        format == vk.VK_FORMAT_B8G8R8A8_USCALED ||
        format == vk.VK_FORMAT_B8G8R8A8_SSCALED ||
        format == vk.VK_FORMAT_B8G8R8A8_UINT ||
        format == vk.VK_FORMAT_B8G8R8A8_SINT ||
        format == vk.VK_FORMAT_B8G8R8A8_SRGB ||
        format == vk.VK_FORMAT_A8B8G8R8_UNORM_PACK32 ||
        format == vk.VK_FORMAT_A8B8G8R8_SNORM_PACK32 ||
        format == vk.VK_FORMAT_A8B8G8R8_USCALED_PACK32 ||
        format == vk.VK_FORMAT_A8B8G8R8_SSCALED_PACK32 ||
        format == vk.VK_FORMAT_A8B8G8R8_UINT_PACK32 ||
        format == vk.VK_FORMAT_A8B8G8R8_SINT_PACK32 ||
        format == vk.VK_FORMAT_A8B8G8R8_SRGB_PACK32 ||
        format == vk.VK_FORMAT_A2R10G10B10_UNORM_PACK32 ||
        format == vk.VK_FORMAT_A2R10G10B10_SNORM_PACK32 ||
        format == vk.VK_FORMAT_A2R10G10B10_USCALED_PACK32 ||
        format == vk.VK_FORMAT_A2R10G10B10_SSCALED_PACK32 ||
        format == vk.VK_FORMAT_A2R10G10B10_UINT_PACK32 ||
        format == vk.VK_FORMAT_A2R10G10B10_SINT_PACK32 ||
        format == vk.VK_FORMAT_A2B10G10R10_UNORM_PACK32 ||
        format == vk.VK_FORMAT_A2B10G10R10_SNORM_PACK32 ||
        format == vk.VK_FORMAT_A2B10G10R10_USCALED_PACK32 ||
        format == vk.VK_FORMAT_A2B10G10R10_SSCALED_PACK32 ||
        format == vk.VK_FORMAT_A2B10G10R10_UINT_PACK32 ||
        format == vk.VK_FORMAT_A2B10G10R10_SINT_PACK32
        return 4
    elseif format == vk.VK_FORMAT_R16_UNORM ||
        format == vk.VK_FORMAT_R16_SNORM ||
        format == vk.VK_FORMAT_R16_USCALED ||
        format == vk.VK_FORMAT_R16_SSCALED ||
        format == vk.VK_FORMAT_R16_UINT ||
        format == vk.VK_FORMAT_R16_SINT ||
        format == vk.VK_FORMAT_R16_SFLOAT
        return 2
    elseif format == vk.VK_FORMAT_R16G16_UNORM ||
        format == vk.VK_FORMAT_R16G16_SNORM ||
        format == vk.VK_FORMAT_R16G16_USCALED ||
        format == vk.VK_FORMAT_R16G16_SSCALED ||
        format == vk.VK_FORMAT_R16G16_UINT ||
        format == vk.VK_FORMAT_R16G16_SINT ||
        format == vk.VK_FORMAT_R16G16_SFLOAT
        return 4
    elseif format == vk.VK_FORMAT_R16G16B16_UNORM ||
        format == vk.VK_FORMAT_R16G16B16_SNORM ||
        format == vk.VK_FORMAT_R16G16B16_USCALED ||
        format == vk.VK_FORMAT_R16G16B16_SSCALED ||
        format == vk.VK_FORMAT_R16G16B16_UINT ||
        format == vk.VK_FORMAT_R16G16B16_SINT ||
        format == vk.VK_FORMAT_R16G16B16_SFLOAT
        return 6
    elseif format == vk.VK_FORMAT_R16G16B16A16_UNORM ||
        format == vk.VK_FORMAT_R16G16B16A16_SNORM ||
        format == vk.VK_FORMAT_R16G16B16A16_USCALED ||
        format == vk.VK_FORMAT_R16G16B16A16_SSCALED ||
        format == vk.VK_FORMAT_R16G16B16A16_UINT ||
        format == vk.VK_FORMAT_R16G16B16A16_SINT ||
        format == vk.VK_FORMAT_R16G16B16A16_SFLOAT
        return 8
    elseif format == vk.VK_FORMAT_R32_UINT ||
        format == vk.VK_FORMAT_R32_SINT ||
        format == vk.VK_FORMAT_R32_SFLOAT
        return 4
    elseif format == vk.VK_FORMAT_R32G32_UINT ||
        format == vk.VK_FORMAT_R32G32_SINT ||
        format == vk.VK_FORMAT_R32G32_SFLOAT
        return 8
    elseif format == vk.VK_FORMAT_R32G32B32_UINT ||
        format == vk.VK_FORMAT_R32G32B32_SINT ||
        format == vk.VK_FORMAT_R32G32B32_SFLOAT
        return 12
    elseif format == vk.VK_FORMAT_R32G32B32A32_UINT ||
        format == vk.VK_FORMAT_R32G32B32A32_SINT ||
        format == vk.VK_FORMAT_R32G32B32A32_SFLOAT
        return 16
    elseif format == vk.VK_FORMAT_R64_UINT ||
        format == vk.VK_FORMAT_R64_SINT ||
        format == vk.VK_FORMAT_R64_SFLOAT
        return 8
    elseif format == vk.VK_FORMAT_R64G64_UINT ||
        format == vk.VK_FORMAT_R64G64_SINT ||
        format == vk.VK_FORMAT_R64G64_SFLOAT
        return 16
    elseif format == vk.VK_FORMAT_R64G64B64_UINT ||
        format == vk.VK_FORMAT_R64G64B64_SINT ||
        format == vk.VK_FORMAT_R64G64B64_SFLOAT
        return 24
    elseif format == vk.VK_FORMAT_R64G64B64A64_UINT ||
        format == vk.VK_FORMAT_R64G64B64A64_SINT ||
        format == vk.VK_FORMAT_R64G64B64A64_SFLOAT
        return 32
    elseif format == vk.VK_FORMAT_B10G11R11_UFLOAT_PACK32 ||
        format == vk.VK_FORMAT_E5B9G9R9_UFLOAT_PACK32
        return 4
    elseif format == vk.VK_FORMAT_D16_UNORM
        return 2
    elseif format == vk.VK_FORMAT_X8_D24_UNORM_PACK32 ||
        format == vk.VK_FORMAT_D32_SFLOAT
        return 4
    elseif format == vk.VK_FORMAT_S8_UINT
        return 1
    elseif format == vk.VK_FORMAT_D16_UNORM_S8_UINT
        return 3
    elseif format == vk.VK_FORMAT_D24_UNORM_S8_UINT
        return 4
    elseif format == vk.VK_FORMAT_D32_SFLOAT_S8_UINT
        return 5
    else
        @assert false "TODO: look those up."
        return 0
    end
end
