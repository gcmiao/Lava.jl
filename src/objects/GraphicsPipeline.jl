mutable struct GraphicsPipeline
    mVkDevice::vk.VkDevice
    mHandleRef::Ref{vk.VkPipeline}
    mCreateInfo::GraphicsPipelineCreateInfo

    function GraphicsPipeline(createInfo::GraphicsPipelineCreateInfo)
        createInfoRef = handleRef(createInfo)
        @assert createInfoRef[].layout != vk.VK_NULL_HANDLE ("GraphicsPipeline requires a PipelineLayout " *
                                     "to be set in its CreateInfo.")
        this = new()
        this.mHandleRef = Ref{vk.VkPipeline}()
        this.mCreateInfo = createInfo
        this.mVkDevice = getLogicalDevice(createInfo.mLayout)
        if (vk.vkCreateGraphicsPipelines(this.mVkDevice, C_NULL, 1, createInfoRef, C_NULL, this.mHandleRef) != vk.VK_SUCCESS)
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

function getLayout(this::GraphicsPipeline)::PipelineLayout
    return this.mCreateInfo.mLayout
end