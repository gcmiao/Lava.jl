struct GraphicsPipelineCreateInfo
    mHandleRef::Ref{vk.VkGraphicsPipelineCreateInfo}
    mPreserve::Vector{Any}
    mLayout

    function GraphicsPipelineCreateInfo(;
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineCreateFlags = vk.VkFlags(0),
        stages::Vector{vk.VkPipelineShaderStageCreateInfo} = Vector{vk.VkPipelineShaderStageCreateInfo}(),
        vertexInputState = nothing, #vk.VkPipelineVertexInputStateCreateInfo,
        inputAssemblyState = nothing, #vk.VkPipelineInputAssemblyStateCreateInfo,
        tessellationState = nothing, #vk.VkPipelineTessellationStateCreateInfo,
        viewportState = nothing, #vk.VkPipelineViewportStateCreateInfo,
        rasterizationState = nothing, #vk.VkPipelineRasterizationStateCreateInfo,
        multisampleState = nothing, #vk.VkPipelineMultisampleStateCreateInfo,
        depthStencilState = nothing, #vk.VkPipelineDepthStencilStateCreateInfo,
        colorBlendState = nothing, #vk.VkPipelineColorBlendStateCreateInfo,
        dynamicState = nothing, #vk.VkPipelineDynamicStateCreateInfo,
        layout, #required
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
            object_to_pointer(vk.VkPipelineVertexInputStateCreateInfo, handleRef(vertexInputState)), #::Ptr{VkPipelineVertexInputStateCreateInfo}
            object_to_pointer(vk.VkPipelineInputAssemblyStateCreateInfo, handleRef(inputAssemblyState)), #::Ptr{VkPipelineInputAssemblyStateCreateInfo}
            object_to_pointer(vk.VkPipelineTessellationStateCreateInfo, handleRef(tessellationState)), #::Ptr{VkPipelineTessellationStateCreateInfo}
            object_to_pointer(vk.VkPipelineViewportStateCreateInfo, handleRef(viewportState)), #::Ptr{VkPipelineViewportStateCreateInfo}
            object_to_pointer(vk.VkPipelineRasterizationStateCreateInfo, handleRef(rasterizationState)), #::Ptr{VkPipelineRasterizationStateCreateInfo}
            object_to_pointer(vk.VkPipelineMultisampleStateCreateInfo, handleRef(multisampleState)), #::Ptr{VkPipelineMultisampleStateCreateInfo}
            object_to_pointer(vk.VkPipelineDepthStencilStateCreateInfo, handleRef(depthStencilState)), #::Ptr{VkPipelineDepthStencilStateCreateInfo}
            object_to_pointer(vk.VkPipelineColorBlendStateCreateInfo, handleRef(colorBlendState)), #::Ptr{VkPipelineColorBlendStateCreateInfo}
            object_to_pointer(vk.VkPipelineDynamicStateCreateInfo, handleRef(dynamicState)), #::Ptr{VkPipelineDynamicStateCreateInfo}
            handleRef(layout)[], #::VkPipelineLayout
            renderPass, #::VkRenderPass
            subpass, #::UInt32
            basePipelineHandle, #::VkPipeline
            basePipelineIndex #::Int32
            )),
            [stages, vertexInputState, inputAssemblyState, tessellationState,
                 viewportState, rasterizationState, multisampleState,
                 depthStencilState, colorBlendState, dynamicState], #mPreserve
            layout # mLayout
        )
        return this
    end
end
    
function handleRef(this::GraphicsPipelineCreateInfo)::Ref{vk.VkGraphicsPipelineCreateInfo}
    return this.mHandleRef
end

function defaults(::Type{GraphicsPipelineCreateInfo};
    stages::Vector{vk.VkPipelineShaderStageCreateInfo} = Vector{vk.VkPipelineShaderStageCreateInfo}(),
    layout, #required
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
    tessellationState = PipelineTessellationStateCreateInfo()

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
                        scissors = scissors
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

    info = GraphicsPipelineCreateInfo(;
        stages = stages, #::Vector{vk.VkPipelineShaderStageCreateInfo
        vertexInputState = inputState, #::VkPipelineVertexInputStateCreateInfo
        inputAssemblyState = inputAssemblyState, #::VkPipelineInputAssemblyStateCreateInfo
        tessellationState = tessellationState, #::VkPipelineTessellationStateCreateInfo
        viewportState = viewportState, #::VkPipelineViewportStateCreateInfo
        rasterizationState = rasterizationState, #::VkPipelineRasterizationStateCreateInfo
        multisampleState = multisampleState, #::VkPipelineMultisampleStateCreateInfo
        depthStencilState = depthStencilState, #::VkPipelineDepthStencilStateCreateInfo
        colorBlendState = colorBlendState, #::VkPipelineColorBlendStateCreateInfo
        dynamicState = dynamicState, #
        layout = layout, #::PipelineLayout
        renderPass = renderPass, #::VkRenderPass
        subpass = subpass #::UInt32
    )
    return info
end