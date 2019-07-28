#module Instance
export InstanceT

using VulkanCore
#using Feature
using features
#IFeatureT = features.IFeatureT
using lava: Device, ISelectionStrategy
using VkExt

strings2pp(names::Vector{String}) = (ptr = Base.cconvert(Ptr{Cstring}, names); GC.@preserve ptr Base.unsafe_convert(Ptr{Cstring}, ptr))
function chars2String(chars)::String
    charArray = UInt8[chars...]
    return String(Base.getindex(charArray, 1:Base.findfirst(x->x==0, charArray) - 1))
end

mutable struct InstanceT
    mFeatures::Array{IFeatureT, 1}
    mInstance::VkInstance

    function InstanceT(inFeatures::Array{IFeatureT, 1})
        this = new(inFeatures)

        # get required extension names
        extensionCount = Ref{UInt32}(0)
        vk.vkEnumerateInstanceExtensionProperties(C_NULL, extensionCount, C_NULL)
        availableExtensions = Array{vk.VkExtensionProperties, 1}(undef, extensionCount[])
        vk.vkEnumerateInstanceExtensionProperties(C_NULL, extensionCount, availableExtensions)

        avaliableExtNames = Array{String, 1}(undef, extensionCount[])
        for i = 1 : extensionCount[]
            avaliableExtNames[i] = chars2String(availableExtensions[i].extensionName)
        end
        
        # get required layer names
        layerCount = Ref{UInt32}(0)
        vk.vkEnumerateInstanceLayerProperties(layerCount, C_NULL);
        avaliableLayers = Array{vk.VkLayerProperties, 1}(undef, layerCount[])
        vk.vkEnumerateInstanceLayerProperties(layerCount, avaliableLayers)

        avaliableLayerNames = Array{String, 1}(undef, layerCount[])
        for i = 1 : layerCount[]
            avaliableLayerNames[i] = chars2String(avaliableLayers[i].layerName)
        end
    
        requiredExtNames = Array{String, 1}()
        requiredLayerNames = Array{String, 1}()
        for feat in this.mFeatures
            extNames = features.instanceExtensions(feat, avaliableExtNames)
            append!(requiredExtNames, extNames)
            layerNames = features.layers(feat, avaliableLayerNames)
            append!(requiredLayerNames, layerNames)
        end

        # create instance
        info = vk.VkInstanceCreateInfo(
            vk.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO, #sType::VkStructureType
            C_NULL, #pNext::Ptr{Cvoid}
            UInt32(0), #flags::VkInstanceCreateFlags
            C_NULL, #pApplicationInfo::Ptr{VkApplicationInfo}
            length(requiredLayerNames), #enabledLayerCount::UInt32
            strings2pp(requiredLayerNames), #ppEnabledLayerNames::Ptr{Cstring}
            length(requiredExtNames), #enabledExtensionCount::UInt32
            strings2pp(requiredExtNames), #ppEnabledExtensionNames::Ptr{Cstring}
        )

        this.mInstance = VkExt.createInstance(info)

        for feat in this.mFeatures
            features.onInstanceCreated(feat, this)
        end

        return this
    end
end

function create(::Type{InstanceT}, features::Array{IFeatureT, 1})::InstanceT
    return InstanceT(features)
end

function createDevice(this::InstanceT, queues, gpuSelectionStrategy::ISelectionStrategy)
    device = Device(this.mInstance, this.mFeatures, gpuSelectionStrategy, queues)
    for feat in this.mFeatures
        features.onLogicalDeviceCreated(feat, device)
    end
    return device
end