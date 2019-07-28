export Device

using features
using VulkanCore
using VkExt
using lava: ISelectionStrategy

mutable struct Device
    mInstance::VkExt.VkInstance
    mFeatures::Array{IFeatureT, 1}
    mPhysicalDevice::vk.VkPhysicalDevice
    mPhyProperties::vk.VkPhysicalDeviceProperties

    function Device(instance::VkExt.VkInstance,
               features::Array{IFeatureT, 1},
               gpuSelectionStrategy::ISelectionStrategy,
               queues::Array{Any, 1})
        this = new()
        this.mInstance = instance
        this.mFeatures = features

        pickPhysicalDevice(this, gpuSelectionStrategy, features)
        #createLogicalDevice(this, [mPhysicalDevice], queues)
    end
end

function pickPhysicalDevice(this::Device, gpuSelectionStrategy::ISelectionStrategy, inFeatures)
    devices = VkExt.enumeratePhysicalDevices(this.mInstance)
    isGoodDevice = function(device)
        for feat in inFeatures
            if !features.supportsDevice(feat, device)
                return false
            end
        end
        return true
    end

    deviceCount::UInt32 = 0
    for device in devices
        if isGoodDevice(device)
            deviceCount += 1
            devices[deviceCount] = device
        end
    end
    resize!(devices, deviceCount)

    this.mPhysicalDevice = selectFrom(gpuSelectionStrategy, devices);

    for feat in inFeatures
        feat->onPhysicalDeviceSelected(this.mPhysicalDevice)
    end

    this.mPhyProperties = VkExt.getProperties(this.mPhysicalDevice);
end

function createLogicalDevice(this::Device, physicalDevices::Array{}, queues)
    # TODO
end