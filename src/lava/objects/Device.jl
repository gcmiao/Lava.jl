mutable struct Device
    mInstance::VkExt.VkInstance
    mFeatures::Vector{features.IFeatureT}
    mPhysicalDevice::vk.VkPhysicalDevice
    mPhyProperties::vk.VkPhysicalDeviceProperties
    mVkDevice::vk.VkDevice

    function Device(instance::VkExt.VkInstance,
               features::Vector{features.IFeatureT},
               gpuSelectionStrategy::ISelectionStrategy,
               queues::Vector{QueueRequest})
        this = new()
        this.mInstance = instance
        this.mFeatures = features

        pickPhysicalDevice(this, gpuSelectionStrategy)
        createLogicalDevice(this, [this.mPhysicalDevice], queues)

        return this
    end
end

# TODO: Deconstruction
# Device::~Device() {
#     for (auto &&feat : mFeatures)
#         feat->beforeDeviceDestruction();
# }

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
    names::Vector{String}
    priorities::Vector{Float32}
    minPriority::Float32
    
    FamilyInfo() = new(typemax(UInt32), Vector{String}(), Vector{Float32}(), typemax(Float32))
end

function resolveQueueRequest(req::QueueRequest, families::Vector{vk.VkQueueFamilyProperties})
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

function queueRequests(this::features.IFeatureT, families::Vector{vk.VkQueueFamilyProperties})
    return []
end

function queueRequests(this::features.GlfwOutputT, families::Vector{vk.VkQueueFamilyProperties})
    result = Vector{QueueRequest}()
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

function createLogicalDevice(this::Device, physicalDevices::Vector{vk.VkPhysicalDevice}, queues::Vector{QueueRequest})
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

    # Group requested queues by family index
    # Combine info that have the same index
    familyInfoDict = Dict{UInt32, FamilyInfo}()
    for q in queues
        info = get!(familyInfoDict, q.index, FamilyInfo())
        info.index = q.index
        push!(info.names, q.name)
        push!(info.priorities, q.priority)
        info.minPriority = min(info.minPriority, q.priority)
    end

    queueCreateInfos = Vector{vk.VkDeviceQueueCreateInfo}()
    for info in values(familyInfoDict)
        queueCreateInfo = vk.VkDeviceQueueCreateInfo(
            vk.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO, #sType::VkStructureType
            C_NULL, #pNext::Ptr{Cvoid}
            0, #flags::VkDeviceQueueCreateFlags
            info.index, #queueFamilyIndex::UInt32
            # queueCount should be less than or equal to available queue count
            # for this pCreateInfo->pQueueCreateInfos[0].queueFamilyIndex} (=0)
            # obtained previously from vkGetPhysicalDeviceQueueFamilyProperties
            1, #length(info.priorities), #queueCount::UInt32
            Base.unsafe_convert(Ptr{Float32}, Ref(info.minPriority)) #pQueuePriorities::Ptr{Cfloat}
        )
        push!(queueCreateInfos, queueCreateInfo)
    end

    extNames = Vector{String}()
    for feat in this.mFeatures
        add = features.deviceExtensions(feat)
        append!(extNames, add)
    end

    deviceFatures = VkExt.VkPhysicalDeviceFeatures()
    VkExt.setSamplerAnisotropy(deviceFatures, VkExt.VK_TRUE)
    for feat in this.mFeatures
        features.addPhysicalDeviceFeatures(feat, deviceFatures)
    end

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
    #     mVkDevice = mPhysicalDevice.createDeviceUnique(info)
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
        enabledFeaturesRef = Ref(VkExt.build(deviceFatures))
        createInfo = vk.VkDeviceCreateInfo(
            vk.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO, #sType::VkStructureType
            pNext, #pNext::Ptr{Cvoid}
            0, #flags::VkDeviceCreateFlags
            length(queueCreateInfos), #queueCreateInfoCount::UInt32
            pointer(queueCreateInfos), #pQueueCreateInfos::Ptr{VkDeviceQueueCreateInfo}
            0, #enabledLayerCount::UInt32, VilidationLayers is disabled
            C_NULL, #ppEnabledLayerNames::Ptr{Cstring}
            length(extNames), #enabledExtensionCount::UInt32
            StringHelper.strings2pp(extNames), #ppEnabledExtensionNames::Ptr{Cstring}
            Base.unsafe_convert(Ptr{vk.VkPhysicalDeviceFeatures}, enabledFeaturesRef)
        )

        GC.@preserve enabledFeaturesRef begin
            this.mVkDevice = VkExt.createDevice(this.mPhysicalDevice, Ref(createInfo))
        end
    #}
    
    #TODO

    # for (auto const &pair : familyInfos) {
    #     mPools[pair.second.index] = mVkDevice->createCommandPoolUnique(
    #         {vk::CommandPoolCreateFlagBits::eResetCommandBuffer |
    #              vk::CommandPoolCreateFlagBits::eTransient,
    #          pair.second.index})

    #     auto pool = mPools[pair.second.index].get()
    #     for (uint32_t i = 0 i < pair.second.names.size() i++) {
    #         auto const &name = pair.second.names[i]
    #         auto const &family = pair.second.index
    #         auto queue = mVkDevice->getQueue(family, i)

    #         mQueues.emplace(name, Queue(family, queue, pool, this))
    #     }
    # }
end

function createPipelineLayout(this::Device, type::Type, descriptorSets::Vector{DescriptorSetLayout} = [])::PipelineLayout   
    range = vk.VkPushConstantRange(
        vk.VK_SHADER_STAGE_ALL, #stageFlags::VkShaderStageFlags
        0, #offset::UInt32
        sizeof_obj(type()) #size::UInt32
    )
    return createPipelineLayout(this, [range], descriptorSets);
end

function createPipelineLayout(this::Device, constantRanges::Vector{vk.VkPushConstantRange} = [],
                              descriptorSets::Vector{DescriptorSetLayout} = [])::PipelineLayout
    return PipelineLayout(this.mVkDevice, descriptorSets, constantRanges)
end

function createDescriptorSetLayout(this::Device, info::DescriptorSetLayoutCreateInfo, poolSize::UInt32 = UInt32(4))
    return DescriptorSetLayout(this.mVkDevice, info, poolSize)
end

function createDescriptorPool(vkDevice::vk.VkDevice, info::DescriptorPoolCreateInfo)::DescriptorPool
    return DescriptorPool(vkDevice, info)
end

function createRenderPass(this::Device, info::RenderPassCreateInfo)::RenderPass
    return RenderPass(this.mVkDevice, info)
end

function createShaderFromFile(this::Device, filePath::String)::ShaderModule
    file = Base.read(filePath)
    size = filesize(filePath)
    stage = identifyShader(filePath)
    return ShaderModule(this.mVkDevice, pointer(file), size, stage)
end