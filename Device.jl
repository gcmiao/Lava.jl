using features
using VulkanCore
using VkExt
using lava: ISelectionStrategy, QueueRequest

mutable struct Device
    mInstance::VkExt.VkInstance
    mFeatures::Array{features.IFeatureT, 1}
    mPhysicalDevice::vk.VkPhysicalDevice
    mPhyProperties::vk.VkPhysicalDeviceProperties
    mDevice::vk.VkDevice

    function Device(instance::VkExt.VkInstance,
               features::Array{features.IFeatureT, 1},
               gpuSelectionStrategy::ISelectionStrategy,
               queues::Array{QueueRequest, 1})
        this = new()
        this.mInstance = instance
        this.mFeatures = features

        pickPhysicalDevice(this, gpuSelectionStrategy)
        createLogicalDevice(this, [this.mPhysicalDevice], queues)
    end
end

function pickPhysicalDevice(this::Device, gpuSelectionStrategy::ISelectionStrategy)
    devices = VkExt.enumeratePhysicalDevices(this.mInstance)
    isGoodDevice = function(device::vk.VkPhysicalDevice)
        for feat in this.mFeatures
            if !features.supportsDevice(feat, device)
                return false
            end
        end
        return true
    end

    deviceCount::UInt32 = 0
    for device in devices
        if isGoodDevice(device)
            deviceCount += 1
            devices[deviceCount] = device
        end
    end
    resize!(devices, deviceCount)
    this.mPhysicalDevice = selectFrom(gpuSelectionStrategy, devices)

    for feat in this.mFeatures
        features.onPhysicalDeviceSelected(feat, this.mPhysicalDevice)
    end

    this.mPhyProperties = VkExt.getProperties(this.mPhysicalDevice)
end

mutable struct FamilyInfo
    index::UInt32
    names::Array{String, 1}
    priorities::Array{Float32, 1}
    
    FamilyInfo() = new(typemax(UInt32), Array{String, 1}(), Array{Float32, 1}())
end

function resolveQueueRequest(req::QueueRequest, families::Array{vk.VkQueueFamilyProperties, 1})
    if (req.index != typemax(UInt32))
        return
    end

    bestBitcount = typemax(UInt32)
    for i = 0 : length(families) - 1 #queueFamilyIndex should start from 0
        family = families[i + 1]
        if (family.queueFlags == req.flags)
            req.index = i
            return
        end

        if (family.queueFlags & req.flags > 0)
            bitcount = family.queueFlags #TODO bitcount = bitsSet(uint32_t(family.queueFlags))
            if (bitcount < bestBitcount)
                req.index = i
                bestBitcount = bitcount
            end
        end
    end
end

function queueRequests(this::features.GlfwOutputT, families::Array{vk.VkQueueFamilyProperties, 1})
    result = Array{QueueRequest, 1}()
    for i::UInt32 = 0 : length(families) - 1 #queueFamilyIndex should start from 0
        if VkExt.getSurfaceSupportKHR(this.mPhysicalDevice, i, this.mTempSurface) == vk.VK_TRUE
            this.mPresentIndex = i
            push!(result, createByFamily(QueueRequest, "present", i, 1.0f0))
            break
        end
    end
    if length(result) == 0
        error("Device can't present to this surface.")
    end

    return result
end

function createLogicalDevice(this::Device, physicalDevices::Array{vk.VkPhysicalDevice, 1}, queues::Array{QueueRequest, 1})
    avaliableExts = VkExt.enumerateDeviceExtensionProperties(this.mPhysicalDevice)

    # Throw in the queues requested by Features
    families = VkExt.getQueueFamilyProperties(this.mPhysicalDevice)
    for feat in this.mFeatures
        fams = queueRequests(feat, families)
        append!(queues, fams)
    end

    for q in queues
        resolveQueueRequest(q, families)
    end
    println("1. queues:", queues)
    println("2. families: ", families)
    # Group requested queues by family index
    # Combine info that have the same index
    familyInfoDict = Dict{UInt32, FamilyInfo}()
    for q in queues
        info = get!(familyInfoDict, q.index, FamilyInfo())
        info.index = q.index
        push!(info.names, q.name)
        push!(info.priorities, q.priority)
    end
    println("3. family dict:", familyInfoDict)

    queueCreateInfos = Array{vk.VkDeviceQueueCreateInfo, 1}()
    for info in values(familyInfoDict)
        queueCreateInfo = vk.VkDeviceQueueCreateInfo(
            vk.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO, #sType::VkStructureType
            C_NULL, #pNext::Ptr{Cvoid}
            0, #flags::VkDeviceQueueCreateFlags
            info.index, #queueFamilyIndex::UInt32
            length(info.priorities), #queueCount::UInt32
            pointer(info.priorities) #pQueuePriorities::Ptr{Cfloat}
        )
        push!(queueCreateInfos, queueCreateInfo)
    end

    println("4. queue create infos:", queueCreateInfos)

    extNames = Array{String, 1}()
    for feat in this.mFeatures
        add = features.deviceExtensions(feat)
        append!(extNames, add)
    end
    println("5. extensions:", extNames)

    deviceFeatures = Ref{vk.VkPhysicalDeviceFeatures}()
    vk.vkGetPhysicalDeviceFeatures(this.mPhysicalDevice, deviceFeatures)
    println("support sampler anisotropy:", deviceFeatures[].samplerAnisotropy)

    devFatures = VkExt.VkPhysicalDeviceFeatures()
    VkExt.setSamplerAnisotropy(devFatures, VkExt.VkTrue)
    for feat in this.mFeatures
        features.addPhysicalDeviceFeatures(feat, devFatures)
    end

    println("6. device features:", devFatures)
    # TODO
    # features::IFeature::NextPtr features2 = nullptr
    # for (auto &&feat : mFeatures)
    #     feat->addPhysicalDeviceFeatures2(features2)
    #
    # if (features2) {
    #     // Some extension needs features from the *Features2KHR extension.
    #     // The specific features go in the next-field of the extension struct.

    #     info.setPEnabledFeatures(nullptr)

    #     vk::PhysicalDeviceFeatures2KHR wrapper{features}
    #     wrapper.pNext = features2
    #     info.pNext = &wrapper
    #     mDevice = mPhysicalDevice.createDeviceUnique(info)
    # } else {
        # Only level 1 extensions are used, no weird magic here.

        pNext = C_NULL
        phyDeviceCount = length(physicalDevices)
        if (phyDeviceCount > 1)
            groupInfo = vk.VkDeviceGroupDeviceCreateInfo(
                vk.VK_STRUCTURE_TYPE_DEVICE_GROUP_DEVICE_CREATE_INFO, #sType::VkStructureType
                C_NULL, #pNext::Ptr{Cvoid}
                phyDeviceCount, #physicalDeviceCount::UInt32
                pointer(physicalDevices) #pPhysicalDevices::Ptr{VkPhysicalDevice}
                )
            pNext = pointer_from_objref(Ref(groupInfo))
        end
        
        enabledFeatures = VkExt.build(devFatures)
        enabledFeatures = deviceFeatures
        createInfo = vk.VkDeviceCreateInfo(
            vk.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO, #sType::VkStructureType
            pNext, #pNext::Ptr{Cvoid}
            0, #flags::VkDeviceCreateFlags
            length(queueCreateInfos), #queueCreateInfoCount::UInt32
            pointer(queueCreateInfos), #pQueueCreateInfos::Ptr{VkDeviceQueueCreateInfo}
            0, #enabledLayerCount::UInt32, VilidationLayers is disabled
            C_NULL, #ppEnabledLayerNames::Ptr{Cstring}
            length(extNames), #enabledExtensionCount::UInt32
            strings2pp(extNames), #ppEnabledExtensionNames::Ptr{Cstring}
            pointer_from_objref(Ref(enabledFeatures)) #pEnabledFeatures::Ptr{VkPhysicalDeviceFeatures}
        )

        println("7. physical device:", this.mPhysicalDevice)
        println("8. create info:", createInfo)
        this.mDevice = VkExt.createDevice(this.mPhysicalDevice, Ref(createInfo))
        println(this.mDevice)
    #}
    
    #TODO

    # for (auto const &pair : familyInfos) {
    #     mPools[pair.second.index] = mDevice->createCommandPoolUnique(
    #         {vk::CommandPoolCreateFlagBits::eResetCommandBuffer |
    #              vk::CommandPoolCreateFlagBits::eTransient,
    #          pair.second.index})

    #     auto pool = mPools[pair.second.index].get()
    #     for (uint32_t i = 0 i < pair.second.names.size() i++) {
    #         auto const &name = pair.second.names[i]
    #         auto const &family = pair.second.index
    #         auto queue = mDevice->getQueue(family, i)

    #         mQueues.emplace(name, Queue(family, queue, pool, this))
    #     }
    # }
end