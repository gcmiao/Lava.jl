using GLFW
using VulkanCore
using VkExt
using StringHelper

mutable struct Validation <: IFeatureT
    mInstance::VkExt.VkInstance
    
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

#TODO: Deconstruction
# Validation::~Validation() {
#     if (mCallback) {
#         mInstance.destroyDebugReportCallbackEXT(mCallback);
#         mCallback = vk::DebugReportCallbackEXT{};
#     }
# }

function create(::Type{Validation})
    return Validation()
end

# TODO
# Validation::~Validation() {
#     if (mCallback) {
#         mInstance.destroyDebugReportCallbackEXT(mCallback);
#         mCallback = vk::DebugReportCallbackEXT{};
#     }
# }

function layers(this::Validation, available::Array{String, 1})::Array{String, 1}
    return ["VK_LAYER_LUNARG_standard_validation"]
end

function instanceExtensions(this::Validation, available::Array{String, 1})::Array{String, 1}
    return [vk.VK_EXT_DEBUG_REPORT_EXTENSION_NAME]
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

function onInstanceCreated(this::Validation, instance::VkExt.VkInstance)
    pfnCallback = @cfunction(debugCallback, vk.VkBool32, (vk.VkDebugReportFlagsEXT, vk.VkDebugReportObjectTypeEXT, Culonglong, Csize_t, Cint, Cstring, Cstring, Ptr{Cvoid}))
    validationRef = Ref(this)
    debug = vk.VkDebugReportCallbackCreateInfoEXT(
        vk.VK_STRUCTURE_TYPE_DEBUG_REPORT_CALLBACK_CREATE_INFO_EXT, #sType::VkStructureType
        C_NULL, #pNext::Ptr{Cvoid}
        vk.VK_DEBUG_REPORT_ERROR_BIT_EXT | vk.VK_DEBUG_REPORT_WARNING_BIT_EXT, #flags::VkDebugReportFlagsEXT
        pfnCallback, #pfnCallback::PFN_vkDebugReportCallbackEXT
        Base.unsafe_convert(Ptr{Cvoid}, validationRef) #pUserData::Ptr{Cvoid}
    )
    mCallback = VkExt.createDebugReportCallbackEXT(instance.vkInstance, debug);
end

# TODO
# void Validation::beforeInstanceDestruction()
# {
#     if (mCallback) {
#         mInstance.destroyDebugReportCallbackEXT(mCallback);
#         mCallback = vk::DebugReportCallbackEXT{};
#     }
# }