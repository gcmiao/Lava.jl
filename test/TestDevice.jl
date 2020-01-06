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

    return true
end
