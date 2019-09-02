mutable struct PipelineViewportStateCreateInfo
    mViewports::Vector{vk.VkViewport}
    mScissors::Vector{vk.VkRect2D}

    mHandleRef::Ref{vk.VkPipelineViewportStateCreateInfo}

    function PipelineViewportStateCreateInfo()
        this = new()
        this.mViewports = Vector{vk.VkViewport}()
        this.mScissors = Vector{vk.VkRect2D}()
        return this
    end
end

function addViewport(this::PipelineViewportStateCreateInfo, vp::vk.VkViewport)
    push!(this.mViewports, vp)
end

function addScissor(this::PipelineViewportStateCreateInfo, sc::vk.VkRect2D)
    push!(this.mScissors, sc)
end

function commit(this::PipelineViewportStateCreateInfo)
    this.mHandleRef = Ref(vk.VkPipelineViewportStateCreateInfo(
                            vk.VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO, #sType::VkStructureType
                            C_NULL, #pNext::Ptr{Cvoid}
                            0, #flags::VkPipelineViewportStateCreateFlags
                            length(this.mViewports), #viewportCount::UInt32
                            pointer(this.mViewports), #pViewports::Ptr{VkViewport}
                            length(this.mScissors), #scissorCount::UInt32
                            pointer(this.mScissors) #pScissors::Ptr{VkRect2D}
                        ))
end

function handleRef(this::PipelineViewportStateCreateInfo)::Ref{vk.VkPipelineViewportStateCreateInfo}
    return this.mHandleRef
end
