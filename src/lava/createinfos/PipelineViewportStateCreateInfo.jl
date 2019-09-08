struct PipelineViewportStateCreateInfo
    mHandleRef::Ref{vk.VkPipelineViewportStateCreateInfo}

    function PipelineViewportStateCreateInfo(;
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineViewportStateCreateFlags = vk.VkFlags(0),
        viewports::Vector{vk.VkViewport} = Vector{vk.VkViewport}(),
        mScissors::Vector{vk.VkRect2D} = Vector{vk.VkRect2D}()
    )

        this = new(Ref(vk.VkPipelineViewportStateCreateInfo(
            vk.VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO, #sType::VkStructureType
            pNext, #::Ptr{Cvoid}
            flags, #::VkPipelineViewportStateCreateFlags
            length(viewports), #viewportCount::UInt32
            pointer(viewports), #pViewports::Ptr{VkViewport}
            length(mScissors), #scissorCount::UInt32
            pointer(mScissors) #pScissors::Ptr{VkRect2D}
        )))
    end
end

function handleRef(this::PipelineViewportStateCreateInfo)::Ref{vk.VkPipelineViewportStateCreateInfo}
    this.mHandleRef
end
