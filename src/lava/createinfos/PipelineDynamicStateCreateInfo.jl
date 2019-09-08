struct PipelineDynamicStateCreateInfo
    mHandleRef::Ref{vk.VkPipelineDynamicStateCreateInfo}

    function PipelineDynamicStateCreateInfo(;
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineDynamicStateCreateFlags = vk.VkFlags(0),
        states::Vector{vk.VkDynamicState} = Vector{vk.VkDynamicState}()
    )

        this = new(Ref(vk.VkPipelineDynamicStateCreateInfo(
            vk.VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO, #sType::VkStructureType
            pNext, #::Ptr{Cvoid}
            flags, #::VkPipelineDynamicStateCreateFlags
            length(states), #dynamicStateCount::UInt32
            pointer(states) #pDynamicStates::Ptr{VkDynamicState}
        )))
    end
end

function handleRef(this::PipelineDynamicStateCreateInfo)::Ref{vk.VkPipelineDynamicStateCreateInfo}
    this.mHandleRef
end