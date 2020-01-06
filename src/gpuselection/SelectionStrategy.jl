abstract type ISelectionStrategy end

function selectFrom(this::ISelectionStrategy, phys::Vector{vk.VkPhysicalDevice})::vk.VkPhysicalDevice
    return vk.VK_NULL_HANDLE
end

mutable struct NthOfTypeStrategy <: ISelectionStrategy
    mType::vk.VkPhysicalDeviceType
    mN::UInt32

    NthOfTypeStrategy(type::vk.VkPhysicalDeviceType) = new(type, 0)
end

function selectFrom(this::NthOfTypeStrategy, phys::Vector{vk.VkPhysicalDevice})::vk.VkPhysicalDevice
    counter::UInt32 = 0
    for dev in phys
        props = VkExt.getProperties(dev)
        if (props.deviceType == this.mType)
            if (counter == this.mN)
                return dev;
            end
            counter += 1
        end
    end
    println("Failed to select physical device.")
    return vk.VK_NULL_HANDLE
end

