using VulkanCore
using features
using lava: Device, ISelectionStrategy
using VkExt

strings2pp(names::Vector{String}) = (ptr = Base.cconvert(Ptr{Cstring}, names); GC.@preserve ptr Base.unsafe_convert(Ptr{Cstring}, ptr))
function chars2String(chars)::String
    charArray = UInt8[chars...]
    return String(Base.getindex(charArray, 1:Base.findfirst(x->x==0, charArray) - 1))
end

mutable struct InstanceT
    mFeatures::Array{features.IFeatureT, 1}
    mInstance::VkExt.VkInstance

    function InstanceT(inFeatures::Array{features.IFeatureT, 1})
        this = new(inFeatures)

        # get required extension names
        availableExtensions, extCount = VkExt.enumerateInstanceExtensionProperties()
        avaliableExtNames = Array{String, 1}(undef, extCount)
        for i = 1 : extCount
            avaliableExtNames[i] = chars2String(availableExtensions[i].extensionName)
        end
        
        # get required layer names
        avaliableLayers, layerCount = VkExt.enumerateInstanceLayerProperties()
        avaliableLayerNames = Array{String, 1}(undef, layerCount)
        for i = 1 : layerCount
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
            features.onInstanceCreated(feat, this.mInstance)
        end

        return this
    end
end

function create(::Type{InstanceT}, features::Array{features.IFeatureT, 1})::InstanceT
    return InstanceT(features)
end

function createDevice(this::InstanceT, queues::Array{QueueRequest, 1}, gpuSelectionStrategy::ISelectionStrategy)
    device = Device(this.mInstance, this.mFeatures, gpuSelectionStrategy, queues)
    for feat in this.mFeatures
        features.onLogicalDeviceCreated(feat, device)
    end
    return device
end