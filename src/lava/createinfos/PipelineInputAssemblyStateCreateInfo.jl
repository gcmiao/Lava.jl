struct PipelineInputAssemblyStateCreateInfo
    mHandleRef::vk.VkPipelineInputAssemblyStateCreateInfo

    function PipelineInputAssemblyStateCreateInfo(;
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineInputAssemblyStateCreateFlags = 0,
        topology::vk.VkPrimitiveTopology = vk.VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST,
        primitiveRestartEnable::vk.VkBool32 = vk.VK_FALSE
    )
        
        this = new(vk.VkPipelineInputAssemblyStateCreateInfo(
            vk.VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO, #sType::VkStructureType
            pNext, #::Ptr{Cvoid}
            flags, #::VkPipelineInputAssemblyStateCreateFlags
            topology, #::VkPrimitiveTopology
            primitiveRestartEnable #::VkBool32
        ))
    end
end

function handleRef(this::PipelineInputAssemblyStateCreateInfo)::Ref{vk.VkPipelineInputAssemblyStateCreateInfo}
    this.mHandleRef
end