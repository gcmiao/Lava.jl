const stageForEnding = Dict{String, vk.VkShaderStageFlagBits}([
    ("vert.spv", vk.VK_SHADER_STAGE_VERTEX_BIT),
    ("vert", vk.VK_SHADER_STAGE_VERTEX_BIT),
    ("frag.spv", vk.VK_SHADER_STAGE_FRAGMENT_BIT),
    ("frag", vk.VK_SHADER_STAGE_FRAGMENT_BIT),
    ("geom.spv", vk.VK_SHADER_STAGE_GEOMETRY_BIT),
    ("geom", vk.VK_SHADER_STAGE_GEOMETRY_BIT),
    ("tcsh.spv", vk.VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT),
    ("tcsh", vk.VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT),
    ("tesc.spv", vk.VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT),
    ("tesc", vk.VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT),
    ("tesh.spv", vk.VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT),
    ("tesh", vk.VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT),
    ("tese.spv", vk.VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT),
    ("tese", vk.VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT),
    ("comp.spv", vk.VK_SHADER_STAGE_COMPUTE_BIT),
    ("comp", vk.VK_SHADER_STAGE_COMPUTE_BIT),
    ("rgen.spv", vk.VK_SHADER_STAGE_RAYGEN_BIT_NV),
    ("rgen", vk.VK_SHADER_STAGE_RAYGEN_BIT_NV),
    ("rint.spv", vk.VK_SHADER_STAGE_INTERSECTION_BIT_NV),
    ("rint", vk.VK_SHADER_STAGE_INTERSECTION_BIT_NV),
    ("rahit.spv", vk.VK_SHADER_STAGE_ANY_HIT_BIT_NV),
    ("rahit", vk.VK_SHADER_STAGE_ANY_HIT_BIT_NV),
    ("rchit.spv", vk.VK_SHADER_STAGE_CLOSEST_HIT_BIT_NV),
    ("rchit", vk.VK_SHADER_STAGE_CLOSEST_HIT_BIT_NV),
    ("rmiss.spv", vk.VK_SHADER_STAGE_MISS_BIT_NV),
    ("rmiss", vk.VK_SHADER_STAGE_MISS_BIT_NV),
    ("rcall.spv", vk.VK_SHADER_STAGE_CALLABLE_BIT_NV),
    ("rcall", vk.VK_SHADER_STAGE_CALLABLE_BIT_NV),
    ("task.spv", vk.VK_SHADER_STAGE_TASK_BIT_NV),
    ("task", vk.VK_SHADER_STAGE_TASK_BIT_NV),
    ("mesh.spv", vk.VK_SHADER_STAGE_MESH_BIT_NV),
    ("mesh", vk.VK_SHADER_STAGE_MESH_BIT_NV)
])

function identifyShader(filename::String)::vk.VkShaderStageFlagBits
    for s in stageForEnding
        if endswith(filename, s.first)
            return s.second
        end
    end
    return vk.VK_SHADER_STAGE_ALL
end