module VkExt

using VulkanCore
include("VkExt.VkPhysicalDeviceFeatures.jl")

const VkTrue = UInt32(vk.VK_TRUE)
const VkFalse = UInt32(vk.VK_FALSE)

struct VkInstance
    vkInstance::vk.VkInstance
end

# instance
function createInstance(info::vk.VkInstanceCreateInfo)::VkInstance
    outInstance = Ref{vk.VkInstance}()
    err = vk.vkCreateInstance(Ref(info), C_NULL, outInstance)
    if err != vk.VK_SUCCESS
        println(err, "Failed to create instance!")
    end
    return VkInstance(outInstance[])
end

function enumerateInstanceExtensionProperties()::Tuple{Array{vk.VkExtensionProperties, 1}, UInt32}
    extensionCount = Ref{UInt32}(0)
    vk.vkEnumerateInstanceExtensionProperties(C_NULL, extensionCount, C_NULL)
    availableExtensions = Array{vk.VkExtensionProperties, 1}(undef, extensionCount[])
    vk.vkEnumerateInstanceExtensionProperties(C_NULL, extensionCount, availableExtensions)
    return availableExtensions, extensionCount[]
end

function enumerateInstanceLayerProperties()::Tuple{Array{vk.VkLayerProperties, 1}, UInt32}
    layerCount = Ref{UInt32}(0)
    vk.vkEnumerateInstanceLayerProperties(layerCount, C_NULL);
    avaliableLayers = Array{vk.VkLayerProperties, 1}(undef, layerCount[])
    vk.vkEnumerateInstanceLayerProperties(layerCount, avaliableLayers)
    return avaliableLayers, layerCount[]
end

function vkCreateDebugReportCallbackEXT(instance, callbackInfoRef, allocatorRef, callbackRef)
    fnptr = vk.vkGetInstanceProcAddr(instance, "vkCreateDebugReportCallbackEXT") |> vk.PFN_vkCreateDebugReportCallbackEXT
    ccall(fnptr, vk.VkResult, (vk.VkInstance, Ptr{vk.VkDebugReportCallbackCreateInfoEXT}, Ptr{vk.VkAllocationCallbacks},
                               Ptr{vk.VkDebugReportCallbackEXT}), instance, callbackInfoRef, allocatorRef, callbackRef)
end

function createDebugReportCallbackEXT(instance::vk.VkInstance, createInfo::vk.VkDebugReportCallbackCreateInfoEXT)
    callback = Ref{vk.VkDebugReportCallbackEXT}()
    err = vkCreateDebugReportCallbackEXT(instance, Ref(createInfo), C_NULL, callback)
    if err != vk.VK_SUCCESS
        println(err, "create debug report callback ext failed!")
    end
    return callback[]
end

# physical device
function enumeratePhysicalDevices(this::VkInstance)
    physicalDeviceCount = Ref{Cuint}(0)
    vk.vkEnumeratePhysicalDevices(this.vkInstance, physicalDeviceCount, C_NULL)
    if (physicalDeviceCount[] == 0)
        println("failed to find GPUs with Vulkan support!")
    end
    physicalDevices = Array{vk.VkPhysicalDevice, 1}(undef, physicalDeviceCount[])
    vk.vkEnumeratePhysicalDevices(this.vkInstance, physicalDeviceCount, physicalDevices)
    #println(physicalDevices)
    return physicalDevices
end

function getProperties(phy::vk.VkPhysicalDevice)::vk.VkPhysicalDeviceProperties
    deviceProperties = Ref{vk.VkPhysicalDeviceProperties}()
    vk.vkGetPhysicalDeviceProperties(phy, deviceProperties)
    return deviceProperties[]
end

function enumerateDeviceExtensionProperties(phy::vk.VkPhysicalDevice)
    extensionCount = Ref{UInt32}(0)
    vk.vkEnumerateDeviceExtensionProperties(phy, C_NULL, extensionCount, C_NULL)

    availableExtensions = Array{vk.VkExtensionProperties, 1}(undef, extensionCount[])
    vk.vkEnumerateDeviceExtensionProperties(phy, C_NULL, extensionCount, availableExtensions)
    return availableExtensions
end

function getQueueFamilyProperties(phy::vk.VkPhysicalDevice)::Array{vk.VkQueueFamilyProperties, 1}
    queueFamilyCount = Ref{Cuint}(0)
    vk.vkGetPhysicalDeviceQueueFamilyProperties(phy, queueFamilyCount, C_NULL)
    
    queueFamilies = Array{vk.VkQueueFamilyProperties, 1}(undef, queueFamilyCount[])
    vk.vkGetPhysicalDeviceQueueFamilyProperties(phy, queueFamilyCount, queueFamilies)
    return queueFamilies
end

function createDevice(phy::vk.VkPhysicalDevice, createInfo::Ref{vk.VkDeviceCreateInfo})::vk.VkDevice
    logicalDevice = Ref{vk.VkDevice}()
    err = vk.vkCreateDevice(phy, createInfo, C_NULL, logicalDevice)
    if err != vk.VK_SUCCESS
         println(err, "failed to create logical device!")
    end
    return logicalDevice[]
end

function getSurfaceSupportKHR(phy::vk.VkPhysicalDevice, queueFamilyIndex::UInt32, surface::vk.VkSurfaceKHR)
    presentSupport = Ref{vk.VkBool32}(false)
    err = vk.vkGetPhysicalDeviceSurfaceSupportKHR(phy, queueFamilyIndex, surface, presentSupport)
    if err != vk.VK_SUCCESS
        println(err, "failed to get physical device surface support!")
    end
    return presentSupport[]
end

end #module