mutable struct ComputePipeline
    mVkDevice::vk.VkDevice
    mCreateInfo::ComputePipelineCreateInfo
    mHandleRef::Ref{vk.VkPipeline}

    function ComputePipeline(createInfo::ComputePipelineCreateInfo)
        this = new()
        this.mCreateInfo = createInfo
        this.mVkDevice = getLogicalDevice(createInfo.mLayout)
        this.mHandleRef = Ref{vk.VkPipeline}()
        if (vk.vkCreateComputePipelines(this.mVkDevice, C_NULL, 1, createInfo.handleRef(), C_NULL, this.mHandleRef) != vk.VK_SUCCESS)
            error("Failed to create compute pipeline!")
        end
        return this
    end
end
@class ComputePipeline

function getLayout(this::ComputePipeline)::PipelineLayout
    return this.mCreateInfo.mLayout
end

function destroy(this::ComputePipeline)
    vk.vkDestroyPipeline(this.mVkDevice, this.mHandleRef[], C_NULL)
end
