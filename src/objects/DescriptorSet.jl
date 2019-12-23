mutable struct DescriptorSet
    mVkDevice::vk.VkDevice
    mPool::DescriptorPool
    mLayout::DescriptorSetLayout

    mHandleRef::Ref{vk.VkDescriptorSet}

    function DescriptorSet(device::vk.VkDevice,
                             pool::DescriptorPool,
                           layout::DescriptorSetLayout)
        this = new()
        this.mVkDevice = device
        this.mPool = pool
        this.mLayout = layout

        setLayoutRef = handleRef(this.mLayout)
        info = Ref(vk.VkDescriptorSetAllocateInfo(
            VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO, #sType::VkStructureType
            C_NULL, #pNext::Ptr{Cvoid}
            handleRef(this.mPool), #descriptorPool::VkDescriptorPool
            1, #descriptorSetCount::UInt32
            pointer(setLayoutRef) #pSetLayouts::Ptr{VkDescriptorSetLayout}
        ))

        descriptorSets = Vector{vk.VkDescriptorSet}(undef, info[].descriptorSetCount)
        vk.vkAllocateDescriptorSets(this.mVkDevice, info, pointer(descriptorSets))
        this.mHandleRef = Ref(descriptorSets[0])
        println("descriptor set:", this.mHandleRef)
    end


    # TODO
    # // Keep Samplers/Views etc. to keep them from being destroyed while in use
    # using ResourceList = std::vector<std::shared_ptr<void>>;
    # std::unordered_map<uint32_t, ResourceList> mBindingResources;
end

function destroy(this::DescriptorSet)
    vk.vkFreeDescriptorSets(this.mVkDevice, handleRef(this.mPool)[], 1, this.mHandleRef[])
end

function handleRef(this::DescriptorSet)::Ref{vk.VkDescriptorSet}
    return this.mHandleRef
end
