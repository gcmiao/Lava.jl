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
    rtProps = Ref(vk.VkPhysicalDeviceRayTracingPropertiesNV(
                    vk.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PROPERTIES_NV, # sType::VkStructureType
                    C_NULL, # pNext::Ptr{Cvoid}
                    0, # shaderGroupHandleSize::UInt32
                    0, # maxRecursionDepth::UInt32
                    0, # maxShaderGroupStride::UInt32
                    0, # shaderGroupBaseAlignment::UInt32
                    0, # maxGeometryCount::UInt64
                    0, # maxInstanceCount::UInt64
                    0, # maxTriangleCount::UInt64
                    0 # maxDescriptorSetAccelerationStructures::UInt32
                ))
    props = VkExt.getProperties(dev)
    props2 = Ref(vk.VkPhysicalDeviceProperties2(
                    vk.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2, # sType::VkStructureType
                    ref_to_pointer(vk.VkPhysicalDeviceRayTracingPropertiesNV, rtProps), # pNext::Ptr{Cvoid}
                    props # properties::VkPhysicalDeviceProperties
                ))
    #props2 = Ref{vk.VkPhysicalDeviceProperties2}()
    vk.vkGetPhysicalDeviceProperties2(dev, props2)
    p = unsafe_load(Ptr{vk.VkPhysicalDeviceRayTracingPropertiesNV}(props2[].pNext))
    println("---", rtProps)
    println("---", p)
    return rtprop.maxGeometryCount > 0
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
end

function LavaCore.:addPhysicalDeviceFeatures(this::RayTracing, outDeviceFeatures::VkExt.VkPhysicalDeviceFeatures)
    outDeviceFeatures.setVertexPipelineStoresAndAtomics(VkExt.VK_TRUE)
end
