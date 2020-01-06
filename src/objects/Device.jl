export Device
export nameQueue, getLogicalDevice, getPhysicalDevice, getInstance,
        namedQueue, family, graphicsQueue,
        attachment2D, handleRef, createView

mutable struct Device
    mVkInstance::vk.VkInstance
    mPhysicalDevice::vk.VkPhysicalDevice
    mVkDevice::vk.VkDevice

    mFeatures::Vector{IFeature}
    mQueues::Dict{String, Queue}
    mPools::Dict{UInt32, vk.VkCommandPool}

    mPhyProperties::vk.VkPhysicalDeviceProperties
    mSuballocator::Suballocator


    function Device(vkInstance::vk.VkInstance,
               features::Vector{IFeature},
               gpuSelectionStrategy::ISelectionStrategy,
               queues::Vector{QueueRequest})
        this = new()
        this.mVkInstance = vkInstance
        this.mFeatures = features
        this.mQueues = Dict{String, Queue}()
        this.mPools = Dict{UInt32, vk.VkCommandPool}()

        pickPhysicalDevice(this, gpuSelectionStrategy)
        createLogicalDevice(this, [this.mPhysicalDevice], queues)

        this.mSuballocator = Suballocator(this, this.mPhyProperties.limits.bufferImageGranularity)
        return this
    end
end

@class Device

function getLogicalDevice(this::Device)::vk.VkDevice
    return this.mVkDevice
end

function getPhysicalDevice(this::Device)::vk.VkPhysicalDevice
    return this.mPhysicalDevice
end

function getInstance(this::Device)::vk.VkInstance
    return this.mVkInstance
end

function destroy(this::Device)
    for feat in this.mFeatures
        beforeDeviceDestruction(feat)
    end
    for pool in this.mPools
        vk.vkDestroyCommandPool(this.mVkDevice, pool.second, C_NULL)
    end
    empty!(this.mPools)
end

function pickPhysicalDevice(this::Device, gpuSelectionStrategy::ISelectionStrategy)
    devices = VkExt.enumeratePhysicalDevices(this.mVkInstance)
    isGoodDevice = function(device::vk.VkPhysicalDevice)
        for feat in this.mFeatures
            if !supportsDevice(feat, device)
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
        onPhysicalDeviceSelected(feat, this.mPhysicalDevice)
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
            bitcount = count_ones(family.queueFlags)
            if (bitcount < bestBitcount)
                req.index = i
                bestBitcount = bitcount
            end
        end
    end
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
            pointer([info.minPriority]) #pQueuePriorities::Ptr{Cfloat}
        )
        push!(queueCreateInfos, queueCreateInfo)
    end

    extNames = Vector{String}()
    for feat in this.mFeatures
        add = deviceExtensions(feat)
        append!(extNames, add)
    end

    deviceFatures = VkExt.VkPhysicalDeviceFeatures()
    VkExt.setSamplerAnisotropy(deviceFatures, VkExt.VK_TRUE)
    for feat in this.mFeatures
        addPhysicalDeviceFeatures(feat, deviceFatures)
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
            strings2pp(extNames), #ppEnabledExtensionNames::Ptr{Cstring}
            Base.unsafe_convert(Ptr{vk.VkPhysicalDeviceFeatures}, enabledFeaturesRef)
        )

        GC.@preserve enabledFeaturesRef createInfo begin
            this.mVkDevice = VkExt.createDevice(this.mPhysicalDevice, Ref(createInfo))
        end
    #}
    
    for pair in familyInfoDict
        info = pair.second
        pool = VkExt.createCommandPool(this.mVkDevice, vk.VkCommandPoolCreateInfo(
            vk.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO, #sType::VkStructureType
            C_NULL, #pNext::Ptr{Cvoid}
            vk.VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT |
            vk.VK_COMMAND_POOL_CREATE_TRANSIENT_BIT, #flags::VkCommandPoolCreateFlags
            info.index #queueFamilyIndex::UInt32
        ))
        this.mPools[info.index] = pool
        for i::UInt32 = 1 : length(info.names)
            name = info.names[i]
            family = info.index
            queue = Ref{vk.VkQueue}()
            vk.vkGetDeviceQueue(this.mVkDevice, family, 0, queue)
            this.mQueues[name] = Queue(family, queue[], pool, this.mVkDevice)
        end
    end
end

function createPipelineLayout(this::Device, type::Type, descriptorSets::Vector{DescriptorSetLayout} = Vector{DescriptorSetLayout}())::PipelineLayout
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

function namedQueue(this::Device, name::String)::Queue
    @assert haskey(this.mQueues, name) "No Queue with this name:" * name * " exists!"
    return this.mQueues[name]
end

function graphicsQueue(this::Device)::Queue
    return namedQueue(this, "graphics")
end

function transferQueue(this::Device)::Queue
    if haskey(this.mQueues, "transfer")
        return this.mQueues["transfer"]
    else
        return graphicsQueue(this)
    end
end

function getSuballocator(this::Device)::Suballocator
    return this.mSuballocator
end
