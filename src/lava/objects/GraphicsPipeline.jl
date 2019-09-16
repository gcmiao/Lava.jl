mutable struct GraphicsPipeline
    mVkDevice::vk.VkDevice
    mHandleRef::Ref{vk.VkPipeline}

    function GraphicsPipeline(vkDevice::vk.VkDevice, createInfoRef::Ref{vk.VkGraphicsPipelineCreateInfo})
        @assert createInfoRef[].layout != vk.VK_NULL_HANDLE ("GraphicsPipeline requires a PipelineLayout " *
                                     "to be set in its CreateInfo.")
        this = new()
        this.mVkDevice = vkDevice
        this.mHandleRef = Ref{vk.VkPipeline}()
        if (vk.vkCreateGraphicsPipelines(vkDevice, vk.VK_NULL_HANDLE, 1, createInfoRef, C_NULL, this.mHandleRef) != vk.VK_SUCCESS)
            error("Failed to create graphics pipeline!")
        end
        return this
    end
end

function handleRef(this::GraphicsPipeline)::Ref{vk.VkPipeline}
    this.mHandleRef
end

# GraphicsPipeline::~GraphicsPipeline() {
#     mDevice->handle().destroyPipeline(mHandle);
# }