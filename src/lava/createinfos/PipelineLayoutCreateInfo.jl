mutable struct PipelineLayoutCreateInfo
    mLayouts::Vector{vk.VkDescriptorSetLayout}
    mRanges::Vector{vk.VkPushConstantRange}

    mHandleRef::Ref{vk.VkPipelineLayoutCreateInfo}

    function PipelineLayoutCreateInfo()
        this = new()
        this.mLayouts = Vector{vk.VkDescriptorSetLayout}()
        this.mRanges = Vector{vk.VkPushConstantRange}()
        return this
    end
end

function addSetLayout(this::PipelineLayoutCreateInfo, layout::vk.VkDescriptorSetLayout)
    push!(this.mLayouts, layout)
end

function addPushConstantRange(this::PipelineLayoutCreateInfo, range::vk.VkPushConstantRange)
    push!(this.mRanges, range)
end

function handleRef(this::PipelineLayoutCreateInfo)::Ref{vk.VkPipelineLayoutCreateInfo}
    this.mHandleRef = Ref(vk.VkPipelineLayoutCreateInfo(
        vk.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO, #sType::VkStructureType
        C_NULL, #pNext::Ptr{Cvoid}
        0, #flags::VkPipelineLayoutCreateFlags
        length(this.mLayouts), #setLayoutCount::UInt32
        pointer(this.mLayouts), #pSetLayouts::Ptr{VkDescriptorSetLayout}
        length(this.mRanges), #pushConstantRangeCount::UInt32
        pointer(this.mRanges) #pPushConstantRanges::Ptr{VkPushConstantRange}
    ))
    return this.mHandleRef
end