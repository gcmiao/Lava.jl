export ISelectionStrategy, NthOfTypeStrategy
export IGroupAssemblyStrategy, NthGroupStrategy

abstract type ISelectionStrategy end

function selectFrom(this::ISelectionStrategy, phys::Vector{vk.VkPhysicalDevice})::vk.VkPhysicalDevice
    return vk.VK_NULL_HANDLE
end

mutable struct NthOfTypeStrategy <: ISelectionStrategy
    mType::vk.VkPhysicalDeviceType
    mN::UInt32

    NthOfTypeStrategy(type::vk.VkPhysicalDeviceType) = new(type, 0)
end
@class NthOfTypeStrategy

function selectFrom(this::NthOfTypeStrategy, phys::Vector{vk.VkPhysicalDevice})::vk.VkPhysicalDevice
    counter::UInt32 = 0
    for dev in phys
        props = VkExt.vkGetPhysicalDeviceProperties(dev)
        if (props.deviceType == this.mType)
            if (counter == this.mN)
                return dev;
            end
            counter += 1
        end
    end
    println("Failed to select physical device of ", this.mType, ".")
    return vk.VK_NULL_HANDLE
end

abstract type IGroupAssemblyStrategy end

function assembleFrom(this::IGroupAssemblyStrategy, groups::Vector{vk.VkPhysicalDeviceGroupProperties})::Vector{vk.VkPhysicalDevice}
    return []
end

mutable struct NthGroupStrategy <: IGroupAssemblyStrategy
    mN::UInt32

    # n start from 0
    NthGroupStrategy(n::Integer) = new(n)
end
@class NthGroupStrategy

function assembleFrom(this::NthGroupStrategy, groups::Vector{vk.VkPhysicalDeviceGroupProperties})::Vector{vk.VkPhysicalDevice}
    @assert(length(groups) > this.mN)

    group = groups[this.mN + 1]
    ret = []
    for i = 1 : group.physicalDeviceCount
        push!(ret, group.physicalDevices[i])
    end
    return ret
end
