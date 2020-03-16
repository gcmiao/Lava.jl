struct Group
    mModule::ShaderModule
    mType::vk.VkRayTracingShaderGroupTypeNV

    Group(_module::ShaderModule,
             type::vk.VkRayTracingShaderGroupTypeNV = vk.VK_RAY_TRACING_SHADER_GROUP_TYPE_GENERAL_NV) = new(_module, type)
end

mutable struct RayTracingPipelineCreateInfo
    mNumRaygens::Integer
    mNumHitGroups::Integer
    mLayout
    mGroups::Vector{vk.VkRayTracingShaderGroupCreateInfoNV} # rayGen|hitGroup|miss
    mStagesData::Vector{vk.VkPipelineShaderStageCreateInfo}
    mStages::Vector{PipelineShaderStageCreateInfo}
    mModules::Vector{ShaderModule}
    mHandleRef::Ref{vk.VkRayTracingPipelineCreateInfoNV}

    function RayTracingPipelineCreateInfo(layout)
        this = new()
        this.mLayout = layout
        this.mGroups = Vector{vk.VkRayTracingShaderGroupCreateInfoNV}()
        this.mStages = Vector{PipelineShaderStageCreateInfo}()
        this.mModules = Vector{ShaderModule}()
        this.mNumRaygens = 0
        this.mNumHitGroups = 0
        return this
    end
end
@class RayTracingPipelineCreateInfo

function handleRef(this::RayTracingPipelineCreateInfo)::Ref{vk.VkRayTracingPipelineCreateInfoNV}
    this.mStagesData = Vector{vk.VkPipelineShaderStageCreateInfo}(undef, length(this.mStages))
    idx = 1
    for stage in this.mStages
        this.mStagesData[idx] = stage.handleRef()[]
        idx += 1
    end

    this.mHandleRef = Ref(vk.VkRayTracingPipelineCreateInfoNV(
        vk.VK_STRUCTURE_TYPE_RAY_TRACING_PIPELINE_CREATE_INFO_NV, # sType::VkStructureType
        C_NULL, # pNext::Ptr{Cvoid}
        vk.VkFlags(0), # flags::VkPipelineCreateFlags
        length(this.mStagesData), # stageCount::UInt32
        pointer(this.mStagesData), # pStages::Ptr{VkPipelineShaderStageCreateInfo}
        length(this.mGroups), # groupCount::UInt32
        pointer(this.mGroups), # pGroups::Ptr{VkRayTracingShaderGroupCreateInfoNV}
        UInt32(0), # maxRecursionDepth::UInt32
        this.mLayout.handleRef()[], # layout::VkPipelineLayout
        C_NULL, # basePipelineHandle::VkPipeline
        Int32(0) # basePipelineIndex::Int32
    ))
    return this.mHandleRef
end

function firstRaygenIndex(this::RayTracingPipelineCreateInfo)::Integer
    return 0
end

function firstHitIndex(this::RayTracingPipelineCreateInfo)::Integer
    return this.mNumRaygens
end

function firstMissIndex(this::RayTracingPipelineCreateInfo)::Integer
    return this.mNumRaygens + this.mNumHitGroups
end

function getLayout(this::RayTracingPipelineCreateInfo)::PipelineLayout
    return this.mLayout
end

function getGroups(this::RayTracingPipelineCreateInfo)::Vector{vk.VkRayTracingShaderGroupCreateInfoNV}
    return this.mGroups
end

# Convenience Interface: add shader modules as shader groups. Stages and
# Groups are automatically created and deduplicated.
function addRayGeneration(this::RayTracingPipelineCreateInfo, rgen::ShaderModule)::RayTracingPipelineCreateInfo
    idx = insertModule(this, rgen)
    this.mNumRaygens += 1
    insert!(this.mGroups, this.mNumRaygens,
        vk.VkRayTracingShaderGroupCreateInfoNV(
            vk.VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_NV, # sType::VkStructureType
            C_NULL, # pNext::Ptr{Cvoid}
            vk.VK_RAY_TRACING_SHADER_GROUP_TYPE_GENERAL_NV, # type::VkRayTracingShaderGroupTypeNV
            idx, # generalShader::UInt32
            vk.VK_SHADER_UNUSED_NV, # closestHitShader::UInt32
            vk.VK_SHADER_UNUSED_NV, # anyHitShader::UInt32
            vk.VK_SHADER_UNUSED_NV # intersectionShader::UInt32
        ))
    return this
end

function addMiss(this::RayTracingPipelineCreateInfo, rmiss::ShaderModule)::RayTracingPipelineCreateInfo
    idx = insertModule(this, rmiss)
    push!(this.mGroups, vk.VkRayTracingShaderGroupCreateInfoNV(
            vk.VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_NV, # sType::VkStructureType
            C_NULL, # pNext::Ptr{Cvoid}
            vk.VK_RAY_TRACING_SHADER_GROUP_TYPE_GENERAL_NV, # type::VkRayTracingShaderGroupTypeNV
            idx, # generalShader::UInt32
            vk.VK_SHADER_UNUSED_NV, # closestHitShader::UInt32
            vk.VK_SHADER_UNUSED_NV, # anyHitShader::UInt32
            vk.VK_SHADER_UNUSED_NV # intersectionShader::UInt32
        ))
    return this
end

function addTriangleHitGroup(this::RayTracingPipelineCreateInfo, closestHit, anyHit = nothing)::RayTracingPipelineCreateInfo
    @assert (closestHit != nothing || anyHit != nothing) "At least one hit shader is needed per hit group"

    this.mNumHitGroups += 1
    insert!(this.mGroups, this.mNumRaygens + this.mNumHitGroups,
        vk.VkRayTracingShaderGroupCreateInfoNV(
            vk.VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_NV, # sType::VkStructureType
            C_NULL, # pNext::Ptr{Cvoid}
            vk.VK_RAY_TRACING_SHADER_GROUP_TYPE_TRIANGLES_HIT_GROUP_NV, # type::VkRayTracingShaderGroupTypeNV
            vk.VK_SHADER_UNUSED_NV, # generalShader::UInt32
            closestHit != nothing ? insertModule(this, closestHit) : vk.VK_SHADER_UNUSED_NV, # closestHitShader::UInt32
            anyHit != nothing ? insertModule(this, anyHit) : vk.VK_SHADER_UNUSED_NV, # anyHitShader::UInt32
            vk.VK_SHADER_UNUSED_NV # intersectionShader::UInt32
        ))
    return this
end

function addProceduralHitGroup(this::RayTracingPipelineCreateInfo, intersection , closestHit, anyHit = nothing)::RayTracingPipelineCreateInfo
    @assert (closestHit != nothing || anyHit != nothing) "At least one hit shader is needed per hit group"
    @assert (intersection != nothing) "Cannot use procedural hit groups without an intersection shader"

    this.mNumHitGroups += 1
    insert!(this.mGroups, this.mNumRaygens + this.mNumHitGroups,
        vk.VkRayTracingShaderGroupCreateInfoNV(
            vk.VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_NV, # sType::VkStructureType
            C_NULL, # pNext::Ptr{Cvoid}
            vk.VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_NV, # type::VkRayTracingShaderGroupTypeNV
            vk.VK_SHADER_UNUSED_NV, # generalShader::UInt32
            closesHit != nothing ? insertModule(this, closesHit) : vk.VK_SHADER_UNUSED_NV, # closestHitShader::UInt32
            anyHit != nothing ? insertModule(this, anyHit) : vk.VK_SHADER_UNUSED_NV, # anyHitShader::UInt32
            insertModule(this, intersection) # intersectionShader::UInt32
        ))
    return this
end

function insertModule(this::RayTracingPipelineCreateInfo, _module::ShaderModule)::UInt32
    ret = findfirst(m->m == _module, this.mModules) # start from 1
    if (ret == nothing)
        push!(this.mModules, _module)
        ret = length(this.mModules)

        stage = defaults(PipelineShaderStageCreateInfo, _module = _module, stage = _module.getStage())
        push!(this.mStages, stage)
    end
    return UInt32(ret - 1)
end
