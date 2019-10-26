struct PipelineRasterizationStateCreateInfo
    mHandleRef::Ref{vk.VkPipelineRasterizationStateCreateInfo}

    function PipelineRasterizationStateCreateInfo(;
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineRasterizationStateCreateFlags = vk.VkFlags(0),
        depthClampEnable::vk.VkBool32 = vk.VkBool32(vk.VK_FALSE),
        rasterizerDiscardEnable::vk.VkBool32 = vk.VkBool32(vk.VK_FALSE),
        polygonMode::vk.VkPolygonMode = vk.VK_POLYGON_MODE_FILL,
        cullMode::vk.VkCullModeFlags = vk.VkFlags(vk.VK_CULL_MODE_NONE),
        frontFace::vk.VkFrontFace = vk.VK_FRONT_FACE_COUNTER_CLOCKWISE,
        depthBiasEnable::vk.VkBool32 = vk.VkBool32(vk.VK_FALSE),
        depthBiasConstantFactor::Cfloat = Cfloat(0.0),
        depthBiasClamp::Cfloat = Cfloat(0.0),
        depthBiasSlopeFactor::Cfloat = Cfloat(0.0),
        lineWidth::Cfloat = Cfloat(1.0)
    )

        this = new(Ref(vk.VkPipelineRasterizationStateCreateInfo(
            vk.VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO, #sType::VkStructureType
            pNext, #::Ptr{Cvoid}
            flags, #::VkPipelineRasterizationStateCreateFlags
            depthClampEnable, #::VkBool32
            rasterizerDiscardEnable, #::VkBool32
            polygonMode, #::VkPolygonMode
            cullMode, #::VkCullModeFlags
            frontFace, #::VkFrontFace
            depthBiasEnable, #::VkBool32
            depthBiasConstantFactor, #::Cfloat
            depthBiasClamp, #::Cfloat
            depthBiasSlopeFactor, #::Cfloat
            lineWidth #::Cfloat
        )))
    end
end

function handleRef(this::PipelineRasterizationStateCreateInfo)::Ref{vk.VkPipelineRasterizationStateCreateInfo}
    this.mHandleRef
end