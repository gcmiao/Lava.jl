mutable struct InstanceT
    mFeatures::Vector{features.IFeatureT}
    mInstance::VkExt.VkInstance

    function InstanceT(inFeatures::Vector{features.IFeatureT})
        this = new()
        this.mFeatures = inFeatures

        # get required extension names
        availableExtensions, extCount = VkExt.enumerateInstanceExtensionProperties()
        avaliableExtNames = Vector{String}(undef, extCount)
        for i = 1 : extCount
            avaliableExtNames[i] = StringHelper.chars2String(availableExtensions[i].extensionName)
        end
        
        # get required layer names
        avaliableLayers, layerCount = VkExt.enumerateInstanceLayerProperties()
        avaliableLayerNames = Vector{String}(undef, layerCount)
        for i = 1 : layerCount
            avaliableLayerNames[i] = StringHelper.chars2String(avaliableLayers[i].layerName)
        end
    
        requiredExtNames = Vector{String}()
        requiredLayerNames = Vector{String}()
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
            StringHelper.strings2pp(requiredLayerNames), #ppEnabledLayerNames::Ptr{Cstring}
            length(requiredExtNames), #enabledExtensionCount::UInt32
            StringHelper.strings2pp(requiredExtNames), #ppEnabledExtensionNames::Ptr{Cstring}
        )

        this.mInstance = VkExt.createInstance(info)

        for feat in this.mFeatures
            features.onInstanceCreated(feat, this.mInstance)
        end

        return this
    end
end

# TODO: Deconstruction
# Instance::~Instance() {
#     for (auto &&feat : mFeatures)
#         feat->beforeInstanceDestruction();
# }

function create(::Type{InstanceT}, inFeatures::Vector{features.IFeatureT})::InstanceT
    return InstanceT(inFeatures)
end

function createDevice(this::InstanceT, queues::Vector{QueueRequest}, gpuSelectionStrategy::ISelectionStrategy)
    device = Device(this.mInstance, this.mFeatures, gpuSelectionStrategy, queues)
    for feat in this.mFeatures
        features.onLogicalDeviceCreated(feat, getLogicalDevice(device), device)
    end
    return device
end