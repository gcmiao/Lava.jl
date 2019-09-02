mutable struct PipelineDynamicStateCreateInfo
    mStates::Vector{vk.VkDynamicState}
    
    mHandleRef::Ref{vk.VkPipelineDynamicStateCreateInfo}

    function PipelineDynamicStateCreateInfo()
        this = new()
        this.mStates = Vector{vk.VkDynamicState}()
        return this
    end
end

function addState(this::PipelineDynamicStateCreateInfo, state::vk.VkDynamicState)
    push!(this.mStates, state)
end

function commit(this::PipelineDynamicStateCreateInfo)
    this.handleRef = Ref(vk.VkPipelineDynamicStateCreateInfo(
                                vk.VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO, #sType::VkStructureType
                                C_NULL, #pNext::Ptr{Cvoid}
                                0, #flags::VkPipelineDynamicStateCreateFlags
                                length(this.mStates), #dynamicStateCount::UInt32
                                pointer(this.mStates) #pDynamicStates::Ptr{VkDynamicState}
                            ))
end

function handleRef(this::PipelineDynamicStateCreateInfo)::Ref{vk.VkPipelineDynamicStateCreateInfo}
    return this.handleRef
end
