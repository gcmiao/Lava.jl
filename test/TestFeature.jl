using Lava: IFeature
mutable struct TestFeature <: IFeature
    mOnInstanceCreatedCalled
    mBeforeInstanceDestruction

    mOnLogicalDeviceCreated
    mOnPhysicalDeviceSelected
    mBeforeDeviceDestructionCalled

    function TestFeature()
        this = new()
        this.mOnInstanceCreatedCalled = false
        this.mBeforeInstanceDestruction = false

        this.mOnLogicalDeviceCreated = false
        this.mOnPhysicalDeviceSelected = false
        this.mBeforeDeviceDestructionCalled = false
        return this
    end
end

@class TestFeature

function create(::Type{TestFeature})
    return TestFeature()
end

function lava.:onInstanceCreated(this::TestFeature, vkInstance::vk.VkInstance)
    this.mOnInstanceCreatedCalled = true
    this.mBeforeInstanceDestruction = false
end

function lava.:beforeInstanceDestruction(this::TestFeature)
    this.mBeforeInstanceDestruction = true
    this.mOnInstanceCreatedCalled = false
end

function lava.:onLogicalDeviceCreated(this::TestFeature, device)
    this.mOnLogicalDeviceCreated = true
    this.mBeforeDeviceDestructionCalled = false
end

function lava.:onPhysicalDeviceSelected(this::TestFeature, phy::vk.VkPhysicalDevice)
    this.mOnPhysicalDeviceSelected = true
    this.mBeforeDeviceDestructionCalled = false
end

function lava.:beforeDeviceDestruction(this::TestFeature)
    this.mBeforeDeviceDestructionCalled = true
    this.mOnPhysicalDeviceSelected = false
    this.mOnLogicalDeviceCreated = false
end
