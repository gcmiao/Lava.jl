struct PipelineTessellationStateCreateInfo
    mHandleRef::Ref{vk.VkPipelineTessellationStateCreateInfo}

    function PipelineTessellationStateCreateInfo(;
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineTessellationStateCreateFlags = vk.VkFlags(0),
        patchControlPoints::UInt32 = UInt32(0)
    )

        this = new(Ref(vk.VkPipelineTessellationStateCreateInfo(
            vk.VK_STRUCTURE_TYPE_PIPELINE_TESSELLATION_STATE_CREATE_INFO, #sType::VkStructureType
            pNext, #::Ptr{Cvoid}
            flags, #::VkPipelineTessellationStateCreateFlags
            patchControlPoints #::UInt32
        )))
    end
end

function handleRef(this::PipelineTessellationStateCreateInfo)::Ref{vk.VkPipelineTessellationStateCreateInfo}
    this.mHandleRef
end