mutable struct DescriptorSetLayoutCreateInfo
    mBindings::Array{vk.VkDescriptorSetLayoutBinding, 1}

    mHandleRef::Ref{vk.VkDescriptorSetLayoutCreateInfo}

    DescriptorSetLayoutCreateInfo() = new()
end

function handleRef(this::DescriptorSetLayoutCreateInfo)::Ref{vk.VkDescriptorSetLayoutCreateInfo}
    mHandleRef = Ref(vk.VkDescriptorSetLayoutCreateInfo(
        vk.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO, #sType::VkStructureType
        C_NULL, #pNext::Ptr{Cvoid}
        0, #flags::VkDescriptorSetLayoutCreateFlags
        length(mBindings), #bindingCount::UInt32
        pointer(mBindings) #pBindings::Ptr{VkDescriptorSetLayoutBinding}
    ))
    return mHandleRef
end