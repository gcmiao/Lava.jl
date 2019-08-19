mutable struct DescriptorSetLayoutCreateInfo
    mBindings::Vector{vk.VkDescriptorSetLayoutBinding}

    mHandleRef::Ref{vk.VkDescriptorSetLayoutCreateInfo}

    DescriptorSetLayoutCreateInfo() = new()
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