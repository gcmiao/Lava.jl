function checkDevice(device)
    @test device.getPhysicalDevice() != vk.VK_NULL_HANDLE
    @test device.getLogicalDevice() != vk.VK_NULL_HANDLE

    feats = device.mFeatures
    for feat in feats
        if isa(feat, TestFeature)
            @test feat.mOnPhysicalDeviceSelected
            @test feat.mOnLogicalDeviceCreated
        end
    end
    return true
end

function checkDestroiedDevice(device)
    feats = device.mFeatures
    for feat in feats
        if isa(feat, TestFeature)
            @test feat.mBeforeDeviceDestructionCalled
        end
    end
    @test isempty(device.mPools)
    return true
end

function testSelectionStrategy(instance)
    devices = VkExt.enumeratePhysicalDevices(instance.mVkInstance)
    pd = lava.selectFrom(lava.NthOfTypeStrategy(vk.VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU), devices)
    pd = lava.selectFrom(lava.NthOfTypeStrategy(vk.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU), devices)

    phyDevices = ntuple(i -> Base.unsafe_convert(vk.VkPhysicalDevice, Ref(2 * i)), 32)
    gpps = [vk.VkPhysicalDeviceGroupProperties(
        vk.VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_GROUP_PROPERTIES, # sType::VkStructureType
        C_NULL, # pNext::Ptr{Cvoid}
        length(phyDevices), # physicalDeviceCount::UInt32
        phyDevices, # physicalDevices::NTuple{32, VkPhysicalDevice}
        VkExt.VK_FALSE # subsetAllocation::VkBool32
    )]
    pds = lava.assembleFrom(lava.NthGroupStrategy(0), gpps)
    @test length(pds) == length(phyDevices)
    @test pds[1] == phyDevices[1] && pds[2] == phyDevices[2] && pds[3] == phyDevices[3]
    return true
end

function testDevice(instance, queues, outDevice::Ref)
    @test testSelectionStrategy(instance)
    # create INTEGRATED_GPU
    device = instance.createDevice(queues,
                                   lava.NthOfTypeStrategy(vk.VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU))
    # create DISCRETE_GPU
    # device = instance.createDevice(queues,
    #                               lava.NthOfTypeStrategy(vk.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU))
    @test checkDevice(device)

    device.destroy()
    @test checkDestroiedDevice(device)
    outDevice[] = device
    return true
end

function testDevice(instance, queues, strategy::T) where T <: lava.IGroupAssemblyStrategy
    device = instance.createDevice(queues, strategy)
    @test checkDevice(device)

    device.destroy()
    @test checkDestroiedDevice(device)

    return true
end
