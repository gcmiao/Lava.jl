mutable struct DescriptorSetLayoutCreateInfo
    mBindings::Vector{vk.VkDescriptorSetLayoutBinding}

    mHandleRef::Ref{vk.VkDescriptorSetLayoutCreateInfo}

    function DescriptorSetLayoutCreateInfo()
        this = new()
        this.mBindings = Vector{vk.VkDescriptorSetLayoutBinding}()
        return this
    end
end
@class DescriptorSetLayoutCreateInfo

function addBinding(this::DescriptorSetLayoutCreateInfo,
                    type::vk.VkDescriptorType,
                   stage::vk.VkShaderStageFlagBits = vk.VK_SHADER_STAGE_ALL_GRAPHICS,
                   count::UInt32 = 0,
                   samplers::Ptr{vk.VkSampler} = Ptr{vk.VkSampler}(C_NULL))::DescriptorSetLayoutCreateInfo
    push!(this.mBindings, vk.VkDescriptorSetLayoutBinding(
                                length(this.mBindings), #binding::UInt32
                                type, #descriptorType::VkDescriptorType
                                count, #descriptorCount::UInt32
                                stage, #stageFlags::VkShaderStageFlags
                                samplers, #pImmutableSamplers::Ptr{VkSampler}
                            ))
    return this
end

function addSampler(this::DescriptorSetLayoutCreateInfo,
                   stage::vk.VkShaderStageFlagBits = vk.VK_SHADER_STAGE_ALL_GRAPHICS,
                   count::UInt32 = UInt32(1))::DescriptorSetLayoutCreateInfo
    addBinding(this, vk.VK_DESCRIPTOR_TYPE_SAMPLER, stage, count)
    return this
end

function addUniformBuffer(this::DescriptorSetLayoutCreateInfo,
                         stage::vk.VkShaderStageFlagBits = vk.VK_SHADER_STAGE_ALL,
                         count::UInt32 = UInt32(1))::DescriptorSetLayoutCreateInfo
    addBinding(this, vk.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, stage, count)
    return this
end

function addCombinedImageSampler(this::DescriptorSetLayoutCreateInfo,
                                stage::vk.VkShaderStageFlagBits = vk.VK_SHADER_STAGE_ALL_GRAPHICS,
                                count::UInt32 = UInt32(1))::DescriptorSetLayoutCreateInfo
    addBinding(this, vk.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, stage, count)
    return this
end

function addSampledImage(this::DescriptorSetLayoutCreateInfo,
                        stage::vk.VkShaderStageFlagBits = vk.VK_SHADER_STAGE_ALL_GRAPHICS,
                        count::UInt32 = UInt32(1))::DescriptorSetLayoutCreateInfo
    addBinding(this, vk.VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE, stage, count)
    return this
end

function addStorageBuffer(this::DescriptorSetLayoutCreateInfo,
                         stage::vk.VkShaderStageFlagBits = vk.VK_SHADER_STAGE_ALL,
                         count::UInt32 = UInt32(1))::DescriptorSetLayoutCreateInfo
    addBinding(this, vk.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, stage, count)
    return this
end

function addStorageImage(this::DescriptorSetLayoutCreateInfo,
                        stage::vk.VkShaderStageFlagBits = vk.VK_SHADER_STAGE_ALL,
                        count::UInt32 = UInt32(1))::DescriptorSetLayoutCreateInfo
    addBinding(this, vk.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE, stage, count)
    return this
end

function addAccelerationStructure(this::DescriptorSetLayoutCreateInfo,
                                 stage::vk.VkShaderStageFlagBits = vk.VkShaderStageFlagBits(
                                        vk.VK_SHADER_STAGE_RAYGEN_BIT_NV |
                                        vk.VK_SHADER_STAGE_ANY_HIT_BIT_NV |
                                        vk.VK_SHADER_STAGE_CLOSEST_HIT_BIT_NV |
                                        vk.VK_SHADER_STAGE_MISS_BIT_NV),
                                 count::UInt32 = UInt32(1))::DescriptorSetLayoutCreateInfo
    addBinding(this, vk.VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_NV, stage, count)
    return this
end

function handleRef(this::DescriptorSetLayoutCreateInfo)::Ref{vk.VkDescriptorSetLayoutCreateInfo}
    this.mHandleRef = Ref(vk.VkDescriptorSetLayoutCreateInfo(
        vk.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO, #sType::VkStructureType
        C_NULL, #pNext::Ptr{Cvoid}
        0, #flags::VkDescriptorSetLayoutCreateFlags
        length(this.mBindings), #bindingCount::UInt32
        pointer(this.mBindings) #pBindings::Ptr{VkDescriptorSetLayoutBinding}
    ))
    return this.mHandleRef
end
