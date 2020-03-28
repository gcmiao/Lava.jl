module LavaCore

include("common/Common.jl")
include("common/Utils.jl")
using .Utils
export Utils

using VulkanCore
include("common/VkExt.jl")
using .VkExt
export VkExt
include("camera/Camera.jl")
using .Camera
export Camera

using GeometryTypes
include("common/FormatInfo.jl")
include("common/LayoutInfo.jl")
include("common/ShaderExtension.jl")
include("common/FeatureBase.jl")
include("common/RigidTransform.jl")

include("objects/ShaderModule.jl")

include("createinfos/DescriptorSetLayoutCreateInfo.jl")
include("createinfos/DescriptorPoolCreateInfo.jl")
include("createinfos/PipelineLayoutCreateInfo.jl")
include("createinfos/RenderPassCreateInfo.jl")
include("createinfos/PipelineColorBlendStateCreateInfo.jl")
include("createinfos/PipelineDepthStencilStateCreateInfo.jl")
include("createinfos/PipelineDynamicStateCreateInfo.jl")
include("createinfos/PipelineInputAssemblyStateCreateInfo.jl")
include("createinfos/PipelineMultisampleStateCreateInfo.jl")
include("createinfos/PipelineRasterizationStateCreateInfo.jl")
include("createinfos/PipelineShaderStageCreateInfo.jl")
include("createinfos/PipelineTessellationStateCreateInfo.jl")
include("createinfos/PipelineVertexInputStateCreateInfo.jl")
include("createinfos/PipelineViewportStateCreateInfo.jl")
include("createinfos/GraphicsPipelineCreateInfo.jl")
include("createinfos/ComputePipelineCreateInfo.jl")
include("createinfos/RayTracingPipelineCreateInfo.jl")
include("createinfos/ImageCreateInfo.jl")
include("createinfos/BufferCreateInfo.jl")
include("createinfos/SamplerCreateInfo.jl")
include("createinfos/BottomLevelAccelerationStructureCreateInfo.jl")

include("gpuselection/SelectionStrategy.jl")

include("objects/MemoryChunk.jl")
include("objects/Suballocator.jl")

include("objects/Instance.jl")
include("objects/Queue.jl")
include("objects/Device.jl")
include("objects/DescriptorPool.jl")
include("objects/DescriptorSetLayout.jl")
include("objects/PipelineLayout.jl")
include("objects/RenderPass.jl")

include("objects/Buffer.jl")
include("objects/Image.jl")
include("objects/ImageView.jl")
include("objects/ImageData.jl")
include("objects/Framebuffer.jl")
include("objects/CommandBuffer.jl")
include("objects/Sampler.jl")
include("objects/BottomLevelAccelerationStructure.jl")
include("objects/TopLevelAccelerationStructure.jl")
include("objects/DescriptorSetWriter.jl")
include("objects/DescriptorSet.jl")

include("raii/ActiveRenderPass.jl")
include("raii/Barriers.jl")

include("objects/GraphicsPipeline.jl")
include("objects/ComputePipeline.jl")
include("objects/RayTracingPipeline.jl")

end
