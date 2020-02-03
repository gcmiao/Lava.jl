struct PipelineColorBlendAttachmentState
    mHandle::vk.VkPipelineColorBlendAttachmentState

    function PipelineColorBlendAttachmentState(;
        blendEnable::vk.VkBool32 = VkExt.VK_FALSE,
        srcColorBlendFactor::vk.VkBlendFactor = vk.VK_BLEND_FACTOR_ZERO,
        dstColorBlendFactor::vk.VkBlendFactor = vk.VK_BLEND_FACTOR_ZERO,
        colorBlendOp::vk.VkBlendOp = vk.VK_BLEND_OP_ADD,
        srcAlphaBlendFactor::vk.VkBlendFactor = vk.VK_BLEND_FACTOR_ZERO,
        dstAlphaBlendFactor::vk.VkBlendFactor = vk.VK_BLEND_FACTOR_ZERO,
        alphaBlendOp::vk.VkBlendOp = vk.VK_BLEND_OP_ADD,
        colorWriteMask::vk.VkColorComponentFlags = 0
    )
        new(
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
        )
    end
end
@class PipelineColorBlendAttachmentState

struct PipelineColorBlendStateCreateInfo
    mHandleRef::Ref{vk.VkPipelineColorBlendStateCreateInfo}
    mPreserve::Vector{Any}

    function PipelineColorBlendStateCreateInfo(;
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineColorBlendStateCreateFlags = vk.VkFlags(0),
        logicOpEnable::vk.VkBool32 = VkExt.VK_FALSE,
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

function handle(this::PipelineColorBlendAttachmentState)::vk.VkPipelineColorBlendAttachmentState
    return this.mHandle
end

function handleRef(this::PipelineColorBlendStateCreateInfo)::Ref{vk.VkPipelineColorBlendStateCreateInfo}
    this.mHandleRef
end

function addNoBlend(outStates::Vector{vk.VkPipelineColorBlendAttachmentState})
    state = PipelineColorBlendAttachmentState(
                colorWriteMask = (vk.VK_COLOR_COMPONENT_R_BIT | vk.VK_COLOR_COMPONENT_G_BIT |
                vk.VK_COLOR_COMPONENT_B_BIT | vk.VK_COLOR_COMPONENT_A_BIT)
            ).handle()
    push!(outStates, state)
end

function addTransparencyBlend(outStates::Vector{vk.VkPipelineColorBlendAttachmentState})
    state = PipelineColorBlendAttachmentState(
                blendEnable = VkExt.VK_TRUE,
                colorWriteMask = (vk.VK_COLOR_COMPONENT_R_BIT | vk.VK_COLOR_COMPONENT_G_BIT |
                                  vk.VK_COLOR_COMPONENT_B_BIT | vk.VK_COLOR_COMPONENT_A_BIT),
                alphaBlendOp = vk.VK_BLEND_OP_ADD,
                srcAlphaBlendFactor = vk.VK_BLEND_FACTOR_ONE,
                dstAlphaBlendFactor = vk.VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
                colorBlendOp = vk.VK_BLEND_OP_ADD,
                srcColorBlendFactor = vk.VK_BLEND_FACTOR_SRC_ALPHA,
                dstColorBlendFactor = vk.VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA
            ).handle()
    push!(outStates, state)
end
