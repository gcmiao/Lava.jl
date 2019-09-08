struct PipelineMultisampleStateCreateInfo
    mHandleRef::Ref{vk.VkPipelineMultisampleStateCreateInfo}
    mReserve::Vector{Any}

    function PipelineMultisampleStateCreateInfo(reserve::Vector{Any} = [];
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineMultisampleStateCreateFlags = vk.VkFlags(0),
        rasterizationSamples::vk.VkSampleCountFlagBits = 0,
        sampleShadingEnable::vk.VkBool32 = vk.VkBool32(vk.VK_FALSE),
        minSampleShading::Cfloat = 0,
        pSampleMask::Ptr{vk.VkSampleMask} = Ptr{vk.VkSampleMask}(C_NULL),
        alphaToCoverageEnable::vk.VkBool32 = vk.VkBool32(vk.VK_FALSE),
        alphaToOneEnable::vk.VkBool32 = vk.VkBool32(vk.VK_FALSE)
    )
    
        this = new(Ref(vk.VkPipelineMultisampleStateCreateInfo(
            vk.VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO, #sType::VkStructureType
            pNext, #::Ptr{Cvoid}
            flags, #::VkPipelineMultisampleStateCreateFlags
            rasterizationSamples, #::VkSampleCountFlagBits
            sampleShadingEnable, #::VkBool32
            minSampleShading, #::Cfloat
            pSampleMask, #::Ptr{VkSampleMask}
            alphaToCoverageEnable, #::VkBool32
            alphaToOneEnable #::VkBool32
        )), reserve)
    end
end

function handleRef(this::PipelineMultisampleStateCreateInfo)::Ref{vk.VkPipelineMultisampleStateCreateInfo}
    this.mHandleRef
end