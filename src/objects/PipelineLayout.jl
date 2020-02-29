mutable struct PipelineLayout
    mVkDevice::vk.VkDevice
    mDescriptors::Vector{DescriptorSetLayout}
    mDescriptorHandles::Vector{vk.VkDescriptorSetLayout}

    mPushConstants::Vector{vk.VkPushConstantRange}
    mCreateInfo::PipelineLayoutCreateInfo

    mHandleRef::Ref{vk.VkPipelineLayout}

    function PipelineLayout(device::vk.VkDevice,
                       descriptors::Vector{DescriptorSetLayout},
                     pushConstants::Vector{vk.VkPushConstantRange})
        this = new()
        this.mVkDevice = device
        this.mDescriptors = descriptors
        this.mPushConstants = pushConstants
        this.mCreateInfo = PipelineLayoutCreateInfo()
        this.mDescriptorHandles = Vector{vk.VkDescriptorSetLayout}()
        
        for d in descriptors
            handle = handleRef(d)[]
            push!(this.mDescriptorHandles, handle)
            addSetLayout(this.mCreateInfo, handle)
        end
        for p in pushConstants
            addPushConstantRange(this.mCreateInfo, p)
        end
        
        this.mHandleRef = Ref{vk.VkPipelineLayout}()
        if vk.vkCreatePipelineLayout(this.mVkDevice, handleRef(this.mCreateInfo), C_NULL, this.mHandleRef) != vk.VK_SUCCESS
            error("Failed to create pipeline layout!")
        end
        return this
    end
end

@class PipelineLayout

function destroy(this::PipelineLayout)
    vk.vkDestroyPipelineLayout(this.mVkDevice, this.mHandleRef[], C_NULL)
end

function handleRef(this::PipelineLayout)::Ref{vk.VkPipelineLayout}
    return this.mHandleRef
end

function createPipelineLayout(this::Device, type::Type, descriptorSets::Vector{DescriptorSetLayout} = Vector{DescriptorSetLayout}())::PipelineLayout
    range = vk.VkPushConstantRange(
        vk.VK_SHADER_STAGE_ALL, #stageFlags::VkShaderStageFlags
        0, #offset::UInt32
        sizeof_obj(type()) #size::UInt32
    )
    return createPipelineLayout(this, [range], descriptorSets);
end

function createPipelineLayout(this::Device, constantRanges::Vector{vk.VkPushConstantRange} = Vector{vk.VkPushConstantRange}(),
                                            descriptorSets::Vector{DescriptorSetLayout} = Vector{DescriptorSetLayout}())::PipelineLayout
    return PipelineLayout(this.mVkDevice, descriptorSets, constantRanges)
end

function getLogicalDevice(this::PipelineLayout)::vk.VkDevice
    return this.mVkDevice
end

function getCreateInfo(this::PipelineLayout)::PipelineLayoutCreateInfo
    return this.mCreateInfo
end
