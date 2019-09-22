using VulkanCore
using VkExt

abstract type IFeatureT end

function layers(this::IFeatureT, available::Vector{String})::Vector{String}
    return []
end

function instanceExtensions(this::IFeatureT, available::Vector{String})::Vector{String}
    return []
end

function deviceExtensions(this::IFeatureT)::Vector{String}
    return []
end

function onInstanceCreated(this::IFeatureT, instance::VkExt.VkInstance)
end

function onLogicalDeviceCreated(this::IFeatureT, device::vk.VkDevice)
end

function onPhysicalDeviceSelected(this::IFeatureT, phy::vk.VkPhysicalDevice)
end

function supportsDevice(this::IFeatureT, dev::vk.VkPhysicalDevice)::Bool
    return true
end

function addPhysicalDeviceFeatures(this::IFeatureT, outDeviceFeatures::VkExt.VkPhysicalDeviceFeatures)
end
