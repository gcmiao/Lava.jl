module VkExt
export VkInstance

using VulkanCore

struct VkInstance
    mInstance::vk.VkInstance
end

function createInstance(info::vk.VkInstanceCreateInfo)
    outInstance = Ref{vk.VkInstance}()
    err = vk.vkCreateInstance(Ref(info), C_NULL, outInstance)
    if err != vk.VK_SUCCESS
        println(err, "Failed to create instance!")
    end
    return VkInstance(outInstance[])
end

end