struct PipelineViewportStateCreateInfo
    mHandleRef::Ref{vk.VkPipelineViewportStateCreateInfo}

    function PipelineViewportStateCreateInfo(
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineViewportStateCreateFlags = 0,
        mViewports::Vector{vk.VkViewport} = Vector{vk.VkViewport}(),
        mScissors::Vector{vk.VkRect2D} = Vector{vk.VkRect2D}()
    )

        this = new(Ref(vk.VkPipelineViewportStateCreateInfo(
            vk.VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO, #sType::VkStructureType
            pNext, #::Ptr{Cvoid}
            flags, #::VkPipelineViewportStateCreateFlags
            length(this.mViewports), #viewportCount::UInt32
            pointer(this.mViewports), #pViewports::Ptr{VkViewport}
            length(this.mScissors), #scissorCount::UInt32
            pointer(this.mScissors) #pScissors::Ptr{VkRect2D}
        )))
    end
end

function handleRef(this::PipelineViewportStateCreateInfo)::vk.VkPipelineViewportStateCreateInfo
    this.mHandleRef
end
