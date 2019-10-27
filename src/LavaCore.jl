module LavaCore

using VulkanCore
include("common/VkExt.jl")
using .VkExt
export VkExt
include("common/Utils.jl")
using .Utils
export Utils
include("camera/Camera.jl")
using .Camera
export Camera


include("common/FormatInfo.jl")
include("common/ShaderExtension.jl")
include("common/FeatureBase.jl")

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
include("createinfos/ImageCreateInfo.jl")
include("createinfos/BufferCreateInfo.jl")

include("gpuselection/SelectionStrategy.jl")

include("objects/Queue.jl")
include("objects/DescriptorPool.jl")
include("objects/DescriptorSetLayout.jl")
include("objects/DescriptorSet.jl")
include("objects/PipelineLayout.jl")
include("objects/RenderPass.jl")
include("objects/GraphicsPipeline.jl")
include("objects/CommandBuffer.jl")

include("objects/MemoryChunk.jl")
include("objects/Suballocator.jl")

include("objects/Device.jl")
include("objects/Image.jl")
include("objects/ImageView.jl")
include("objects/Framebuffer.jl")
include("objects/Buffer.jl")
include("objects/Instance.jl")

end