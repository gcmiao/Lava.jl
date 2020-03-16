module VkExt

using ..LavaCore: @class
using ..LavaCore.Utils: ref_to_pointer

using VulkanCore
include("VkExt.VkPhysicalDeviceFeatures.jl")

const VK_TRUE = vk.VkBool32(vk.VK_TRUE)
const VK_FALSE = vk.VkBool32(vk.VK_FALSE)

# instance
function createInstance(info::vk.VkInstanceCreateInfo)::vk.VkInstance
    outInstance = Ref{vk.VkInstance}()
    err = vk.vkCreateInstance(Ref(info), C_NULL, outInstance)
    if err != vk.VK_SUCCESS
        error(err, "Failed to create instance!")
    end
    return outInstance[]
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

function createDebugReportCallbackEXT(instance::vk.VkInstance, createInfo::vk.VkDebugReportCallbackCreateInfoEXT)::vk.VkDebugReportCallbackEXT
    callback = Ref{vk.VkDebugReportCallbackEXT}()
    err = vkCreateDebugReportCallbackEXT(instance, Ref(createInfo), C_NULL, callback)
    if err != vk.VK_SUCCESS
        error(err, "Create debug report callback ext failed!")
    end
    return callback[]
end

function destroyDebugReportCallbackEXT(instance::vk.VkInstance, callback::vk.VkDebugReportCallbackEXT)
    fnptr = vk.vkGetInstanceProcAddr(instance, "vkDestroyDebugReportCallbackEXT") |> vk.PFN_vkDestroyDebugReportCallbackEXT
    err = ccall(fnptr, vk.VkResult, (vk.VkInstance, vk.VkDebugReportCallbackEXT, Ptr{vk.VkAllocationCallbacks}),
                                     instance, callback, C_NULL)
    if err != vk.VK_SUCCESS
       error(err, "Destroy debug report callback ext failed!")
    end
end
# physical device
function enumeratePhysicalDevices(vkInstance::vk.VkInstance)
    physicalDeviceCount = Ref{Cuint}(0)
    vk.vkEnumeratePhysicalDevices(vkInstance, physicalDeviceCount, C_NULL)
    if (physicalDeviceCount[] == 0)
        error("Failed to find GPUs with Vulkan support!")
    end
    physicalDevices = Vector{vk.VkPhysicalDevice}(undef, physicalDeviceCount[])
    vk.vkEnumeratePhysicalDevices(vkInstance, physicalDeviceCount, physicalDevices)
    return physicalDevices
end

function enumeratePhysicalDeviceGroups(vkInstance::vk.VkInstance)
    groupCount = Ref{Cuint}(0)
    vk.vkEnumeratePhysicalDeviceGroups(vkInstance, groupCount, C_NULL)
    if (groupCount[] == 0)
        error("Failed to find GPU groups with Vulkan support!")
    end
    groupProps = Vector{vk.VkPhysicalDeviceGroupProperties}(undef, groupCount[])
    vk.vkEnumeratePhysicalDeviceGroups(vkInstance, groupCount, groupProps)
    return groupProps
end

function getProperties(phyDevice::vk.VkPhysicalDevice)::vk.VkPhysicalDeviceProperties
    deviceProperties = Ref{vk.VkPhysicalDeviceProperties}()
    vk.vkGetPhysicalDeviceProperties(phyDevice, deviceProperties)
    return deviceProperties[]
end

function getRayTracingProperties(phyDevice::vk.VkPhysicalDevice)::vk.VkPhysicalDeviceRayTracingPropertiesNV
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
    props = VkExt.getProperties(phyDevice)
    props2 = Ref(vk.VkPhysicalDeviceProperties2(
                    vk.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2, # sType::VkStructureType
                    ref_to_pointer(rtProps), # pNext::Ptr{Cvoid}
                    props # properties::VkPhysicalDeviceProperties
                ))
    vk.vkGetPhysicalDeviceProperties2(phyDevice, props2)
    return rtProps[]
end

function enumerateDeviceExtensionProperties(phyDevice::vk.VkPhysicalDevice)
    extensionCount = Ref{UInt32}(0)
    vk.vkEnumerateDeviceExtensionProperties(phyDevice, C_NULL, extensionCount, C_NULL)

    availableExtensions = Vector{vk.VkExtensionProperties}(undef, extensionCount[])
    vk.vkEnumerateDeviceExtensionProperties(phyDevice, C_NULL, extensionCount, availableExtensions)
    return availableExtensions
end

function getQueueFamilyProperties(phyDevice::vk.VkPhysicalDevice)::Vector{vk.VkQueueFamilyProperties}
    queueFamilyCount = Ref{Cuint}(0)
    vk.vkGetPhysicalDeviceQueueFamilyProperties(phyDevice, queueFamilyCount, C_NULL)

    queueFamilies = Vector{vk.VkQueueFamilyProperties}(undef, queueFamilyCount[])
    vk.vkGetPhysicalDeviceQueueFamilyProperties(phyDevice, queueFamilyCount, queueFamilies)
    return queueFamilies
end

function createDevice(phyDevice::vk.VkPhysicalDevice, createInfo::Ref{vk.VkDeviceCreateInfo})::vk.VkDevice
    logicalDevice = Ref{vk.VkDevice}()
    err = vk.vkCreateDevice(phyDevice, createInfo, C_NULL, logicalDevice)
    if err != vk.VK_SUCCESS
         error(err, "failed to create logical device!")
    end
    return logicalDevice[]
end

function getSurfaceSupportKHR(phyDevice::vk.VkPhysicalDevice, queueFamilyIndex::UInt32, surface::vk.VkSurfaceKHR)
    presentSupport = Ref{vk.VkBool32}(false)
    err = vk.vkGetPhysicalDeviceSurfaceSupportKHR(phyDevice, queueFamilyIndex, surface, presentSupport)
    if err != vk.VK_SUCCESS
        error(err, "failed to get physical device surface support!")
    end
    return presentSupport[]
end

function getSurfaceFormatsKHR(phyDevice::vk.VkPhysicalDevice, surface::vk.VkSurfaceKHR)::Vector{vk.VkSurfaceFormatKHR}
    surfaceFormats = Vector{vk.VkSurfaceFormatKHR}()
    formatCount = Ref{UInt32}()
    vk.vkGetPhysicalDeviceSurfaceFormatsKHR(phyDevice, surface, formatCount, C_NULL)
    if (formatCount[] != 0)
        resize!(surfaceFormats, formatCount[])
        vk.vkGetPhysicalDeviceSurfaceFormatsKHR(phyDevice, surface, formatCount, surfaceFormats)
    end
    return surfaceFormats
end

function getSurfacePresentModesKHR(phyDevice::vk.VkPhysicalDevice, surface::vk.VkSurfaceKHR)::Vector{vk.VkPresentModeKHR}
    presentModes = Vector{vk.VkPresentModeKHR}(undef, 1)
    presentModeCount = Ref{UInt32}()
    vk.vkGetPhysicalDeviceSurfacePresentModesKHR(phyDevice, surface, presentModeCount, C_NULL)
    if (presentModeCount != 0)
        resize!(presentModes, presentModeCount[])
        vk.vkGetPhysicalDeviceSurfacePresentModesKHR(phyDevice, surface, presentModeCount, presentModes)
    end
    return presentModes
end

function getMemoryProperties(phyDevice::vk.VkPhysicalDevice)::vk.VkPhysicalDeviceMemoryProperties
    memoryProperties = Ref{vk.VkPhysicalDeviceMemoryProperties}()
    vk.vkGetPhysicalDeviceMemoryProperties(phyDevice, memoryProperties)
    return memoryProperties[]
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

function createCommandPool(logicalDevice::vk.VkDevice, createInfo::vk.VkCommandPoolCreateInfo)::vk.VkCommandPool
    commandPool = Ref{vk.VkCommandPool}()
    if (vk.vkCreateCommandPool(logicalDevice, Ref(createInfo), C_NULL, commandPool) != vk.VK_SUCCESS)
        error("Failed to create command pool!")
    end
    return commandPool[]
end

function createSemaphore(logicalDevice::vk.VkDevice,
                            createInfo::vk.VkSemaphoreCreateInfo = vk.VkSemaphoreCreateInfo(
                                                                        vk.VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO, #sType::VkStructureType
                                                                        C_NULL, #pNext::Ptr{Cvoid}
                                                                        0 #flags::VkSemaphoreCreateFlags
                                                                    ))
    semaphore = Ref{vk.VkSemaphore}()
    if (vk.vkCreateSemaphore(logicalDevice, Ref(createInfo), C_NULL, semaphore) != vk.VK_SUCCESS)
        error("Failed to create semaphore!")
    end
    return semaphore[]
end

function getSwapchainImagesKHR(logicalDevice::vk.VkDevice, swapchain::vk.VkSwapchainKHR)::Vector{vk.VkImage}
    imageCount = Ref{UInt32}()
    swapChainImages = Vector{vk.VkImage}()
    vk.vkGetSwapchainImagesKHR(logicalDevice, swapchain, imageCount, C_NULL)
    resize!(swapChainImages, imageCount[])
    vk.vkGetSwapchainImagesKHR(logicalDevice, swapchain, imageCount, swapChainImages)
    return swapChainImages
end

function allocateMemory(logicalDevice::vk.VkDevice, allocateInfo::Ref{vk.VkMemoryAllocateInfo})::vk.VkDeviceMemory
    memory = Ref{vk.VkDeviceMemory}()
    vk.vkAllocateMemory(logicalDevice, allocateInfo, C_NULL, memory)
    return memory[]
end

function getImageMemoryRequirements(logicalDevice::vk.VkDevice, image::vk.VkImage)::vk.VkMemoryRequirements
    memoryRequirements = Ref{vk.VkMemoryRequirements}()
    vk.vkGetImageMemoryRequirements(logicalDevice, image, memoryRequirements)
    return memoryRequirements[]
end

function getBufferMemoryRequirements(logicalDevice::vk.VkDevice, buffer::vk.VkBuffer)::vk.VkMemoryRequirements
    memoryRequirements = Ref{vk.VkMemoryRequirements}()
    vk.vkGetBufferMemoryRequirements(logicalDevice, buffer, memoryRequirements)
    return memoryRequirements[]
end

function createBuffer(logicalDevice::vk.VkDevice, createInfo::Ref{vk.VkBufferCreateInfo})::vk.VkBuffer
    buffer = Ref{vk.VkBuffer}()
    if vk.vkCreateBuffer(logicalDevice, createInfo, C_NULL, buffer) != vk.VK_SUCCESS
        error("Failed to create buffer!")
    end
    return buffer[]
end

function mapMemory(logicalDevice::vk.VkDevice, memory::vk.VkDeviceMemory, offset::vk.VkDeviceSize, size::vk.VkDeviceSize, flags::vk.VkMemoryMapFlags)::Ptr{Cvoid}
    pData = Ref{Ptr{Cvoid}}()
    if vk.vkMapMemory(logicalDevice, memory, offset, size, flags, pData) != vk.VK_SUCCESS
        error("Failed to map memory!")
    end
    return pData[]
end

function waitForFences(logicalDevice::vk.VkDevice, fences::Vector{vk.VkFence}, waitAll::vk.VkBool32, timeout::UInt64)
    if vk.vkWaitForFences(logicalDevice, length(fences), pointer(fences), waitAll, timeout) != vk.VK_SUCCESS
        error("Failed to wait for fences!")
    end
end

function createFence(logicalDevice::vk.VkDevice)::vk.VkFence
    fenceInfo = Ref(vk.VkFenceCreateInfo(
        vk.VK_STRUCTURE_TYPE_FENCE_CREATE_INFO, #sType::VkStructureType
        C_NULL, #pNext::Ptr{Cvoid}
        0 #flags::VkFenceCreateFlags
    ))
    outFence = Ref{vk.VkFence}()
    err = vk.vkCreateFence(logicalDevice, fenceInfo, C_NULL, outFence)
    if err == vk.VK_ERROR_OUT_OF_HOST_MEMORY
        error("Queue::findFreeFence(): Ran out of memory trying to allocate a fence for CommandBuffer submission. \n" *
              "Use Queue::catchUp to prevent oversized backlogs of submissions.")
    elseif err != vk.VK_SUCCESS
        error("Failed to create fence!")
    end
    return outFence[]
end

function vkCreateRayTracingPipelinesNV(device, pipelineCache, createInfoCount, pCreateInfos, pAllocator, pPipelines)
    fnptr = vk.vkGetDeviceProcAddr(device, "vkCreateRayTracingPipelinesNV") |> vk.PFN_vkCreateRayTracingPipelinesNV
    ccall(fnptr, vk.VkResult, (vk.VkDevice, vk.VkPipelineCache, UInt32, Ptr{vk.VkRayTracingPipelineCreateInfoNV}, Ptr{vk.VkAllocationCallbacks}, Ptr{vk.VkPipeline}),
                               device, pipelineCache, createInfoCount, pCreateInfos, pAllocator, pPipelines)
end

function vkGetRayTracingShaderGroupHandlesNV(device, pipeline, firstGroup, groupCount, dataSize, pData)
    fnptr = vk.vkGetDeviceProcAddr(device, "vkGetRayTracingShaderGroupHandlesNV") |> vk.PFN_vkGetRayTracingShaderGroupHandlesNV
    ccall(fnptr, vk.VkResult, (vk.VkDevice, vk.VkPipeline, UInt32, UInt32, Csize_t, Ptr{Cvoid}),
                               device, pipeline, firstGroup, groupCount, dataSize, pData)
end

# common
function ClearValue(color::vk.VkClearColorValue)
    return vk.VkClearValue(color)
end

function ClearValue(depthStencil::vk.VkClearDepthStencilValue)
    vk.VkClearValue(vk.VkClearColorValue((depthStencil.depth, depthStencil.stencil, 0, 0)))
end

# cmd
function vkCmdPipelineBarrier(commandBuffer::vk.VkCommandBuffer,
                              srcStageMask::VkPipelineStageFlags, dstStageMask::VkPipelineStageFlags,
                              dependencyFlags::VkDependencyFlags;
                              memoryBarriers = nothing,
                              bufferMemoryBarriers = nothing,
                              imageMemoryBarriers = nothing)
    vk.vkCmdPipelineBarrier(commandBuffer, srcStageMask, dstStageMask, dependencyFlags,
                            memoryBarriers == nothing ? 0 : length(memoryBarriers),
                            memoryBarriers == nothing ? C_NULL : pointer(memoryBarriers),
                            bufferMemoryBarriers == nothing ? 0 : length(bufferMemoryBarriers),
                            bufferMemoryBarriers == nothing ? C_NULL : pointer(bufferMemoryBarriers),
                            imageMemoryBarriers == nothing ? 0 : length(imageMemoryBarriers),
                            imageMemoryBarriers == nothing ? C_NULL : pointer(imageMemoryBarriers))
end

end #module
