struct GraphicsPipelineCreateInfo
    mHandleRef::Ref{vk.VkGraphicsPipelineCreateInfo}
    mReserve::Vector{Any}

    function GraphicsPipelineCreateInfo(reserve::Vector{Any} = [];
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineCreateFlags = vk.VkFlags(0),
        stages::Vector{vk.VkPipelineShaderStageCreateInfo} = Vector{vk.VkPipelineShaderStageCreateInfo}(),
        pVertexInputState::Ptr{vk.VkPipelineVertexInputStateCreateInfo} = C_NULL,
        pInputAssemblyState::Ptr{vk.VkPipelineInputAssemblyStateCreateInfo} = C_NULL,
        pTessellationState::Ptr{vk.VkPipelineTessellationStateCreateInfo} = C_NULL,
        pViewportState::Ptr{vk.VkPipelineViewportStateCreateInfo} = C_NULL,
        pRasterizationState::Ptr{vk.VkPipelineRasterizationStateCreateInfo} = C_NULL,
        pMultisampleState::Ptr{vk.VkPipelineMultisampleStateCreateInfo} = C_NULL,
        pDepthStencilState::Ptr{vk.VkPipelineDepthStencilStateCreateInfo} = C_NULL,
        pColorBlendState::Ptr{vk.VkPipelineColorBlendStateCreateInfo} = C_NULL,
        pDynamicState::Ptr{vk.VkPipelineDynamicStateCreateInfo} = C_NULL,
        layout::vk.VkPipelineLayout, #required
        renderPass::vk.VkRenderPass, #required
        subpass::UInt32 = UInt32(0),
        basePipelineHandle::vk.VkPipeline = vk.VkPipeline(vk.VK_NULL_HANDLE),
        basePipelineIndex::Int32 = Int32(0),
    )

        this = new(Ref(vk.VkGraphicsPipelineCreateInfo(
            vk.VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO, #sType::VkStructureType
            pNext, #pNext::Ptr{Cvoid}
            flags, #flags::VkPipelineCreateFlags
            length(stages), #stageCount::UInt32
            pointer(stages), #pStages::Ptr{VkPipelineShaderStageCreateInfo}
            pVertexInputState, #::Ptr{VkPipelineVertexInputStateCreateInfo}
            pInputAssemblyState, #::Ptr{VkPipelineInputAssemblyStateCreateInfo}
            pTessellationState, #::Ptr{VkPipelineTessellationStateCreateInfo}
            pViewportState, #::Ptr{VkPipelineViewportStateCreateInfo}
            pRasterizationState, #::Ptr{VkPipelineRasterizationStateCreateInfo}
            pMultisampleState, #::Ptr{VkPipelineMultisampleStateCreateInfo}
            pDepthStencilState, #::Ptr{VkPipelineDepthStencilStateCreateInfo}
            pColorBlendState, #::Ptr{VkPipelineColorBlendStateCreateInfo}
            pDynamicState, #::Ptr{VkPipelineDynamicStateCreateInfo}
            layout, #::VkPipelineLayout
            renderPass, #::VkRenderPass
            subpass, #::UInt32
            basePipelineHandle, #::VkPipeline
            basePipelineIndex #::Int32
        )), reserve)
    end
end

function handleRef(this::GraphicsPipelineCreateInfo)::Ref{vk.VkGraphicsPipelineCreateInfo}
    return this.mHandleRef
end

function defaults(::Type{GraphicsPipelineCreateInfo};
    stages::Vector{vk.VkPipelineShaderStageCreateInfo} = Vector{vk.VkPipelineShaderStageCreateInfo}(),
    layout::vk.VkPipelineLayout, #required
    renderPass::vk.VkRenderPass, #required
    subpass::UInt32 = UInt32(0),
    depthTestEnable::vk.VkBool32 = Vk.VK_FALSE,
    depthWriteEnable::vk.VkBool32 = Vk.VK_FALSE,
    frontFace::vk.VkFrontFace = vk.VK_FRONT_FACE_COUNTER_CLOCKWISE,
    inputState::PipelineVertexInputStateCreateInfo = PipelineVertexInputStateCreateInfo()
)::GraphicsPipelineCreateInfo
    inputAssemblyState = PipelineInputAssemblyStateCreateInfo(
                                    topology = vk.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST, #::VkPrimitiveTopology
                                )
    tesselationState = PipelineTessellationStateCreateInfo()

    viewports = [vk.VkViewport(
                    0, #x::Cfloat
                    0, #y::Cfloat
                    float(typemax(Int32)), #width::Cfloat
                    float(typemax(Int32)), #height::Cfloat
                    0.0, #minDepth::Cfloat
                    1.0 #maxDepth::Cfloat
                )]
    scissors = [vk.VkRect2D(vk.VkOffset2D(0, 0), vk.VkExtent2D(typemax(Int32), typemax(Int32)))]
    viewportState = PipelineViewportStateCreateInfo(
                        viewports = viewports,
                        mScissors = scissors
                    )

    rasterizationState = PipelineRasterizationStateCreateInfo(
                            polygonMode = vk.VK_POLYGON_MODE_FILL, #::VkPolygonMode
                            frontFace = vk.VK_FRONT_FACE_COUNTER_CLOCKWISE, #::VkFrontFace
                            lineWidth = Cfloat(1.0) #::Cfloat
                        )

    depthStencilState = PipelineDepthStencilStateCreateInfo(
                            depthCompareOp = vk.VK_COMPARE_OP_GREATER, #::VkCompareOp
                        )

    multisampleState = PipelineMultisampleStateCreateInfo(
                            rasterizationSamples = vk.VK_SAMPLE_COUNT_1_BIT, #::VkSampleCountFlagBits
                            minSampleShading = Cfloat(1.0) #::Cfloat
                        )
    #addNoBlend
    attachments = [PipelineColorBlendAttachmentState(
                        colorBlendOp = vk.VK_BLEND_OP_ADD, #::VkBlendOp
                        alphaBlendOp = vk.VK_BLEND_OP_ADD, #::VkBlendOp
                        colorWriteMask = (vk.VK_COLOR_COMPONENT_R_BIT | vk.VK_COLOR_COMPONENT_G_BIT |
                                            vk.VK_COLOR_COMPONENT_B_BIT | vk.VK_COLOR_COMPONENT_A_BIT) #::VkColorComponentFlags
                    )]
    colorBlendState = PipelineColorBlendStateCreateInfo(
                            logicOp = vk.VK_LOGIC_OP_COPY, #::VkLogicOp
                            attachments = attachments #::Vector{vk.VkPipelineColorBlendAttachmentState}
                        )

    dynamicState = PipelineDynamicStateCreateInfo(states = [vk.VK_DYNAMIC_STATE_VIEWPORT])

    info = GraphicsPipelineCreateInfo([stages,
                                        inputState, inputAssemblyState, tesselationState,
                                        viewportState, rasterizationState, multisampleState,
                                        depthStencilState, colorBlendState, dynamicState],
        stages = stages, #::Vector{vk.VkPipelineShaderStageCreateInfo}
        pVertexInputState = Base.unsafe_convert(Ptr{vk.VkPipelineVertexInputStateCreateInfo}, handleRef(inputState)), #::Ptr{VkPipelineVertexInputStateCreateInfo}
        pInputAssemblyState = Base.unsafe_convert(Ptr{vk.VkPipelineInputAssemblyStateCreateInfo}, handleRef(inputAssemblyState)), #::Ptr{VkPipelineInputAssemblyStateCreateInfo}
        pTessellationState = Base.unsafe_convert(Ptr{vk.VkPipelineTessellationStateCreateInfo}, handleRef(tesselationState)), #::Ptr{VkPipelineTessellationStateCreateInfo}
        pViewportState = Base.unsafe_convert(Ptr{vk.VkPipelineViewportStateCreateInfo}, handleRef(viewportState)), #::Ptr{VkPipelineViewportStateCreateInfo}
        pRasterizationState = Base.unsafe_convert(Ptr{vk.VkPipelineRasterizationStateCreateInfo}, handleRef(rasterizationState)), #::Ptr{VkPipelineRasterizationStateCreateInfo}
        pMultisampleState = Base.unsafe_convert(Ptr{vk.VkPipelineMultisampleStateCreateInfo}, handleRef(multisampleState)), #::Ptr{VkPipelineMultisampleStateCreateInfo}
        pDepthStencilState = Base.unsafe_convert(Ptr{vk.VkPipelineDepthStencilStateCreateInfo}, handleRef(depthStencilState)), #::Ptr{VkPipelineDepthStencilStateCreateInfo}
        pColorBlendState = Base.unsafe_convert(Ptr{vk.VkPipelineColorBlendStateCreateInfo}, handleRef(colorBlendState)), #::Ptr{VkPipelineColorBlendStateCreateInfo}
        pDynamicState = Base.unsafe_convert(Ptr{vk.VkPipelineDynamicStateCreateInfo}, handleRef(dynamicState)), #::Ptr{VkPipelineDynamicStateCreateInfo}
        layout = layout, #::VkPipelineLayout
        renderPass = renderPass, #::VkRenderPass
        subpass = subpass #::UInt32
    )
    return info
end