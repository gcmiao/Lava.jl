struct PipelineVertexInputStateCreateInfo
    mHandleRef::Ref{vk.VkPipelineVertexInputStateCreateInfo}
    reserve::Vector{Any}

    function PipelineVertexInputStateCreateInfo(
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineVertexInputStateCreateFlags = 0,
        attributes::Vector{vk.VkVertexInputAttributeDescription} = Vector{vk.VkVertexInputAttributeDescription}(),
        bindings::Vector{vk.VkVertexInputBindingDescription} = Vector{vk.VkVertexInputBindingDescription}()
    )

        this = new(Ref(vk.VkPipelineVertexInputStateCreateInfo(
            vk.VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO, #sType::VkStructureType
            pNext, #::Ptr{Cvoid}
            flags, #::VkPipelineVertexInputStateCreateFlags
            length(bindings), #vertexBindingDescriptionCount::UInt32
            pointer(bindings), #pVertexBindingDescriptions::Ptr{VkVertexInputBindingDescription}
            length(attributes), #vertexAttributeDescriptionCount::UInt32
            pointer(attributes) #pVertexAttributeDescriptions::Ptr{VkVertexInputAttributeDescription}
        ), [attributes, bindings]))
    end
end

function handleRef(this::PipelineVertexInputStateCreateInfo)::Ref{vk.VkPipelineVertexInputStateCreateInfo}
    this.mHandleRef
end