abstract type ISelectionStrategy end

function selectFrom(this::ISelectionStrategy, phys::Array{vk.VkPhysicalDevice})::vk.VkPhysicalDevice
    return vk.VK_NULL_HANDLE
end

mutable struct NthOfTypeStrategy <: ISelectionStrategy
    mType::vk.VkPhysicalDeviceType
    mN::UInt32

    NthOfTypeStrategy(type::vk.VkPhysicalDeviceType) = new(type, 1)
end

function selectFrom(this::NthOfTypeStrategy, phys::Array{vk.VkPhysicalDevice})::vk.VkPhysicalDevice
    counter::UInt32 = 0
    for dev in phys
        props = VkExt.getProperties(dev)
        if (props.deviceType == this.mType)
            counter += 1
            if (counter == this.mN)
                return dev;
            end
        end
    end
    println("Failed to select physical device.")
    return vk.VK_NULL_HANDLE
end