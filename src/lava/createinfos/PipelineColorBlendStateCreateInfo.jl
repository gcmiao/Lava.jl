mutable struct PipelineColorBlendStateCreateInfo
    mAttachments::Vector{vk.VkPipelineColorBlendAttachmentState}

    mHandleRef::vk.VkPipelineColorBlendStateCreateInfo

    function PipelineColorBlendStateCreateInfo()
        this = new()
        this.mAttachments = Vector{vk.VkPipelineColorBlendAttachmentState}()
        return this
    end
end

function add(this::PipelineColorBlendStateCreateInfo, state::vk.VkPipelineColorBlendAttachmentState)
    this.mAttachments.push_back(state);
end

function addNoBlend(this::PipelineColorBlendStateCreateInfo)
    add(this, vk.VkPipelineColorBlendAttachmentState(
                        vk.VK_FALSE, #blendEnable::VkBool32
                        vk.VK_BLEND_FACTOR_ZERO, #srcColorBlendFactor::VkBlendFactor
                        vk.VK_BLEND_FACTOR_ZERO, #dstColorBlendFactor::VkBlendFactor
                        vk.VK_BLEND_OP_ADD, #colorBlendOp::VkBlendOp
                        vk.VK_BLEND_FACTOR_ZERO, #srcAlphaBlendFactor::VkBlendFactor
                        vk.VK_BLEND_FACTOR_ZERO, #dstAlphaBlendFactor::VkBlendFactor
                        vk.VK_BLEND_OP_ADD, #alphaBlendOp::VkBlendOp
                        (vk.VK_COLOR_COMPONENT_R_BIT | vk.VK_COLOR_COMPONENT_G_BIT |
                         vk.VK_COLOR_COMPONENT_B_BIT | vk.VK_COLOR_COMPONENT_A_BIT) #colorWriteMask::VkColorComponentFlags
                    ))
end

function commit(this::PipelineColorBlendStateCreateInfo)
    this.mHandleRef = Ref(vk.VkPipelineColorBlendStateCreateInfo(
                                vk.VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO, #sType::VkStructureType
                                C_NULL, #pNext::Ptr{Cvoid}
                                0, #flags::VkPipelineColorBlendStateCreateFlags
                                vk.VK_FALSE, #logicOpEnable::VkBool32
                                vk.VK_LOGIC_OP_COPY, #logicOp::VkLogicOp
                                length(this.mAttachments), #attachmentCount::UInt32
                                pointer(this.mAttachments), #pAttachments::Ptr{VkPipelineColorBlendAttachmentState}
                                (0.0, 0.0, 0.0, 0.0) #blendConstants::NTuple{4, Cfloat}
                            ))
end

function handleRef(this::PipelineColorBlendStateCreateInfo)::Ref{vk.VkPipelineColorBlendStateCreateInfo}
    return this.mHandleRef
end
