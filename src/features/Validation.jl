mutable struct Validation <: IFeatureT
    mVkInstance::vk.VkInstance
    
    mPaused::Bool
    mMessageCount::UInt32
    mCallback::vk.VkDebugReportCallbackEXT

    function Validation()
        this = new()
        mPaused = false
        mMessageCount = 0
        return this
    end
end

function LavaCore.:destroy(this::Validation)
    return
    println("Destroy Validation: ", this.mCallback)
    if this.mCallback != 0
        VkExt.destroyDebugReportCallbackEXT(this.mVkInstance, this.mCallback)
        this.mCallback = vk.VkDebugReportCallbackEXT(0)
    end
end

function create(::Type{Validation})
    return Validation()
end

function paused(this::Validation)
    return this.mPaused
end

function bumpMessageCount(this::Validation)
    this.mMessageCount += 1
end

function debugCallback(flags::vk.VkDebugReportFlagsEXT,
                     objType::vk.VkDebugReportObjectTypeEXT,
                         obj,
                    location::UInt64,
                        code::Int32,
                 layerPrefix,
                         msg,
                    userData)

    validationPtr = Base.unsafe_convert(Ptr{Validation}, userData)
    validation = Base.unsafe_load(validationPtr)
    if (paused(validation))
        return VkExt.VK_FALSE
    end

    bumpMessageCount(validation)
    println("--------", validation.mMessageCount , ".Debug Report--------")
    println("flags:", flags)
    println("objType:", objType)
    println("obj:", obj)
    println("location:", location)
    println("code:", code)
    println("layerPrefix:", unsafe_string(layerPrefix))
    println("msg:", unsafe_string(msg))

    return VkExt.VK_FALSE
end

function beforeInstanceDestruction(this::Validation)
    println("Before instance destruct in Validation: ", this.mCallback)
    if this.mCallback != 0
        VkExt.destroyDebugReportCallbackEXT(this.mVkInstance, this.mCallback)
        this.mCallback = vk.VkDebugReportCallbackEXT(0)
    end
end

########## override begin ##########
function LavaCore.:layers(this::Validation, available::Vector{String})::Vector{String}
    return ["VK_LAYER_LUNARG_standard_validation"]
end

function LavaCore.:instanceExtensions(this::Validation, available::Vector{String})::Vector{String}
    return [vk.VK_EXT_DEBUG_REPORT_EXTENSION_NAME]
end

function LavaCore.:onInstanceCreated(this::Validation, vkInstance::vk.VkInstance)
    this.mVkInstance = vkInstance
    pfnCallback = @cfunction(debugCallback, vk.VkBool32, (vk.VkDebugReportFlagsEXT, vk.VkDebugReportObjectTypeEXT, Culonglong, Csize_t, Cint, Cstring, Cstring, Ptr{Cvoid}))
    validationRef = Ref(this)
    debug = vk.VkDebugReportCallbackCreateInfoEXT(
        vk.VK_STRUCTURE_TYPE_DEBUG_REPORT_CALLBACK_CREATE_INFO_EXT, #sType::VkStructureType
        C_NULL, #pNext::Ptr{Cvoid}
        vk.VK_DEBUG_REPORT_ERROR_BIT_EXT | vk.VK_DEBUG_REPORT_WARNING_BIT_EXT, #flags::VkDebugReportFlagsEXT
        pfnCallback, #pfnCallback::PFN_vkDebugReportCallbackEXT
        Base.unsafe_convert(Ptr{Cvoid}, validationRef) #pUserData::Ptr{Cvoid}
    )
    this.mCallback = VkExt.createDebugReportCallbackEXT(vkInstance, debug);
end
########## override end ##########
