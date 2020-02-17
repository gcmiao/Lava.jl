mutable struct DescriptorSet
    mVkDevice::vk.VkDevice
    mPool::DescriptorPool
    mLayout::DescriptorSetLayout
    mInfo::vk.VkDescriptorSetAllocateInfo
    mHandleRef::Ref{vk.VkDescriptorSet}
    # Keep Samplers/Views etc. to keep them from being destroyed while in use
    mBindingResources::Dict{UInt32, Vector{Any}}

    function DescriptorSet(device::vk.VkDevice,
                             pool::DescriptorPool,
                           layout::DescriptorSetLayout)
        this = new()
        this.mVkDevice = device
        this.mPool = pool
        this.mLayout = layout
        this.mBindingResources = Dict{UInt32, Vector{Any}}()

        setLayouts = [this.mLayout.handleRef()[]]
        info = Ref(vk.VkDescriptorSetAllocateInfo(
            vk.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO, #sType::VkStructureType
            C_NULL, #pNext::Ptr{Cvoid}
            handleRef(this.mPool)[], #descriptorPool::VkDescriptorPool
            UInt32(length(setLayouts)), #descriptorSetCount::UInt32
            pointer(setLayouts) #pSetLayouts::Ptr{VkDescriptorSetLayout}
        ))

        descriptorSets = Vector{vk.VkDescriptorSet}(undef, info[].descriptorSetCount)
        vk.vkAllocateDescriptorSets(this.mVkDevice, info, pointer(descriptorSets))
        this.mHandleRef = Ref(descriptorSets[1])
        println("descriptor set:", this.mHandleRef)
        return this
    end


    # TODO
    # // Keep Samplers/Views etc. to keep them from being destroyed while in use
    # using ResourceList = std::vector<std::shared_ptr<void>>;
    # std::unordered_map<uint32_t, ResourceList> mBindingResources;
end
@class DescriptorSet

function destroy(this::DescriptorSet)
    vk.vkFreeDescriptorSets(this.mVkDevice, handleRef(this.mPool)[], 1, this.mHandleRef[])
end

function handleRef(this::DescriptorSet)::Ref{vk.VkDescriptorSet}
    return this.mHandleRef
end

function writeCombinedImageSamplers(this::DescriptorSet, sampler::Sampler, views::Vector{ImageView}, binding::UInt32)::DescriptorSet
    writer = DescriptorSetWriter(this, binding)
    writer.combinedImageSamplers(sampler, views).write()
    return this
end

function writeCombinedImageSampler(this::DescriptorSet, sampler::Sampler, view::ImageView, binding::UInt32)::DescriptorSet
    writer = DescriptorSetWriter(this, binding)
    writer.combinedImageSamplers(sampler, view).write()
    return this
end

function writeUniformBuffer(this::DescriptorSet, buffer::Buffer, binding::UInt32)::DescriptorSet
    writer = DescriptorSetWriter(this, binding)
    writer.uniformBuffer(buffer).write()
    return this
end

function writeSampledImage(this::DescriptorSet, view::ImageView, binding::UInt32)::DescriptorSet
    writer = DescriptorSetWriter(this, binding)
    writer.sampledImage(view).write()
    return this
end
