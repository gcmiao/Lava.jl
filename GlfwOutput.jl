#module GlfwOutput
export GlfwOutputT, create

using features: IFeatureT
using GLFW
using VulkanCore

mutable struct GlfwOutputT <: IFeatureT
    layers::Array{String}
    instanceExtensions::Array{String}
    deviceExtensions::Array{String}
    mInstance::Any
    mPhysicalDevice::vk.VkPhysicalDevice
    mDevice

    GlfwOutputT() = new()
end

function create(::Type{GlfwOutputT})
    return GlfwOutputT()
end

function layers(this::GlfwOutputT, available::Array{String})::Array{String}
    return []
end

function instanceExtensions(this::GlfwOutputT, available::Array{String})::Array{String}
    ret = Array{String, 1}()
    glfwReqExts = GLFW.GetRequiredInstanceExtensions()
    extCount = length(glfwReqExts)
    
    # TODO: check availability
    
    append!(ret, glfwReqExts)
    return ret
end

function deviceExtensions(this::GlfwOutputT)::Array{String}
    
end

function onInstanceCreated(this::GlfwOutputT, instance)
    mInstance = instance
end

function onLogicalDeviceCreated(this::GlfwOutputT, device)
    mDevice = device
end

function onPhysicalDeviceSelected(this::GlfwOutputT, phy::vk.VkPhysicalDevice)
    this.mPhysicalDevice = phy;

    # TODO
    # mChainFormat = bestFormat(phy, mTempSurface);
end

function supportsDevice(this::GlfwOutputT, device::vk.VkPhysicalDevice)
    # TODO
    # auto families = dev.getQueueFamilyProperties();
    # for (uint32_t i = 0; i < families.size(); i++) {
    #     if (dev.getSurfaceSupportKHR(i, mTempSurface))
    #         return true;
    # }
    # return false;
    return true
end

#end