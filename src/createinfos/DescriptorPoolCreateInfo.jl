mutable struct DescriptorPoolCreateInfo
    mSizes::Vector{vk.VkDescriptorPoolSize}
    mFlags::vk.VkDescriptorPoolCreateFlags
    mMaxSets::UInt32

    mHandleRef::Ref{vk.VkDescriptorPoolCreateInfo}

    function DescriptorPoolCreateInfo()
        this = new()
        this.mSizes = Vector{vk.VkDescriptorPoolSize}()
        this.mFlags = 0
        this.mMaxSets = 0
        return this
    end
end

function handleRef(this::DescriptorPoolCreateInfo)
    this.mHandleRef = Ref(vk.VkDescriptorPoolCreateInfo(
        vk.VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO, #sType::VkStructureType
        C_NULL, #pNext::Ptr{Cvoid}
        this.mFlags, #flags::VkDescriptorPoolCreateFlags
        this.mMaxSets, #maxSets::UInt32
        length(this.mSizes), #poolSizeCount::UInt32
        pointer(this.mSizes) #pPoolSizes::Ptr{VkDescriptorPoolSize}
    ))
end

function allowFreeing(this::DescriptorPoolCreateInfo, val::Bool = true)
    if val
        this.mFlags |= vk.VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT
    else
        this.mFlags &= (~Int(vk.VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT))
    end
end

function setMaxSets(this::DescriptorPoolCreateInfo, count::UInt32)
    this.mMaxSets = count
end

function addSize(this::DescriptorPoolCreateInfo, type::vk.VkDescriptorType, count::UInt32)
    push!(this.mSizes, vk.VkDescriptorPoolSize(type, count))
end