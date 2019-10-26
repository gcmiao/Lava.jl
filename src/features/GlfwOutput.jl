#using lava: QueueRequest, createByFamily


mutable struct GlfwOutputT <: IFeatureT
    mVkInstance::vk.VkInstance
    mPhysicalDevice::vk.VkPhysicalDevice
    mDevice #::Device

    mTempWindow::GLFW.Window
    mTempSurface::vk.VkSurfaceKHR
    mChainFormat::vk.VkSurfaceFormatKHR

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

function layers(this::GlfwOutputT, available::Vector{String})::Vector{String}
    return []
end

function openWindow(this::GlfwOutputT, width::UInt32 = UInt32(800), height::UInt32 = UInt32(600), resizable::Bool = false, title::String = "Lava Window")::GlfwWindow
    return GlfwWindow(this.mVkInstance, this.mChainFormat, width, height, resizable, title)
end

function instanceExtensions(this::GlfwOutputT, available::Vector{String})::Vector{String}
    ret = Vector{String}()
    glfwReqExts = GLFW.GetRequiredInstanceExtensions()
    extCount = length(glfwReqExts)
    
    # TODO: check availability
    
    append!(ret, glfwReqExts)
    return ret
end

function deviceExtensions(this::GlfwOutputT)::Vector{String}
    return [vk.VK_KHR_SWAPCHAIN_EXTENSION_NAME]
end

function onInstanceCreated(this::GlfwOutputT, vkInstance::vk.VkInstance)
    this.mVkInstance = vkInstance

    GLFW.WindowHint(GLFW.CLIENT_API, GLFW.NO_API)
    GLFW.WindowHint(GLFW.VISIBLE, false)
    #GLFW.WindowHint(GLFW.RESIZABLE, false)

    this.mTempWindow = GLFW.CreateWindow(100, 100, "Vulkan")
    this.mTempSurface = GLFW.CreateWindowSurface(this.mVkInstance, this.mTempWindow)
end

function onLogicalDeviceCreated(this::GlfwOutputT, device)
    this.mDevice = device
end

function bestFormat(dev::vk.VkPhysicalDevice, surface::vk.VkSurfaceKHR)::vk.VkSurfaceFormatKHR
    formats = VkExt.getSurfaceFormatsKHR(dev, surface)

    if (length(formats) == 1) && (formats[1].format == vk.VK_FORMAT_UNDEFINED)
        return vk.VkSurfaceFormatKHR(
                                        vk.VK_FORMAT_R8G8B8A8_SRGB, #format::VkFormat
                                        vk.VK_COLOR_SPACE_SRGB_NONLINEAR_KHR#colorSpace::VkColorSpaceKHR
                                    )
    end

    for f in formats
        if (f.format == vk.VK_FORMAT_B8G8R8A8_SRGB ||
            f.format == vk.VK_FORMAT_R8G8B8A8_SRGB ||
            f.format == vk.VK_FORMAT_B8G8R8_SRGB ||
            f.format == vk.VK_FORMAT_R8G8B8_SRGB)
            return f
        end
    end

    for f in formats
        if (f.format == vk.VK_FORMAT_B8G8R8A8_UNORM ||
            f.format == vk.VK_FORMAT_R8G8B8A8_UNORM ||
            f.format == vk.VK_FORMAT_B8G8R8_UNORM ||
            f.format == vk.VK_FORMAT_R8G8B8_UNORM)
            return f
        end
    end

    error("No suitable format found!")
end

function onPhysicalDeviceSelected(this::GlfwOutputT, phy::vk.VkPhysicalDevice)
    this.mPhysicalDevice = phy
    this.mChainFormat = bestFormat(phy, this.mTempSurface)
end

function supportsDevice(this::GlfwOutputT, dev::vk.VkPhysicalDevice)::Bool
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

function format(this::GlfwOutputT)::vk.VkFormat
    return this.mChainFormat.format
end
