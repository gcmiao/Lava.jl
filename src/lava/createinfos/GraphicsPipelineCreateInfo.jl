include("PipelineVertexInputStateCreateInfo.jl")
include("PipelineViewportStateCreateInfo.jl")
include("PipelineColorBlendStateCreateInfo.jl")
include("PipelineDynamicStateCreateInfo.jl")

mutable struct GraphicsPipelineCreateInfo
    vertexInputState::PipelineVertexInputStateCreateInfo
    inputAssemblyStateRef::Ref{vk.VkPipelineInputAssemblyStateCreateInfo}
    tesselationStateRef::Ref{vk.VkPipelineTessellationStateCreateInfo}
    viewportState::PipelineViewportStateCreateInfo
    rasterizationStateRef::Ref{vk.VkPipelineRasterizationStateCreateInfo}
    depthStencilStateRef::Ref{vk.VkPipelineDepthStencilStateCreateInfo}
    multisampleStateRef::Ref{vk.VkPipelineMultisampleStateCreateInfo}
    colorBlendState::PipelineColorBlendStateCreateInfo
    dynamicState::PipelineDynamicStateCreateInfo

    bool mUseTesselation = false;
    mStages::Vector{PipelineShaderStageCreateInfo}
    mLayout::PipelineLayout
    mPass::RenderPass

    mHandleRef::vk.VkGraphicsPipelineCreateInfo

    function GraphicsPipelineCreateInfo()
        this = new()
        this.vertexInputState = PipelineVertexInputStateCreateInfo()
        this.viewportState = PipelineViewportStateCreateInfo()
        this.colorBlendState = PipelineColorBlendStateCreateInfo()
        this.dynamicState = PipelineDynamicStateCreateInfo()
        this.tesselationStateRef = Ref(vk.VkPipelineTessellationStateCreateInfo(
                                            vk.VK_STRUCTURE_TYPE_PIPELINE_TESSELLATION_STATE_CREATE_INFO, #sType::VkStructureType
                                            C_NULL, #pNext::Ptr{Cvoid}
                                            0, #flags::VkPipelineTessellationStateCreateFlags
                                            0 #patchControlPoints::UInt32
                                        ))
        return this
    end
end

function defaults(::Type{GraphicsPipelineCreateInfo})::GraphicsPipelineCreateInfo
    info = GraphicsPipelineCreateInfo()
    info.inputAssemblyStateRef = Ref(vk.VkPipelineInputAssemblyStateCreateInfo(
                                        vk.VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO, #sType::VkStructureType
                                        C_NULL, #pNext::Ptr{Cvoid}
                                        0, #flags::VkPipelineInputAssemblyStateCreateFlags
                                        vk.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST, #topology::VkPrimitiveTopology
                                        vk.VK_FALSE #primitiveRestartEnable::VkBool32
                                    ))

    addViewport(info.viewportState, vk.VkViewport(
                                                    0, #x::Cfloat
                                                    0, #y::Cfloat
                                                    float(INT32_MAX), #width::Cfloat
                                                    float(INT32_MAX), #height::Cfloat
                                                    0.f, #minDepth::Cfloat
                                                    1.f #maxDepth::Cfloat
                                                ))
    addScissor(info.viewportState, vk.VkRect2D(vk.VkOffset2D(0, 0), vk.VkExtent2D(INT32_MAX, INT32_MAX)))

    info.rasterizationStateRef = Ref(vk.VkPipelineRasterizationStateCreateInfo(
                                        vk.VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO, #sType::VkStructureType
                                        C_NULL, #pNext::Ptr{Cvoid}
                                        0, #flags::VkPipelineRasterizationStateCreateFlags
                                        vk.VK_FALSE, #depthClampEnable::VkBool32
                                        vk.VK_FALSE, #rasterizerDiscardEnable::VkBool32
                                        vk.VK_POLYGON_MODE_FILL, #polygonMode::VkPolygonMode
                                        vk.VK_CULL_MODE_NONE, #cullMode::VkCullModeFlags
                                        vk.VK_FRONT_FACE_COUNTER_CLOCKWISE, #frontFace::VkFrontFace
                                        vk.VK_FALSE, #depthBiasEnable::VkBool32
                                        0.0, #depthBiasConstantFactor::Cfloat
                                        0.0, #depthBiasClamp::Cfloat
                                        0.0, #depthBiasSlopeFactor::Cfloat
                                        1.f #lineWidth::Cfloat
                                    ))

    info.depthStencilStateRef = Ref(vk.VkPipelineDepthStencilStateCreateInfo(
                                        vk.VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO, #sType::VkStructureType
                                        C_NULL, #pNext::Ptr{Cvoid}
                                        0, #flags::VkPipelineDepthStencilStateCreateFlags
                                        vk.VK_FALSE, #depthTestEnable::VkBool32
                                        vk.VK_FALSE, #depthWriteEnable::VkBool32
                                        vk.VK_COMPARE_OP_GREATER, #depthCompareOp::VkCompareOp
                                        vk.VK_FALSE, #depthBoundsTestEnable::VkBool32
                                        vk.VK_FALSE, #stencilTestEnable::VkBool32
                                        vk.VkStencilOpState(
                                                VK_STENCIL_OP_KEEP, #failOp::VkStencilOp
                                                vk.VK_STENCIL_OP_KEEP, #passOp::VkStencilOp
                                                vk.VK_STENCIL_OP_KEEP, #depthFailOp::VkStencilOp
                                                vk.VK_COMPARE_OP_NEVER, #compareOp::VkCompareOp
                                                0, #compareMask::UInt32
                                                0, #writeMask::UInt32
                                                0 #reference::UInt32
                                            ), #front::VkStencilOpState
                                        vk.VkStencilOpState(
                                                VK_STENCIL_OP_KEEP, #failOp::VkStencilOp
                                                vk.VK_STENCIL_OP_KEEP, #passOp::VkStencilOp
                                                vk.VK_STENCIL_OP_KEEP, #depthFailOp::VkStencilOp
                                                vk.VK_COMPARE_OP_NEVER, #compareOp::VkCompareOp
                                                0, #compareMask::UInt32
                                                0, #writeMask::UInt32
                                                0 #reference::UInt32
                                            ), #back::VkStencilOpState
                                        0, #minDepthBounds::Cfloat
                                        0 #maxDepthBounds::Cfloat
                                    ))

    info.multisampleStateRef = Ref(vk.VkPipelineMultisampleStateCreateInfo(
                                        vk.VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO, #sType::VkStructureType
                                        C_NULL, #pNext::Ptr{Cvoid}
                                        0, #flags::VkPipelineMultisampleStateCreateFlags
                                        vk.VK_SAMPLE_COUNT_1_BIT, #rasterizationSamples::VkSampleCountFlagBits
                                        vk.VK_FALSE, #sampleShadingEnable::VkBool32
                                        1.f, #minSampleShading::Cfloat
                                        C_NULL, #pSampleMask::Ptr{VkSampleMask}
                                        vk.VK_FALSE, #alphaToCoverageEnable::VkBool32
                                        vk.VK_FALSE #alphaToOneEnable::VkBool32
                                    ))

    addNoBlend(info.colorBlendState)
    commit(info.colorBlendState)

    addState(info.dynamicState, vk.VK_DYNAMIC_STATE_VIEWPORT)
    commit(info.dynamicState)

    return info
end

function setLayout(this::GraphicsPipelineCreateInfo, layout::PipelineLayout)
    this.mLayout = layout
end

function commit(this::GraphicsPipelineCreateInfo)

    vkStages = Vector{vk.VkPipelineShaderStageCreateInfo}()
    for stage in this.mStages
        push!(vkStages, handleRef(stage))
    end
    this.mHandleRef = vk.VkGraphicsPipelineCreateInfo(
        vk.VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO, #sType::VkStructureType
        C_NULL, #pNext::Ptr{Cvoid}
        0, #flags::VkPipelineCreateFlags
        length(vkStages), #stageCount::UInt32
        pointer(vkStages), #pStages::Ptr{VkPipelineShaderStageCreateInfo}
        Base.unsafe_convert(Ptr{vk.VkPipelineVertexInputStateCreateInfo}, handleRef(this.vertexInputState)), #pVertexInputState::Ptr{VkPipelineVertexInputStateCreateInfo}
        Base.unsafe_convert(Ptr{vk.VkPipelineInputAssemblyStateCreateInfo}, this.inputAssemblyStateRef), #pInputAssemblyState::Ptr{VkPipelineInputAssemblyStateCreateInfo}
        Base.unsafe_convert(Ptr{vk.VkPipelineTessellationStateCreateInfo}, this.tesselationStateRef), #pTessellationState::Ptr{VkPipelineTessellationStateCreateInfo}
        handleRef(this.viewportState), #pViewportState::Ptr{VkPipelineViewportStateCreateInfo}
        Base.unsafe_convert(Ptr{vk.VkPipelineRasterizationStateCreateInfo}, this.rasterizationStateRef), #pRasterizationState::Ptr{VkPipelineRasterizationStateCreateInfo}
        Base.unsafe_convert(Ptr{vk.VkPipelineMultisampleStateCreateInfo}, this.multisampleStateRef), #pMultisampleState::Ptr{VkPipelineMultisampleStateCreateInfo}
        Base.unsafe_convert(Ptr{vk.VkPipelineDepthStencilStateCreateInfo}, this.depthStencilStateRef), #pDepthStencilState::Ptr{VkPipelineDepthStencilStateCreateInfo}
        handleRef(info.colorBlendState), #pColorBlendState::Ptr{VkPipelineColorBlendStateCreateInfo}
        handleRef(info.dynamicState), #pDynamicState::Ptr{VkPipelineDynamicStateCreateInfo}
        handleRef(this.mLayout)[], #layout::VkPipelineLayout
        handleRef(this.mPass)[], #renderPass::VkRenderPass
        0, #subpass::UInt32
        vk.VK_NULL_HANDLE, #basePipelineHandle::VkPipeline
        0 #basePipelineIndex::Int32
    )
end

function handleRef(this::GraphicsPipelineCreateInfo)::vk.VkGraphicsPipelineCreateInfo
    return this.mHandleRef
end