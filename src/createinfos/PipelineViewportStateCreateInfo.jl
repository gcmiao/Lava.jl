struct PipelineViewportStateCreateInfo
    mHandleRef::Ref{vk.VkPipelineViewportStateCreateInfo}
    mRefserve::Vector{Any}

    function PipelineViewportStateCreateInfo(;
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineViewportStateCreateFlags = vk.VkFlags(0),
        viewports::Vector{vk.VkViewport} = Vector{vk.VkViewport}(),
        scissors::Vector{vk.VkRect2D} = Vector{vk.VkRect2D}()
    )
        this = new(Ref(vk.VkPipelineViewportStateCreateInfo(
            vk.VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO, #sType::VkStructureType
            pNext, #::Ptr{Cvoid}
            flags, #::VkPipelineViewportStateCreateFlags
            length(viewports), #viewportCount::UInt32
            pointer(viewports), #pViewports::Ptr{VkViewport}
            length(scissors), #scissorCount::UInt32
            pointer(scissors) #pScissors::Ptr{VkRect2D}
        )), [viewports, scissors])
    end
end

function handleRef(this::PipelineViewportStateCreateInfo)::Ref{vk.VkPipelineViewportStateCreateInfo}
    this.mHandleRef
end
