mutable struct PipelineLayout
    mDevice::Device,
    mDescriptors::Array{DescriptorSetLayout, 1},
    mDescriptorHandles::Array{vk.VkDescriptorSetLayout, 1},

    mPushConstants::Array{vk.VkPushConstantRange, 1},
    mCreateInfo::PipelineLayoutCreateInfo
    mHandleRef::Ref{vk.VkPipelineLayout}

    function PipelineLayout(device::Device,
                       descriptors::Array{DescriptorSetLayout, 1},
                     pushConstants::Array{PushConstantRange, 1})
        this = new()
        this.mDevice = device
        this.mDescriptors = descriptors
        this.mPushConstants = pushConstants

        std::transform(begin(mDescriptors), end(mDescriptors),
                       back_inserter(mDescriptorHandles),
                       [](SharedDescriptorSetLayout const &d) { return d->handle(); });
        
        for d in descriptors
            addSetLayout(mCreateInfo, handle(d))
        end
        for p in pushConstants
            addPushConstantRange(mCreateInfo, p)
        end
        
        this.mHandleRef = Ref{vk.VkPipelineLayout}()
        if (vk.vkCreatePipelineLayout(this.mDevice, handleRef(mCreateInfo), C_NULL, mHandleRef) != vk.VK_SUCCESS)
            error("Failed to create pipeline layout!")
        end
    end
end

# TODO: Deconstruction
# PipelineLayout::~PipelineLayout()
# {
#     mDevice->handle().destroyPipelineLayout(mHandle);
# }

function handleRef(this::PipelineLayout)::vk.VkPipelineLayout
    return mHandleRef[]
end