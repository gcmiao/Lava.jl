struct Sampler
    mVkDevice::vk.VkDevice
    mInfo::SamplerCreateInfo
    mHandle::vk.VkSampler

    function Sampler(vkDevice::vk.VkDevice, info::SamplerCreateInfo)
        handleRef = Ref{vk.VkSampler}()
        if vk.vkCreateSampler(vkDevice, info.handleRef(), C_NULL, handleRef) != vk.VK_SUCCESS
            error("Failed to create sampler.")
        end
        this = new(vkDevice, info, handleRef[])
        return this
    end
end
@class Sampler

function destroy(this::Sampler)
    vk.vkDestroySampler(this.mVkDevice, this.mHandle, C_NULL)
end

function handle(this::Sampler)::vk.VkSampler
    return this.mHandle
end
