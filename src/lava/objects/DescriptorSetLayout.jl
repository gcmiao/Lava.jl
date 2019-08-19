mutable struct DescriptorSetLayout
    mVkDevice::vk.VkDevice
    mCreateInfo::DescriptorSetLayoutCreateInfo
    mPool::DescriptorPool

    mHandleRef::Ref{vk.VkDescriptorSetLayout}

    function DescriptorSetLayout(device::vk.VkDevice,
                                   info::DescriptorSetLayoutCreateInfo,
                               poolSize::UInt32)
        this = new()
        this.mVkDevice = device
        this.mCreateInfo = info
        
        this.mHandleRef = Ref{vk.VkDescriptorSetLayout}()
        if vk.vkCreateDescriptorSetLayout(this.mVkDevice, handleRef(this.mCreateInfo), C_NULL, this.mHandleRef) != vk.VK_SUCCESS
            error("Failed to create descriptor set layout!")
        end
        println("descriptor set layout:", this.mHandleRef)
        if poolSize != 0
            sizes = Dict{vk.VkDescriptorType, UInt32}()
            for b in info.mBindings
                count = get!(sizes, b.descriptorType, 0)
                count += b.descriptorCount
                sizes[b.descriptorType] = count
            end
            pinfo = DescriptorPoolCreateInfo()
            allowFreeing(pinfo)
            for s in sizes
                addSize(pinfo, s.first, s.second * poolSize);
            end
            setMaxSets(pinfo, poolSize);

            this.mPool = createDescriptorPool(this.mVkDevice, pinfo);
        end
        return this
    end

end

# TODO: Deconstruction
# DescriptorSetLayout::~DescriptorSetLayout()
# {
#     mDevice->handle().destroyDescriptorSetLayout(mHandle);
# }

function handleRef(this::DescriptorSetLayout)::Ref{vk.VkDescriptorSetLayout}
    return this.mHandleRef
end

function createDescriptorSet(this::DescriptorSetLayout)::DescriptorSet
    return createDescriptorSet(this.mPool, this);
end