using GLFW

mutable struct GlfwWindow
    mDevice::Device
    mChainFormat::vk.VkSurfaceFormatKHR

    mWidth::UInt32
    mHeight::UInt32
    mResizable::Bool
    mTitle::String
    mWindow::GLFW.Window
    mSurface::vk.VkSurfaceKHR
    mChain::vk.VkSwapchainKHR

    mImageReady::vk.VkSemaphore
    mRenderingComplete::vk.VkSemaphore
    
    mQueue::Queue

    mChainImages::Vector{Image}
    mChainViews::Vector{ImageView}
    mSwapchainHandler#::SwapchainBuildHandler
    
    mSwapchainInfo::vk.VkSwapchainCreateInfoKHR

    function GlfwWindow(device::Device, format::vk.VkSurfaceFormatKHR,
                        width::UInt32, height::UInt32, resizable::Bool, title::String)
        this = new()
        this.mDevice = device
        this.mChainFormat = format
        this.mWidth = width
        this.mHeight = height
        this.mResizable = resizable
        this.mTitle = title

        this.mChainImages = Vector{Image}()
        this.mChainViews = Vector{ImageView}()
        this.mSwapchainHandler = nothing

        GLFW.WindowHint(GLFW.CLIENT_API, GLFW.NO_API)
        GLFW.WindowHint(GLFW.VISIBLE, true)
        GLFW.WindowHint(GLFW.RESIZABLE, this.mResizable ? true : false)
        this.mWindow = GLFW.CreateWindow(width, height, title)
        this.mQueue = namedQueue(this.mDevice, "present")
        this.mSurface = GLFW.CreateWindowSurface(getInstance(device), this.mWindow)
        vkDevice = getLogicalDevice(this.mDevice)
        this.mImageReady = VkExt.createSemaphore(vkDevice)
        this.mRenderingComplete = VkExt.createSemaphore(vkDevice)

        return this
    end
end

function setSize(this::GlfwWindow, width::UInt32, height::UInt32)
    this.mWidth = width
    this.mHeight = height
end

function getSurface(this::GlfwWindow)::vk.VkSurfaceKHR
    return this.mSurface
end

function getSurfaceFormat(this::GlfwWindow)::vk.VkSurfaceFormatKHR
    return this.mChainFormat
end

function getWidth(this::GlfwWindow)
    return this.mWidth
end

function getHeight(this::GlfwWindow)
    return this.mHeight
end

function buildSwapchainWith(this::GlfwWindow, handler)
    this.mSwapchainHandler = handler
    buildSwapchain(this)
end

function buildSwapchain(this::GlfwWindow)
    empty!(this.mChainImages)
    empty!(this.mChainViews)

    # TODO
    # if this.mChain
    #     mDevice->handle().destroySwapchainKHR(mChain);
    # end
    phyDevice = getPhysicalDevice(this.mDevice)
    capRef = Ref{vk.VkSurfaceCapabilitiesKHR}()
    vk.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(phyDevice, this.mSurface, capRef)
    cap = capRef[]
    setSize(this, cap.currentExtent.width, cap.currentExtent.height)

    pres = bestMode(phyDevice, this.mSurface)

    supp = Ref{vk.VkBool32}(false)
    vk.vkGetPhysicalDeviceSurfaceSupportKHR(phyDevice, family(this.mQueue), this.mSurface, supp)
    if(supp[] != vk.VK_TRUE)
        error("The selected queue family can't present to this device.")
    end

    imageSharingMode = 0
    queueFamilyIndexCount = 0
    queueFamilyIndices = C_NULL
    families = 0
    if family(graphicsQueue(this.mDevice)) == family(this.mQueue)
        imageSharingMode = vk.VK_SHARING_MODE_EXCLUSIVE
    else
        imageSharingMode = vk.VK_SHARING_MODE_CONCURRENT
        families = [family(graphicsQueue(this.mDevice)), family(this.mQueue)]
        queueFamilyIndexCount = 2
        queueFamilyIndices = pointer(families)
    end

    createInfo = Ref(vk.VkSwapchainCreateInfoKHR(
        vk.VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR, #sType
        C_NULL, #pNext
        vk.VkFlags(0), #flags
        this.mSurface, #surface
        cap.minImageCount, #minImageCount
        this.mChainFormat.format, #imageFormat
        this.mChainFormat.colorSpace, #imageColorSpace
        cap.currentExtent, #imageExtent
        1, #imageArrayLayers
        vk.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | vk.VK_IMAGE_USAGE_TRANSFER_DST_BIT, #imageUsage
        imageSharingMode, #imageSharingMode::VkSharingMode
        queueFamilyIndexCount, #queueFamilyIndexCount::UInt32
        queueFamilyIndices, #pQueueFamilyIndices::Ptr{UInt32}
        cap.currentTransform, #preTransform::VkSurfaceTransformFlagBitsKHR
        vk.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR, #compositeAlpha::VkCompositeAlphaFlagBitsKHR
        pres, #presentMode::VkPresentModeKHR
        vk.VK_TRUE, #clipped::VkBool32
        vk.VK_NULL_HANDLE #oldSwapchain::VkSwapchainKHR
    ))

    vkDevice = getLogicalDevice(this.mDevice)
    swapChain = Ref{vk.VkSwapchainKHR}()
    if (vk.vkCreateSwapchainKHR(vkDevice, createInfo, C_NULL, swapChain) != vk.VK_SUCCESS)
        error("Failed to create swap chain!")
    end
    this.mChain = swapChain[]
    chainHandles = VkExt.getSwapchainImagesKHR(vkDevice, this.mChain)
    imgCreateInfo = attachment2D(phyDevice, this.mWidth, this.mHeight, this.mChainFormat.format)
    for handle::vk.VkImage in chainHandles
        image = Image(this.mDevice, handleRef(imgCreateInfo)[], handle, vk.VK_IMAGE_VIEW_TYPE_2D)
        #push!(this.mChainViews, createView(image)) ???
        push!(this.mChainImages, image)
    end

    for img in this.mChainImages
        push!(this.mChainViews, createView(img))
    end

    this.mSwapchainInfo = createInfo[]
    if this.mSwapchainHandler != nothing
        this.mSwapchainHandler(this.mChainViews)
    end
end

function bestMode(phyDev::vk.VkPhysicalDevice, surf::vk.VkSurfaceKHR)::vk.VkPresentModeKHR
    prios = [vk.VK_PRESENT_MODE_MAILBOX_KHR,
            # Fifo-Modes are bugged on nvidia currently, so rather accept tearing
            # than the whole system freezing
            vk.VK_PRESENT_MODE_IMMEDIATE_KHR,
            vk.VK_PRESENT_MODE_FIFO_KHR,
            vk.VK_PRESENT_MODE_FIFO_RELAXED_KHR]

    modes = VkExt.getSurfacePresentModesKHR(phyDev, surf)
    for target in prios
        for candidate in modes
            if (target == candidate)
                return target
            end
        end
    end
    return modes[1]
end