mutable struct ShaderModule
    mVkDevice::vk.VkDevice
    mHandle::vk.VkShaderModule
    mStage::vk.VkShaderStageFlagBits

    function ShaderModule(device::vk.VkDevice,
                            code::Ptr{UInt8}, codeSize::Int64,
                            stage::vk.VkShaderStageFlagBits = vk.VK_SHADER_STAGE_ALL)
        this = new(device, VkExt.createShaderModule(device, code, codeSize), stage)
    end
end

function destroy(this::ShaderModule)
    vk.vkDestroyShaderModule(this.mVkDevice, this.mHandle, C_NULL)
    this.mHandle = C_NULL
    println("Destroy ShaderModule")
end

function handle(this::ShaderModule)::vk.VkShaderModule
    return this.mHandle
end

function getStage(this::ShaderModule)::vk.VkShaderStageFlagBits
    return this.mStage
end
