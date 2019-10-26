mutable struct GlfwWindow
    mChainFormat::vk.VkSurfaceFormatKHR
    mWidth::UInt32
    mHeight::UInt32
    mResizable::Bool
    mTitle::String
    mWindow::GLFW.Window
    mSurface::vk.VkSurfaceKHR


    function GlfwWindow(vkInstance::vk.VkInstance, format::vk.VkSurfaceFormatKHR,
                        width::UInt32, height::UInt32, resizable::Bool, title::String)
        this = new()
        this.mChainFormat = format
        this.mWidth = width
        this.mHeight = height
        this.mResizable = resizable
        this.mTitle = title

        GLFW.WindowHint(GLFW.CLIENT_API, GLFW.NO_API)
        GLFW.WindowHint(GLFW.VISIBLE, true)
        GLFW.WindowHint(GLFW.RESIZABLE, this.mResizable ? true : false)
        this.mWindow = GLFW.CreateWindow(width, height, title)
        this.mSurface = GLFW.CreateWindowSurface(vkInstance, this.mWindow)
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