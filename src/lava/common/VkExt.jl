module VkExt

using VulkanCore
include("VkExt.VkPhysicalDeviceFeatures.jl")

const VK_TRUE = UInt32(vk.VK_TRUE)
const VK_FALSE = UInt32(vk.VK_FALSE)

struct VkInstance
    vkInstance::vk.VkInstance
end

# instance
function createInstance(info::vk.VkInstanceCreateInfo)::VkInstance
    outInstance = Ref{vk.VkInstance}()
    err = vk.vkCreateInstance(Ref(info), C_NULL, outInstance)
    if err != vk.VK_SUCCESS
        error(err, "Failed to create instance!")
    end
    return VkInstance(outInstance[])
end

function enumerateInstanceExtensionProperties()::Tuple{Vector{vk.VkExtensionProperties}, UInt32}
    extensionCount = Ref{UInt32}(0)
    vk.vkEnumerateInstanceExtensionProperties(C_NULL, extensionCount, C_NULL)
    availableExtensions = Vector{vk.VkExtensionProperties}(undef, extensionCount[])
    vk.vkEnumerateInstanceExtensionProperties(C_NULL, extensionCount, availableExtensions)
    return availableExtensions, extensionCount[]
end

function enumerateInstanceLayerProperties()::Tuple{Vector{vk.VkLayerProperties}, UInt32}
    layerCount = Ref{UInt32}(0)
    vk.vkEnumerateInstanceLayerProperties(layerCount, C_NULL);
    avaliableLayers = Vector{vk.VkLayerProperties}(undef, layerCount[])
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
        error(err, "create debug report callback ext failed!")
    end
    return callback[]
end

# physical device
function enumeratePhysicalDevices(this::VkInstance)
    physicalDeviceCount = Ref{Cuint}(0)
    vk.vkEnumeratePhysicalDevices(this.vkInstance, physicalDeviceCount, C_NULL)
    if (physicalDeviceCount[] == 0)
        error("failed to find GPUs with Vulkan support!")
    end
    physicalDevices = Vector{vk.VkPhysicalDevice}(undef, physicalDeviceCount[])
    vk.vkEnumeratePhysicalDevices(this.vkInstance, physicalDeviceCount, physicalDevices)
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

    availableExtensions = Vector{vk.VkExtensionProperties}(undef, extensionCount[])
    vk.vkEnumerateDeviceExtensionProperties(phy, C_NULL, extensionCount, availableExtensions)
    return availableExtensions
end

function getQueueFamilyProperties(phy::vk.VkPhysicalDevice)::Vector{vk.VkQueueFamilyProperties}
    queueFamilyCount = Ref{Cuint}(0)
    vk.vkGetPhysicalDeviceQueueFamilyProperties(phy, queueFamilyCount, C_NULL)
    
    queueFamilies = Vector{vk.VkQueueFamilyProperties}(undef, queueFamilyCount[])
    vk.vkGetPhysicalDeviceQueueFamilyProperties(phy, queueFamilyCount, queueFamilies)
    return queueFamilies
end

function createDevice(phy::vk.VkPhysicalDevice, createInfo::Ref{vk.VkDeviceCreateInfo})::vk.VkDevice
    logicalDevice = Ref{vk.VkDevice}()
    err = vk.vkCreateDevice(phy, createInfo, C_NULL, logicalDevice)
    if err != vk.VK_SUCCESS
         error(err, "failed to create logical device!")
    end
    return logicalDevice[]
end

function getSurfaceSupportKHR(phy::vk.VkPhysicalDevice, queueFamilyIndex::UInt32, surface::vk.VkSurfaceKHR)
    presentSupport = Ref{vk.VkBool32}(false)
    err = vk.vkGetPhysicalDeviceSurfaceSupportKHR(phy, queueFamilyIndex, surface, presentSupport)
    if err != vk.VK_SUCCESS
        error(err, "failed to get physical device surface support!")
    end
    return presentSupport[]
end

function getSurfaceFormatsKHR(device::vk.VkPhysicalDevice, surface::vk.VkSurfaceKHR)::Vector{vk.VkSurfaceFormatKHR}
    surfaceFormats = Vector{vk.VkSurfaceFormatKHR}()
    formatCount = Ref{UInt32}()
    vk.vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, formatCount, C_NULL)
    if (formatCount[] != 0)
        resize!(surfaceFormats, formatCount[])
        vk.vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, formatCount, surfaceFormats)
    end
    return surfaceFormats
end

# logical device
function createShaderModule(logicalDevice::vk.VkDevice, code::Ptr{UInt8}, codeSize::Int64)::vk.VkShaderModule
    createInfo = Ref(vk.VkShaderModuleCreateInfo(
        vk.VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO, #sType::VkStructureType
        C_NULL, #pNext::Ptr{Cvoid}
        0, #flags::VkShaderModuleCreateFlags
        codeSize, #codeSize::Csize_t
        code, #pCode::Ptr{UInt32}
    ))

    shaderModule = Ref{vk.VkShaderModule}()
    if (vk.vkCreateShaderModule(logicalDevice, createInfo, C_NULL, shaderModule) != vk.VK_SUCCESS)
        error("Failed to create shader module!")
    end
    return shaderModule[]
end

# common
mutable struct ClearValue
    mColor::vk.VkClearColorValue
    mDepthStencil::vk.VkClearDepthStencilValue

    function ClearValue(color::vk.VkClearColorValue)
        this = new()
        this.mColor = color
        return this
    end

    function ClearValue(depthStencil::vk.VkClearDepthStencilValue)
        this = new()
        this.mDepthStencil = depthStencil
        return this
    end
end

end #module