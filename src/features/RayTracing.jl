mutable struct RayTracing <: IFeature
    mVkInstance::vk.VkInstance
    mDevice::Device

    function RayTracing()
        this = new()
        return this
    end
end
@class RayTracing

function create(::Type{RayTracing})
    return RayTracing()
end

function LavaCore.:destroy(this::RayTracing)
end

function LavaCore.:supportsDevice(this::RayTracing, dev::vk.VkPhysicalDevice)::Bool
    rtProps = VkExt.getRayTracingProperties(dev)
    return rtProps.maxGeometryCount > 0
end

function LavaCore.:deviceExtensions(this::RayTracing)::Vector{String}
    return [vk.VK_NV_RAY_TRACING_EXTENSION_NAME,
            vk.VK_KHR_GET_MEMORY_REQUIREMENTS_2_EXTENSION_NAME]
end

function LavaCore.:instanceExtensions(this::RayTracing, available::Vector{String})::Vector{String}
    return [vk.VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME]
end

function LavaCore.:onInstanceCreated(this::RayTracing, vkInstance::vk.VkInstance)
    this.mVkInstance = vkInstance
end

function LavaCore.:onLogicalDeviceCreated(this::RayTracing, device::Device)
    this.mDevice = device
    #TODO device->handle().getProcAddr("vkCreateAccelerationStructureNVX");
end

function LavaCore.:addPhysicalDeviceFeatures(this::RayTracing, outDeviceFeatures::VkExt.VkPhysicalDeviceFeatures)
    outDeviceFeatures.setVertexPipelineStoresAndAtomics(VkExt.VK_TRUE)
end
