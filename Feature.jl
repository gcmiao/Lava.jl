using VulkanCore
using VkExt

abstract type IFeatureT end

function layers(this::IFeatureT, available::Array{String})::Array{String}
    println("empty implementation in IFeatureT.layers")
    return []
end

function instanceExtensions(this::IFeatureT, available::Array{String})::Array{String}
    println("empty implementation in IFeatureT.instanceExtensions")
    return []
end

function deviceExtensions(this::IFeatureT, available::Array{String})::Array{String}
    println("empty implementation in IFeatureT.deviceExtensions")
    return []
end

function onInstanceCreated(this::IFeatureT, instance::VkExt.VkInstance)
    println("empty implementation in IFeatureT.onInstanceCreated")
end

function onLogicalDeviceCreated(this::IFeatureT, device)
    println("empty implementation in IFeatureT.onLogicalDeviceCreated")
end

function onPhysicalDeviceSelected(this::IFeatureT, phy::vk.VkPhysicalDevice)
    println("empty implementation in IFeatureT.onPhysicalDeviceSelected")
end

function supportsDevice(this::IFeatureT, dev::vk.VkPhysicalDevice)
    return true
end

function addPhysicalDeviceFeatures(this::IFeatureT, outDeviceFeatures::VkExt.VkPhysicalDeviceFeatures)
end

function queueRequests(this::IFeatureT, families::Array{vk.VkQueueFamilyProperties, 1})
end