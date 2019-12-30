export IFeature

abstract type IFeature end

function layers(this::IFeature, available::Vector{String})::Vector{String}
    return []
end

function instanceExtensions(this::IFeature, available::Vector{String})::Vector{String}
    return []
end

function deviceExtensions(this::IFeature)::Vector{String}
    return []
end

function onInstanceCreated(this::IFeature, vkInstance::vk.VkInstance)
end

function beforeInstanceDestruction(this::IFeature)
end

function onLogicalDeviceCreated(this::IFeature, device)
end

function onPhysicalDeviceSelected(this::IFeature, phy::vk.VkPhysicalDevice)
end

function beforeDeviceDestruction(this::IFeature)
end

function supportsDevice(this::IFeature, dev::vk.VkPhysicalDevice)::Bool
    return true
end

function queueRequests(this::IFeature, families::Vector{vk.VkQueueFamilyProperties})
    return []
end

function addPhysicalDeviceFeatures(this::IFeature, outDeviceFeatures::VkExt.VkPhysicalDeviceFeatures)
end
