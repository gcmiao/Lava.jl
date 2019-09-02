mutable struct PipelineVertexInputStateCreateInfo
    mAttributes::Vector{vk.VkVertexInputAttributeDescription}
    mBindings::Vector{vk.VkVertexInputBindingDescription}

    mHandleRef::vk.VkPipelineVertexInputStateCreateInfo

    function PipelineVertexInputStateCreateInfo()
        this = new()
        this.mAttributes = Vector{vk.VkVertexInputAttributeDescription}()
        this.mBindings = Vector{vk.VkVertexInputBindingDescription}()
        return this
    end
end

function commit(this::PipelineVertexInputStateCreateInfo)
    this.mHandleRef = VkPipelineVertexInputStateCreateInfo(
        vk.VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO, #sType::VkStructureType
        C_NULL, #pNext::Ptr{Cvoid}
        0, #flags::VkPipelineVertexInputStateCreateFlags
        length(this.mBindings), #vertexBindingDescriptionCount::UInt32
        pointer(this.mBindings), #pVertexBindingDescriptions::Ptr{VkVertexInputBindingDescription}
        length(this.mAttributes), #vertexAttributeDescriptionCount::UInt32
        pointer(this.mAttributes) #pVertexAttributeDescriptions::Ptr{VkVertexInputAttributeDescription}
    )
end

function handleRef(this::PipelineVertexInputStateCreateInfo)::Ref{vk.VkPipelineVertexInputStateCreateInfo}
    return this.handleRef
end