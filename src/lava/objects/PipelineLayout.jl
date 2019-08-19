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
        println("pipeline layout:", this.mHandleRef)
        return this
    end
end

# TODO: Deconstruction
# PipelineLayout::~PipelineLayout()
# {
#     mDevice->handle().destroyPipelineLayout(mHandle);
# }

function handleRef(this::PipelineLayout)::Ref{vk.VkPipelineLayout}
    return this.mHandleRef
end