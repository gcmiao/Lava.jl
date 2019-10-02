mutable struct SwapChain
    mDevice::Device
    mWindow::features.GlfwWindow
    mQueue::Queue
    mChain::vk.VkSwapchainKHR
    mImageReady::vk.VkSemaphore
    mRenderingComplete::vk.VkSemaphore

    mChainImages::Vector{Image}
    mChainViews::Vector{ImageView}
    mSwapchainHandler#::SwapchainBuildHandler

    mSwapchainInfo::vk.VkSwapchainCreateInfoKHR

    function SwapChain(device::Device)
        this = new()
        this.mDevice = device
        this.mQueue = namedQueue(this.mDevice, "present")

        this.mChainImages = Vector{Image}()
        this.mChainViews = Vector{ImageView}()

        this.mSwapchainHandler = nothing

        vkDevice = getLogicalDevice(this.mDevice)
        this.mImageReady = VkExt.createSemaphore(vkDevice)
        this.mRenderingComplete = VkExt.createSemaphore(vkDevice)
        return this
    end
end

function buildSwapchainWith(this::SwapChain, window::features.GlfwWindow, handler)
    this.mSwapchainHandler = handler
    buildSwapchain(this, window)
end

function buildSwapchain(this::SwapChain, window::features.GlfwWindow)
    empty!(this.mChainImages)
    empty!(this.mChainViews)

    # TODO
    # if this.mChain
    #     mDevice->handle().destroySwapchainKHR(mChain);
    # end
    this.mWindow = window
    phyDevice = getPhysicalDevice(this.mDevice)
    surface = features.getSurface(this.mWindow)
    capRef = Ref{vk.VkSurfaceCapabilitiesKHR}()
    vk.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(phyDevice, surface, capRef)
    cap = capRef[]
    features.setSize(this.mWindow, cap.currentExtent.width, cap.currentExtent.height)

    pres = bestMode(phyDevice, surface)

    supp = Ref{vk.VkBool32}(false)
    vk.vkGetPhysicalDeviceSurfaceSupportKHR(phyDevice, family(this.mQueue), surface, supp)
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

    chainFormat = features.getSurfaceFormat(this.mWindow)
    createInfo = Ref(vk.VkSwapchainCreateInfoKHR(
        vk.VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR, #sType
        C_NULL, #pNext
        vk.VkFlags(0), #flags
        features.getSurface(this.mWindow), #surface
        cap.minImageCount, #minImageCount
        chainFormat.format, #imageFormat
        chainFormat.colorSpace, #imageColorSpace
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
    imgCreateInfo = attachment2D(phyDevice, this.mWindow.mWidth, this.mWindow.mHeight, chainFormat.format)
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