struct ComputePipelineCreateInfo
    mHandleRef::Ref{vk.VkComputePipelineCreateInfo}
    mLayout

    function ComputePipelineCreateInfo(
        stage::PipelineShaderStageCreateInfo, # required
        layout; # ::PipelineLayout
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineCreateFlags = vk.VkFlags(0),
        basePipelineHandle::vk.VkPipeline = vk.VkPipeline(vk.VK_NULL_HANDLE), # ::VkPipeline
        basePipelineIndex::Int32 = Int32(0)) # ::Int32

            new(Ref(vk.VkComputePipelineCreateInfo(
                vk.VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO, # sType::VkStructureType
                pNext, # ::Ptr{Cvoid}
                flags, # ::VkPipelineCreateFlags
                stage.handleRef()[], # ::VkPipelineShaderStageCreateInfo
                layout.handleRef()[], # ::VkPipelineLayout
                basePipelineHandle, # ::VkPipeline
                basePipelineIndex)), # ::Int32)
                layout
            )
    end
end
@class ComputePipelineCreateInfo

function handleRef(this::ComputePipelineCreateInfo)::Ref{vk.VkComputePipelineCreateInfo}
    return this.mHandleRef
end
