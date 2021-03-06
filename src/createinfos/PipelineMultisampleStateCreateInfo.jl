struct PipelineMultisampleStateCreateInfo
    mHandleRef::Ref{vk.VkPipelineMultisampleStateCreateInfo}
    mPreserve::Vector{Any}

    function PipelineMultisampleStateCreateInfo(;
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineMultisampleStateCreateFlags = vk.VkFlags(0),
        rasterizationSamples::vk.VkSampleCountFlagBits = 0,
        sampleShadingEnable::vk.VkBool32 = VkExt.VK_FALSE,
        minSampleShading::Cfloat = 0,
        sampleMask = nothing, #::vk.VkSampleMask
        alphaToCoverageEnable::vk.VkBool32 = VkExt.VK_FALSE,
        alphaToOneEnable::vk.VkBool32 = VkExt.VK_FALSE
    )
        this = new(Ref(vk.VkPipelineMultisampleStateCreateInfo(
            vk.VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO, #sType::VkStructureType
            pNext, #::Ptr{Cvoid}
            flags, #::VkPipelineMultisampleStateCreateFlags
            rasterizationSamples, #::VkSampleCountFlagBits
            sampleShadingEnable, #::VkBool32
            minSampleShading, #::Cfloat
            ref_to_pointer(vk.VkSampleMask, sampleMask), #Ptr{VkSampleMask}
            alphaToCoverageEnable, #::VkBool32
            alphaToOneEnable #::VkBool32
        )), [sampleMask])
    end
end

function handleRef(this::PipelineMultisampleStateCreateInfo)::Ref{vk.VkPipelineMultisampleStateCreateInfo}
    this.mHandleRef
end