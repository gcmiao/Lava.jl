mutable struct Sampler
    mVkDevice::vk.VkDevice
    mInfo::SamplerCreateInfo
    mHandle::vk.VkSampler

    function Sampler(vkDevice::vk.VkDevice, info::SamplerCreateInfo)
        this = new()
        this.mVkDevice = vkDevice
        this.mInfo = info
        ref = Ref{vk.VkSampler}()
        if vk.vkCreateSampler(vkDevice, handleRef(info), C_NULL, ref) != vk.VK_SUCCESS
            error("Failed to create sampler.")
        end
        this.mHandle = ref[]
        return this
    end
end
@class Sampler

function destroy(this::Sampler)
    vk.vkDestroySampler(this.mVkDevice, this.mHandle, C_NULL)
end

function handle(this::Sampler)
    return this.mHandle
end
