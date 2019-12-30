mutable struct Instance
    mFeatures::Vector{IFeature}
    mVkInstance::vk.VkInstance

    function Instance(inFeatures::Vector{IFeature})
        this = new()
        this.mFeatures = inFeatures

        # get required extension names
        availableExtensions, extCount = VkExt.enumerateInstanceExtensionProperties()
        avaliableExtNames = Vector{String}(undef, extCount)
        for i = 1 : extCount
            avaliableExtNames[i] = chars2String(availableExtensions[i].extensionName)
        end
        
        # get required layer names
        avaliableLayers, layerCount = VkExt.enumerateInstanceLayerProperties()
        avaliableLayerNames = Vector{String}(undef, layerCount)
        for i = 1 : layerCount
            avaliableLayerNames[i] = chars2String(avaliableLayers[i].layerName)
        end
    
        requiredExtNames = Vector{String}()
        requiredLayerNames = Vector{String}()
        for feat in this.mFeatures
            extNames = instanceExtensions(feat, avaliableExtNames)
            append!(requiredExtNames, extNames)
            layerNames = layers(feat, avaliableLayerNames)
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

        this.mVkInstance = VkExt.createInstance(info)

        for feat in this.mFeatures
            onInstanceCreated(feat, this.mVkInstance)
        end

        return this
    end
end

function destroy(this::Instance)
    for feat in this.mFeatures
        beforeInstanceDestruction(feat)
    end
    destroy(this.mFeatures)
end

function handle(this::Instance)::vk.VkInstance
    return this.mVkInstance
end

function create(::Type{Instance}, inFeatures::Vector{IFeature})::Instance
    return Instance(inFeatures)
end

function createDevice(this::Instance, queues::Vector{QueueRequest}, gpuSelectionStrategy::ISelectionStrategy)
    device = Device(this.mVkInstance, this.mFeatures, gpuSelectionStrategy, queues)
    for feat in this.mFeatures
        onLogicalDeviceCreated(feat, device)
    end
    return device
end
