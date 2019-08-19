mutable struct DescriptorSetLayoutCreateInfo
    mBindings::Vector{vk.VkDescriptorSetLayoutBinding}

    mHandleRef::Ref{vk.VkDescriptorSetLayoutCreateInfo}

    function DescriptorSetLayoutCreateInfo()
        this = new()
        this.mBindings = Vector{vk.VkDescriptorSetLayoutBinding}()
        return this
    end
end

function addBinding(this::DescriptorSetLayoutCreateInfo,
                    type::vk.VkDescriptorType,
                   stage::vk.VkShaderStageFlagBits = vk.VK_SHADER_STAGE_ALL_GRAPHICS,
                   count::UInt32 = 0,
                   samplers::Ptr{vk.VkSampler} = Ptr{vk.VkSampler}(C_NULL))
    push!(this.mBindings, vk.VkDescriptorSetLayoutBinding(
                                length(this.mBindings), #binding::UInt32
                                type, #descriptorType::VkDescriptorType
                                count, #descriptorCount::UInt32
                                stage, #stageFlags::VkShaderStageFlags
                                samplers, #pImmutableSamplers::Ptr{VkSampler}
                            ))
end

function addUniformBuffer(this::DescriptorSetLayoutCreateInfo,
                         stage::vk.VkShaderStageFlagBits = vk.VK_SHADER_STAGE_ALL)
    addBinding(this, vk.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, stage, UInt32(1))
end

function addCombinedImageSampler(this::DescriptorSetLayoutCreateInfo,
                                stage::vk.VkShaderStageFlagBits = vk.VK_SHADER_STAGE_ALL_GRAPHICS)
    addBinding(this, vk.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, stage, UInt32(1))
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