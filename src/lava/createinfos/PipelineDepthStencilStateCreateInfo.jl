function StencilOpState(; 
    failOp::vk.VkStencilOp = vk.VK_STENCIL_OP_KEEP,
    passOp::vk.VkStencilOp = vk.VK_STENCIL_OP_KEEP,
    depthFailOp::vk.VkStencilOp = vk.VK_STENCIL_OP_KEEP,
    compareOp::vk.VkCompareOp = vk.VK_COMPARE_OP_NEVER,
    compareMask::UInt32 = 0,
    writeMask::UInt32 = 0,
    reference::UInt32 = 0
)
    
    vk.VkStencilOpState(
        ailOp, #::VkStencilOp
        passOp, #::VkStencilOp
        depthFailOp, #::VkStencilOp
        compareOp, #::VkCompareOp
        compareMask, #::UInt32
        writeMask, #::UInt32
        reference #::UInt32
    )
end

struct PipelineDepthStencilStateCreateInfo
    mHandleRef::vk.VkPipelineDepthStencilStateCreateInfo

    function PipelineDepthStencilStateCreateInfo(;
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineDepthStencilStateCreateFlags = 0,
        depthTestEnable::vk.VkBool32 = vk.VK_FALSE,
        depthWriteEnable::vk.VkBool32 = vk.VK_FALSE,
        depthCompareOp::vk.VkCompareOp = VK_COMPARE_OP_NEVER,
        depthBoundsTestEnable::vk.VkBool32 = vk.VK_FALSE,
        stencilTestEnable::vk.VkBool32 = vk.VK_FALSE,
        front::vk.VkStencilOpState = StencilOpState(),
        back::vk.VkStencilOpState = StencilOpState(),
        minDepthBounds::Cfloat = 0,
        maxDepthBounds::Cfloat = 0
    )

        this = new(Ref(vk.VkPipelineDepthStencilStateCreateInfo(
            vk.VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO, #sType::VkStructureType
            pNext, #::Ptr{Cvoid}
            flags, #::VkPipelineDepthStencilStateCreateFlags
            depthTestEnable, #::VkBool32
            depthWriteEnable, #::VkBool32
            depthCompareOp, #::VkCompareOp
            depthBoundsTestEnable, #::VkBool32
            stencilTestEnable, #::VkBool32
            front, #::VkStencilOpState
            back, #::VkStencilOpState
            minDepthBounds, #::Cfloat
            maxDepthBounds #::Cfloat
        )))
    end
end

function handleRef(this::PipelineDepthStencilStateCreateInfo)::Ref{vk.VkPipelineDepthStencilStateCreateInfo}
    this.mHandleRef
end