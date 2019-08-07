using GLFW
using VulkanCore
using VkExt
#using lava: QueueRequest, createByFamily

mutable struct GlfwOutputT <: IFeatureT
    mInstance::VkExt.VkInstance
    mPhysicalDevice::vk.VkPhysicalDevice
    mDevice

    mTempWindow::GLFW.Window
    mTempSurface::vk.VkSurfaceKHR

    mPresentIndex::UInt32

    function GlfwOutputT()
        this = new()
        GLFW.Init()
        return this
    end
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
    return [vk.VK_KHR_SWAPCHAIN_EXTENSION_NAME]
end

function onInstanceCreated(this::GlfwOutputT, instance::VkExt.VkInstance)
    this.mInstance = instance

    GLFW.WindowHint(GLFW.CLIENT_API, GLFW.NO_API)
    GLFW.WindowHint(GLFW.VISIBLE, false)
    #GLFW.WindowHint(GLFW.RESIZABLE, false)

    this.mTempWindow = GLFW.CreateWindow(100, 100, "Vulkan")
    this.mTempSurface = GLFW.CreateWindowSurface(this.mInstance.vkInstance, this.mTempWindow)
end

function onLogicalDeviceCreated(this::GlfwOutputT, device)
    this.mDevice = device
end

function onPhysicalDeviceSelected(this::GlfwOutputT, phy::vk.VkPhysicalDevice)
    this.mPhysicalDevice = phy

    # TODO
    # mChainFormat = bestFormat(phy, mTempSurface)
end

function supportsDevice(this::GlfwOutputT, dev::vk.VkPhysicalDevice)
    families = VkExt.getQueueFamilyProperties(dev)
    for i::UInt32 = 0 : length(families) - 1 #queueFamilyIndex should start from 0
        if VkExt.getSurfaceSupportKHR(dev, i, this.mTempSurface) == vk.VK_TRUE
            return true
        end
    end
    return false
end

# function addPhysicalDeviceFeatures(this::GlfwOutputT, outDeviceFeatures::VkExt.VkPhysicalDeviceFeatures)
# end


