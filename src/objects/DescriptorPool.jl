mutable struct DescriptorPool
    mVkDevice::vk.VkDevice
    mCreateInfo::DescriptorPoolCreateInfo

    mHandleRef::Ref{vk.VkDescriptorPool}

    function DescriptorPool(device::vk.VkDevice, info::DescriptorPoolCreateInfo)
        this = new()
        this.mVkDevice = device
        this.mCreateInfo = info
        this.mHandleRef = Ref{vk.VkDescriptorPool}()
        if vk.vkCreateDescriptorPool(this.mVkDevice, handleRef(this.mCreateInfo), C_NULL, this.mHandleRef) != vk.VK_SUCCESS
            error("Failed to create descriptor pool!")
        end
        println("descriptor pool:", this.mHandleRef)
        return this
    end
end


# TODO Deconstruction
# DescriptorPool::~DescriptorPool()
# {
#     mDevice->handle().destroyDescriptorPool(mHandle);
# }

#function createDescriptorSet(this::DescriptorPool, layout::DescriptorSetLayout)::SharedDescriptorSet
function createDescriptorSet(this::DescriptorPool, layout)::DescriptorSet
    return DescriptorSet(this.mDevice, this, layout)
end

function handleRef(this::DescriptorPool)::Ref{vk.VkDescriptorPool}
    return this.mHandleRef
end