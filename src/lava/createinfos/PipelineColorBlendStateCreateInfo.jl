function PipelineColorBlendAttachmentState(;
    blendEnable::vk.VkBool32 = vk.VkBool32(vk.VK_FALSE),
    srcColorBlendFactor::vk.VkBlendFactor = vk.VK_BLEND_FACTOR_ZERO,
    dstColorBlendFactor::vk.VkBlendFactor = vk.VK_BLEND_FACTOR_ZERO,
    colorBlendOp::vk.VkBlendOp = vk.VK_BLEND_OP_ADD,
    srcAlphaBlendFactor::vk.VkBlendFactor = vk.VK_BLEND_FACTOR_ZERO,
    dstAlphaBlendFactor::vk.VkBlendFactor = vk.VK_BLEND_FACTOR_ZERO,
    alphaBlendOp::vk.VkBlendOp = vk.VK_BLEND_OP_ADD,
    colorWriteMask::vk.VkColorComponentFlags = 0
)

    vk.VkPipelineColorBlendAttachmentState(
        blendEnable, #::VkBool32
        srcColorBlendFactor, #::VkBlendFactor
        dstColorBlendFactor, #::VkBlendFactor
        colorBlendOp, #::VkBlendOp
        srcAlphaBlendFactor, #::VkBlendFactor
        dstAlphaBlendFactor, #::VkBlendFactor
        alphaBlendOp, #::VkBlendOp
        colorWriteMask #::VkColorComponentFlags
    )
end

struct PipelineColorBlendStateCreateInfo
    mHandleRef::Ref{vk.VkPipelineColorBlendStateCreateInfo}
    mReserve::Vector{Any}

    function PipelineColorBlendStateCreateInfo(;
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineColorBlendStateCreateFlags = vk.VkFlags(0),
        logicOpEnable::vk.VkBool32 = vk.VkBool32(vk.VK_FALSE),
        logicOp::vk.VkLogicOp = vk.VK_LOGIC_OP_COPY,
        attachments::Vector{vk.VkPipelineColorBlendAttachmentState} = Vector{vk.VkPipelineColorBlendAttachmentState}(),
        blendConstants::NTuple{4, Cfloat} = (Cfloat(0), Cfloat(0), Cfloat(0), Cfloat(0))
    )

        this = new(Ref(vk.VkPipelineColorBlendStateCreateInfo(
            vk.VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO, #sType::VkStructureType
            pNext, #::Ptr{Cvoid}
            flags, #::VkPipelineColorBlendStateCreateFlags
            logicOpEnable, #::VkBool32
            logicOp, #::VkLogicOp
            length(attachments), #::UInt32
            pointer(attachments), #::Ptr{VkPipelineColorBlendAttachmentState}
            blendConstants #::NTuple{4, Cfloat}
        )), [attachments])
    end
end

function handleRef(this::PipelineColorBlendStateCreateInfo)::Ref{vk.VkPipelineColorBlendStateCreateInfo}
    this.mHandleRef
end
