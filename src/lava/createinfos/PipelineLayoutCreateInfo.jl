mutable struct PipelineLayoutCreateInfo
    mLayouts::Array{vk.VkDescriptorSetLayout, 1}
    mRanges::Array{vk.VkPushConstantRange, 1}

    mHandleRef::Ref{vk.VkPipelineLayoutCreateInfo}

    function PipelineLayoutCreateInfo()
        this = new()
        this.mLayouts = Array{vk.VkDescriptorSetLayout, 1}()
        this.mRanges = Array{vk.VkPushConstantRange, 1}()
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