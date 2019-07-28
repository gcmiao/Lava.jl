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

function enumeratePhysicalDevices(this::VkInstance)
    physicalDeviceCount = Ref{Cuint}(0)
    vk.vkEnumeratePhysicalDevices(this.mInstance, physicalDeviceCount, C_NULL)
    if (physicalDeviceCount[] == 0)
        println("failed to find GPUs with Vulkan support!")
    end
    physicalDevices = Vector{vk.VkPhysicalDevice}(undef, physicalDeviceCount[])
    vk.vkEnumeratePhysicalDevices(this.mInstance, physicalDeviceCount, physicalDevices)
    #println(physicalDevices)
    return physicalDevices
end

function getProperties(phy::vk.VkPhysicalDevice)::vk.VkPhysicalDeviceProperties
    deviceProperties = Ref{vk.VkPhysicalDeviceProperties}()
    vk.vkGetPhysicalDeviceProperties(phy, deviceProperties)
    return deviceProperties[]
end

end