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
        return this
    end
end
@class DescriptorPool

function destroy(this::DescriptorPool)
    vk.vkDestroyDescriptorPool(this.mVkDevice, this.mHandleRef[], C_NULL)
end

function handleRef(this::DescriptorPool)::Ref{vk.VkDescriptorPool}
    return this.mHandleRef
end
