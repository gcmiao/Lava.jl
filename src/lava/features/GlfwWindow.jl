using lava: graphicsQueue, namedQueue, family
mutable struct GlfwWindow
    mPhysicalDevice::vk.VkPhysicalDevice
    mVkDevice::vk.VkDevice
    mDevice
    mChainFormat::vk.VkSurfaceFormatKHR

    mWidth::UInt32
    mHeight::UInt32
    mResizable::Bool
    mTitle::String
    mWindow::GLFW.Window
    mQueue::Queue
    mSurface::vk.VkSurfaceKHR
    mChain::vk.VkSwapchainKHR

    mImageReady::vk.VkSemaphore
    mRenderingComplete::vk.VkSemaphore

    mChainImages::Vector{Image}
    mChainViews::Vector{ImageView}
    mSwapchainHandler#::SwapchainBuildHandler

    mSwapchainInfo::vk.VkSwapchainCreateInfoKHR

    function GlfwWindow(phyDevice::vk.VkPhysicalDevice, vkDevice::vk.VkDevice, device, format::vk.VkSurfaceFormatKHR,
                        width::UInt32, height::UInt32, resizable::Bool, title::String)
        this = new()
        this.mPhysicalDevice = phyDevice
        this.mVkDevice = vkDevice
        this.mDevice = device
        this.mChainFormat = format
        this.mWidth = width
        this.mHeight = height
        this.mResizable = resizable
        this.mTitle = title
        this.mSwapchainHandler = nothing

        GLFW.WindowHint(GLFW.CLIENT_API, GLFW.NO_API)
        GLFW.WindowHint(GLFW.VISIBLE, true)
        GLFW.WindowHint(GLFW.RESIZABLE, mResizable ? true : false)
        this.mWindow = GLFW.CreateWindow(width, height, title)
        this.mQueue = namedQueue(this.mDevice, "present")

        this.mSurface = GLFW.CreateWindowSurface(instance[], this.mWindow)
        this.mImageReady = VkExt.createSemaphore(vkDevice)
        this.mRenderingComplete = VkExt.createSemaphore(vkDevice)
    end
end
