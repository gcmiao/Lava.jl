export IFeatureT

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

function onInstanceCreated(this::IFeatureT, vkInstance::vk.VkInstance)
end

function onLogicalDeviceCreated(this::IFeatureT, device)
end

function onPhysicalDeviceSelected(this::IFeatureT, phy::vk.VkPhysicalDevice)
end

function supportsDevice(this::IFeatureT, dev::vk.VkPhysicalDevice)::Bool
    return true
end

function queueRequests(this::IFeatureT, families::Vector{vk.VkQueueFamilyProperties})
    return []
end

function addPhysicalDeviceFeatures(this::IFeatureT, outDeviceFeatures::VkExt.VkPhysicalDeviceFeatures)
end