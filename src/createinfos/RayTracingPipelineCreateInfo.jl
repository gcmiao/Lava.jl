using GroupType = vk::;
struct Group {
    mModule::ShaderModule
    mType::vk.VkRayTracingShaderGroupTypeNV = GroupType::eGeneral

    function Group(_module::ShaderModule, type::vk.VkRayTracingShaderGroupTypeNV = vk.VK_RAY_TRACING_SHADER_GROUP_TYPE_GENERAL_NV)
        return new(_module, type)
    end
end

mutable struct RayTracingPipelineCreateInfo
    mNumRaygens::Integer
    mNumHitGroups::Integer
    mLayout::PipelineLayout
    mGroups::Vector{vk.VkRayTracingShaderGroupCreateInfoNV}
    mStagesData::Vector{vk.VkPipelineShaderStageCreateInfo}
    mStages::Vector{PipelineShaderStageCreateInfo}
    mModules::Vector{ShaderModule}
    mHandleRef::Ref{vk.VkRayTracingPipelineCreateInfoNV}

    function RayTracingPipelineCreateInfo(layout::PipelineLayout)
        this = new()
        this.mLayout = layout
        return this
    end
end

function handleRef(this::RayTracingPipelineCreateInfo)::Ref{vk.VkRayTracingPipelineCreateInfoNV}
    this.mStagesData = Vector{vk.VkPipelineShaderStageCreateInfo}(undef, length(this.mStages))
    for stage in this.mStages
        push!(this.mStagesData, stage.handleRef()[])
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
        C_NULL, # layout::VkPipelineLayout
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
function addRayGeneration(this::RayTracingPipelineCreateInfo, rgen::ShaderModule)
    auto idx = insertModule(rgen);
mGroups.emplace(begin(mGroups) + mNumRaygens)
    ->setType(vk::RayTracingShaderGroupTypeNV::eGeneral)
    .setGeneralShader(idx)
    .setAnyHitShader(VK_SHADER_UNUSED_NV)
    .setClosestHitShader(VK_SHADER_UNUSED_NV)
    .setIntersectionShader(VK_SHADER_UNUSED_NV);
mNumRaygens++;

return *this;
end

function addMiss(this::RayTracingPipelineCreateInfo, rmiss::ShaderModule)
end

function addTriangleHitGroup(this::RayTracingPipelineCreateInfo, closestHit::ShaderModule, anyHit::ShaderModule)
end

function addProceduralHitGroup(this::RayTracingPipelineCreateInfo, intersection::ShaderModule , closestHit::ShaderModule, anyHit::ShaderModule)
end

function insertModule(_module::ShaderModule)::UInt32
    ret = findfirst(m->m == _module, this.mModules)
    if (ret == nothing)
        push!(this.mModules, _module)
        ret = length(this.mModules)

        stage = lava.defaults(lava.PipelineShaderStageCreateInfo, _module = _module, stage = _module.getStage())
        push!(this.mStages, stage)
    end
    return UInt32(ret)
end
