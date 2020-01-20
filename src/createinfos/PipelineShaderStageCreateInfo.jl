struct PipelineShaderStageCreateInfo
    mHandleRef::Ref{vk.VkPipelineShaderStageCreateInfo}
    mPreserve::Vector{Any}

    function PipelineShaderStageCreateInfo(;
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineShaderStageCreateFlags = vk.VkFlags(0),
        stage::vk.VkShaderStageFlagBits = vk.VK_SHADER_STAGE_ALL,
        _module::vk.VkShaderModule, #required
        name::String = "",
        specializationInfo = nothing #::vk.VkSpecializationInfo
    )

        this = new(Ref(vk.VkPipelineShaderStageCreateInfo(
            vk.VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO, #sType::VkStructureType
            pNext, #pNext::Ptr{Cvoid}
            flags, #flags::VkPipelineShaderStageCreateFlags
            stage, #stage::VkShaderStageFlagBits
            _module, #::vk.VkShaderModule
            Base.unsafe_convert(Cstring, name), #pName::Cstring
            ref_to_pointer(vk.VkSpecializationInfo, specializationInfo), #pSpecializationInfo::Ptr{VkSpecializationInfo}
        )), [specializationInfo])
    end
end

@class PipelineShaderStageCreateInfo

function handleRef(this::PipelineShaderStageCreateInfo)::Ref{vk.VkPipelineShaderStageCreateInfo}
    this.mHandleRef
end

function defaults(::Type{PipelineShaderStageCreateInfo};
    _module::ShaderModule, #required
    name::String = "main",
    stage::vk.VkShaderStageFlagBits = vk.VK_SHADER_STAGE_ALL
    )::PipelineShaderStageCreateInfo

    if (stage == vk.VK_SHADER_STAGE_ALL)
        moduleStage = getStage(_module)
        @assert (moduleStage != vk.VK_SHADER_STAGE_ALL) ("Couldn't find out the type of stage you want to add. Either " *
                                                                "load from a file with a hint for the stage in the name, or " *
                                                                "explicitly provide the stage either to the ShaderModule or " *
                                                                "when you add the stage.")
        stage = moduleStage
    end

    info = PipelineShaderStageCreateInfo(
        _module = handle(_module),
        name = name,
        stage = stage
    )

    return info
end
